# PDF Extractor — Project Context

> This file is the authoritative reference for any AI assistant working on this codebase. Read it fully before making any changes.

---

## What This App Does

**PDF Extractor** is a Rails 8 web application that automates the extraction of purchase order (PO) data from PDF documents and exports it into a standardized Excel format (`StandardSalesOrder.xlsx`).

**Business Context:** A garment/textile supplier receives PO documents from multiple international buyers (Levi's, ASOS, Kontoor, etc.) each with a different PDF format. Instead of manually keying the data, this app:

1. Accepts uploaded PO PDFs
2. Auto-detects which buyer the document is from
3. Sends the PDF to **Google Gemini AI** (via API) with a buyer-specific prompt to extract structured data
4. Maps the extracted data to a canonical internal schema
5. Lets the user download a standardized Excel file ready for their ERP/OC system

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Ruby on Rails 8.0 |
| Database | PostgreSQL |
| Background Jobs | Solid Queue (`:async` adapter in dev) |
| File Storage | Active Storage (local disk) |
| Frontend | React 18 (JSX) via `jsbundling-rails` |
| AI / OCR | Google Gemini API (`gemini-3-flash-preview`) |
| PDF Reading | `pdf-reader` gem |
| PDF Splitting | `combine_pdf` gem |
| Excel Export | `axlsx` + `axlsx_rails` gems |
| HTTP Client | `httparty` gem |
| Auth | Custom session-based auth with `bcrypt` |
| Deployment | Kamal (Docker-based) |

---

## Architecture Overview

```
User Browser (React SPA)
       │
       │ JSON API calls
       ▼
Rails Controllers (REST API + HTML shell)
       │
       ├── DocumentsController   — main CRUD + export endpoints
       └── SessionsController    — login/logout
       
       │ on upload
       ▼
DocumentProcessingJob (Solid Queue background job)
       │
       ▼
DocumentProcessingService
       ├── 1. BuyerDetectionService   — regex match on first 2 pages of PDF
       ├── 2. PdfSplittingService     — split if > 4 POs (batches of 4)
       └── 3. GeminiOcrService        — send PDF to Gemini, parse JSON response
              └── Buyers::BuyerFactory
                     ├── Buyers::<Name>::Prompt  — buyer-specific extraction prompt
                     └── Buyers::<Name>::Mapper  — maps Gemini output → Excel schema
```

---

## Document Lifecycle / Status Machine

```
[uploaded] → pending → processing → completed
                                 └→ failed
```

- **`pending`** — uploaded, job queued
- **`processing`** — `mark_as_processing!` called, job running
- **`completed`** — `mark_as_completed!(data)` called, `extracted_data` JSON stored in DB
- **`failed`** — `mark_as_failed!(error_msg)` called, `error_message` stored

On completion, an `OcrAuditLog` record is also created tracking page count and whether it was an `initial_scan` or `retry`.

A failed document can be **retried** via `POST /documents/:id/retry` — it resets to `pending` and re-queues the job (sets `is_retry: true`).

---

## Key Database Tables

### `documents`
| Column | Type | Notes |
|---|---|---|
| `name` | string | User-visible label |
| `status` | string | pending/processing/completed/failed |
| `buyer` | string | Snake_case buyer key (see buyers list) |
| `buyer_detection` | string | Always `"auto"` currently |
| `extracted_data` | json | Stores the full extraction result including `excel_data` array |
| `page_count` | integer | Total pages in PDF |
| `is_retry` | boolean | True if this run was a retry |
| `batch_upload_id` | string | UUID grouping documents uploaded together (nullable) |
| `error_message` | text | Set on failure |
| `processed_at` | datetime | Timestamp of completion or failure |

### `ocr_audit_logs`
Tracks every successful OCR operation for usage monitoring:
- `document_id`, `buyer`, `page_count`, `operation_type` (`initial_scan` / `retry`)

### `users`
Simple email + bcrypt password. Created via seeds (`db/seeds.rb`).

---

## Supported Buyers

Each buyer has its own namespace under `app/services/buyers/<name>/`:
- `levis` → Levi Strauss
- `pvh_tommy` → PVH Tommy Hilfiger
- `asos` → ASOS
- `kontoor` → Kontoor Brands
- `bestseller` → Bestseller (international, identified by "Order no" field)
- `bestseller_domestic` → Bestseller Domestic (identified by "PO number" field)
- `barbour` → Barbour
- `ll_bean` → L.L.Bean
- `superdry_uk` → Superdry UK (DKH Retail entity)
- `superdry_australia` → Superdry Australia (BrandCollective entity)

### Adding a New Buyer

1. Create directory: `app/services/buyers/<name>/`
2. Create `prompt.rb` — class `Buyers::<Name>::Prompt` with `self.build` method returning the LLM prompt string
3. Create `mapper.rb` — class `Buyers::<Name>::Mapper` with `self.build_excel_row(header, line_item)` returning the standardized hash
4. Register in `BuyerDetectionService::DETECTION_PATTERNS` with regex patterns
5. Add to `BuyerFactory#prompt_for` and `BuyerFactory#mapper_for` case statements
6. Add to `Document::VALID_BUYERS` constant
7. Add display name to `Document#buyer_display_name`

---

## Processing Pipeline (Detailed)

### Step 1 — Buyer Detection (`BuyerDetectionService`)
- Reads first 2 pages of PDF using `pdf-reader`
- Matches text against `DETECTION_PATTERNS` regexes (first match wins)
- Returns buyer key or `nil` (which causes the job to fail with "Unable to detect buyer type")
- **Note:** Bestseller vs Bestseller Domestic distinction is pattern order-sensitive — `bestseller` checks for "Order no", `bestseller_domestic` checks for "PO number"

### Step 2 — PDF Splitting (`PdfSplittingService`)
- Constants: `BATCH_SIZE = 4`, `PO_THRESHOLD = 4`
- Scans all pages with `PO_PATTERNS` regexes to find unique PO numbers and their start pages
- If PO count > 4: splits PDF into chunks of 4 POs using `combine_pdf`, saves as `Tempfile`s
- If PO count ≤ 4: processes as single file
- Tempfiles are kept alive via `batch[:tempfiles]` references and only cleaned up after all batches are processed

### Step 3 — Gemini OCR (`GeminiOcrService`)
- Encodes PDF to Base64
- Calls `gemini-3-flash-preview` via REST API with the buyer-specific prompt
- Generation config: `temperature: 0.0`, `maxOutputTokens: 32768`, `thinkingLevel: "minimal"`
- Retries up to **5 times** with 5-second sleep on 503 (service overloaded) errors
- Timeout: 240 seconds per request
- Strips markdown code fences from response before JSON parsing
- Returns array of PO objects

### Step 4 — Data Mapping
- `GeminiOcrService#convert_to_excel_format` calls `BuyerFactory.mapper_for(@buyer)`
- Each PO object has a `"line_items"` array — each line item becomes one row
- If `line_items` is empty, a single row is created with empty line item fields
- The mapper produces a flat hash with 47 standardized keys (the Excel schema)

### Step 5 — Storage
`DocumentProcessingService` stores the result in `document.extracted_data`:
```json
{
  "extraction_method": "gemini" | "gemini_split",
  "buyer": "levis",
  "excel_data": [...],
  "total_line_items": 42,
  "total_pos": 5,
  "batches_processed": 2,
  "processed_at": "2026-04-25T10:00:00Z"
}
```

---

## Gemini Prompt Design

Every buyer prompt follows this contract:

- **Input:** Raw PDF (base64 inline data) sent as `inlineData` part
- **Output:** JSON array, one object per PO, with a `"line_items"` array of per-size rows
- **Date format:** All dates in `DD-MM-YYYY` format
- **Missing fields:** Empty string `""`, never `null`
- **No markdown/explanations** in response — pure JSON only

Header fields are PO-level (repeated for each line item row in the mapper). Line item fields are size/quantity level.

---

## Excel Export Schema (47 Columns)

All exports produce a file named `StandardSalesOrder.xlsx` with these columns (in order):

`Factory`, `Ship Under PO Ref`, `Article`, `Buyer`, `Buyer Division/Dept`, `Currency`, `Season`, `Country of Origin`, `Place of Receipt by Pre-Carrier`, `Prod. Capacity Booking No`, `Order Initiation Date`, `Payment Terms`, `Buyer PO Num`, `Summary Buyer Order Ref`, `Market Buyer Order Ref`, `Destination Buyer Order Ref`, `Delivery Buyer Order Ref`, `Buyer Order Date`, `Order Type`, `Mode of Shipment`, `Buyer Delivery Date`, `OC Delivery Date`, `PCD Date`, `Original GAC Date`, `GAC Date`, `Raw Material ETA`, `Country of Final Destination`, `Final Destination`, `Market`, `Buyer Style Ref.`, `Packing Type`, `Packing Option/Flat Pack`, `Color`, `Size`, `Total Qty`, `Price`, `Units`, `Delivery Terms`, `Zone`, `Internal Lot No.`, `Buyer Lot No.`, `DeliveryOCID`, `Fulfillment Type`, `Initial PCD Date`, `FirstBuyerDeliveryDate`, `Packing Code(SKU)`, `Make to Stock`, `Split`, `Other Instruction`

Columns at positions 1, 12, 13, 14, 15, 16 (0-indexed) are styled as numbers with format `"0"` in Excel.
Header row style: blue background (`4472C4`), white bold text, centered.

---

## Frontend Architecture

The frontend is a **React SPA embedded in Rails ERB views**. Rails renders a thin HTML shell with a `<div id="react-app" data-page="...">` mount point, and `application.js` bootstraps the correct React page component.

### Pages
- **`LoginPage`** (`/login`) — email/password form, calls `POST /login` JSON
- **`HomePage`** (`/`) — document list, upload, filters, pagination, bulk export
- **`ShowPage`** (`/documents/:id`) — document detail, extracted data table, export

### Key Components
- `DocumentsList` — table with checkboxes for bulk selection, status badges, action buttons
- `FileUpload` — modal with drag-and-drop PDF upload
- `ExtractedDataTable` — paginated table (50 rows/page) showing all 47 columns
- `DocumentFilters` — status + buyer dropdowns + search input
- `DocumentSummary` — metadata card on show page
- `StatusBadge` — colored pill for pending/processing/completed/failed
- `RenameModal`, `DeleteConfirmModal` — confirmation modals

### Auto-refresh
- **HomePage:** polls `loadDocuments` every **5 seconds** if any doc is `pending` or `processing`
- **ShowPage:** polls `loadDocument` every **3 seconds** if document is `pending` or `processing`

### API Layer (`app/javascript/utils/api.js`)
All calls include CSRF token from `<meta name="csrf-token">`. JSON responses for data, `blob` for Excel downloads. `downloadBlob()` helper creates a temporary object URL and triggers download.

---

## Routes

```
GET    /                              → documents#index (HTML)
GET    /documents.json                → documents#index (JSON, supports ?page, ?status, ?buyer, ?search)
GET    /documents/:id.json            → documents#show (JSON)
POST   /documents                     → documents#create (single file, multipart form)
POST   /documents/batch               → documents#batch (1–5 files, multipart form with files[])
PUT    /documents/:id                 → documents#update (name only)
DELETE /documents/:id                 → documents#destroy
POST   /documents/:id/retry           → documents#retry
GET    /documents/:id/download_original → documents#download_original (redirect to blob)
GET    /documents/:id/export          → documents#export (Excel download)
GET    /documents/export_all          → documents#export_all (Excel download)
GET    /documents/export_all_summary.json → documents#export_all_summary
POST   /documents/export_selected     → documents#export_selected (body: { document_ids: [...] })

GET    /login                         → sessions#new
POST   /login                         → sessions#create
DELETE /logout                        → sessions#destroy
```

---

## Authentication

- Custom session-based auth (no Devise)
- `ApplicationController` runs `before_action :require_authentication` globally
- JSON requests skip CSRF token verification (`skip_before_action :verify_authenticity_token, if: -> { request.format.json? }`)
- `SessionsController` skips auth check on `new` and `create` actions
- User accounts created via `db/seeds.rb`

---

## File Validation

`FileValidatable` concern (included in `Document`):
- Allowed types: `application/pdf`, `image/jpeg`, `image/png`, `image/jpg`
- Max size: **10MB**

---

## Environment Variables

| Variable | Purpose |
|---|---|
| `GOOGLE_GEMINI_API_KEY` | Google Gemini API key for OCR extraction |

Set in `.env` (loaded via `dotenv` gem). The `.env` file contains multiple commented-out keys — only the uncommented one is active.

---

## Background Job Configuration

- Adapter: `:async` (in-process) for development, Solid Queue for production
- `DocumentProcessingJob` retries up to **3 times** on `StandardError`
- Recurring job in production: clears finished Solid Queue jobs every hour at :12

---

## Known Patterns & Gotchas

1. **Tempfile lifecycle:** `PdfSplittingService` stores Tempfile references in `batch[:tempfiles]` to prevent premature GC. Cleanup happens explicitly after all batches process via `cleanup_split_files`.

2. **Bestseller buyer disambiguation:** Both Bestseller variants use "Bestseller" in text. The distinction is:
   - `bestseller` → "Order no" present
   - `bestseller_domestic` → "PO number" present
   Detection order in `DETECTION_PATTERNS` matters — `bestseller` is checked before `bestseller_domestic`.

3. **Gemini JSON stripping:** Gemini sometimes wraps JSON in markdown code fences. The service strips leading `` ```json `` and trailing `` ``` `` before parsing.

4. **`total_pos` tracking:** Only populated when `extraction_method == "gemini_split"`. Single-batch documents don't set `total_pos` in `extracted_data` (it returns `0` via `total_pos_count`).

5. **Sleep between batches:** A `sleep(1)` is inserted between batch Gemini requests to avoid rate limiting.

6. **Queue adapter is `:async` in dev/test:** Jobs run in-process threads. No separate worker process needed for local development.

7. **React routing is fake:** Navigation between pages is done by changing `window.location.href` (see `utils/navigation.js`), not React Router. The Rails server renders each page's HTML shell.

8. **Multi-file upload uses `POST /documents/batch` with `files[]`:** The frontend sends all files as a multipart array. The backend creates one `Document` per file under a shared `batch_upload_id` UUID. Limit is 5 files per batch, enforced on both frontend and backend.

9. **OCR jobs run on a dedicated `ocr` queue with `threads: 1`:** This ensures sequential processing and prevents multiple simultaneous Gemini calls from saturating Puma's thread pool. The `default` queue (3 threads) handles everything else.

10. **`handle_export_error` lives in `ExportErrorHandler` concern** (`app/controllers/concerns/export_error_handler.rb`), included in `DocumentsController`. It logs the error and renders a 500 JSON response (with error details in development only).

---

## Local Development

```bash
bundle install
yarn install   # or npm install
bin/rails db:create db:migrate db:seed
bin/dev        # starts Rails + JS bundler via Procfile.dev
```

`Procfile.dev`:
```
web: bin/rails server
js: yarn build --watch
```

Set `GOOGLE_GEMINI_API_KEY` in `.env` before processing documents.

---

## Deployment

Uses **Kamal** (Docker-based). Config in `config/deploy.yml` and `.kamal/`. Production serves via Puma + Thruster (HTTP caching/compression layer).
