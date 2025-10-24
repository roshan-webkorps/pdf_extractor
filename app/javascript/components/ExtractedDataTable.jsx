import React, { useState } from 'react'

const ExtractedDataTable = ({ data, documentName }) => {
  const [currentPage, setCurrentPage] = useState(1)
  const [itemsPerPage] = useState(50)

  if (!data || data.length === 0) {
    return (
      <div className="no-data-state">
        <div className="no-data-icon">📊</div>
        <h3>No data extracted</h3>
        <p>This document didn't contain any extractable purchase order data.</p>
      </div>
    )
  }

  // Paginate data (no search, no sorting)
  const totalPages = Math.ceil(data.length / itemsPerPage)
  const startIndex = (currentPage - 1) * itemsPerPage
  const paginatedData = data.slice(startIndex, startIndex + itemsPerPage)

  // All 47 columns in the correct order (with # column at the start)
  const allColumns = [
    { key: '#', label: '#', isNumber: true },
    { key: 'factory', label: 'Factory' },
    { key: 'ship_under_po_ref', label: 'Ship Under PO Ref' },
    { key: 'article', label: 'Article' },
    { key: 'buyer', label: 'Buyer' },
    { key: 'buyer_division_dept', label: 'Buyer Division/Dept' },
    { key: 'currency', label: 'Currency' },
    { key: 'season', label: 'Season' },
    { key: 'country_of_origin', label: 'Country of Origin' },
    { key: 'place_of_receipt_by_pre_carrier', label: 'Place of Receipt by Pre-Carrier' },
    { key: 'prod_capacity_booking_no', label: 'Prod. Capacity Booking No' },
    { key: 'order_initiation_date', label: 'Order Initiation Date' },
    { key: 'payment_terms', label: 'Payment Terms' },
    { key: 'buyer_po_num', label: 'Buyer PO Num' },
    { key: 'summary_buyer_order_ref', label: 'Summary Buyer Order Ref' },
    { key: 'market_buyer_order_ref', label: 'Market Buyer Order Ref' },
    { key: 'destination_buyer_order_ref', label: 'Destination Buyer Order Ref' },
    { key: 'delivery_buyer_order_ref', label: 'Delivery Buyer Order Ref' },
    { key: 'buyer_order_date', label: 'Buyer Order Date' },
    { key: 'order_type', label: 'Order Type' },
    { key: 'mode_of_shipment', label: 'Mode of Shipment' },
    { key: 'buyer_delivery_date', label: 'Buyer Delivery Date' },
    { key: 'oc_delivery_date', label: 'OC Delivery Date' },
    { key: 'pcd_date', label: 'PCD Date' },
    { key: 'original_gac_date', label: 'Original GAC Date' },
    { key: 'gac_date', label: 'GAC Date' },
    { key: 'raw_material_eta', label: 'Raw Material ETA' },
    { key: 'country_of_final_destination', label: 'Country of Final Destination' },
    { key: 'final_destination', label: 'Final Destination' },
    { key: 'market', label: 'Market' },
    { key: 'buyer_style_ref', label: 'Buyer Style Ref.' },
    { key: 'packing_type', label: 'Packing Type' },
    { key: 'packing_option_flat_pack', label: 'Packing Option/Flat Pack)' },
    { key: 'color', label: 'Color' },
    { key: 'size', label: 'Size' },
    { key: 'total_qty', label: 'Total Qty' },
    { key: 'price', label: 'Price' },
    { key: 'units', label: 'Units' },
    { key: 'delivery_terms', label: 'Delivery Terms' },
    { key: 'zone', label: 'Zone' },
    { key: 'internal_lot_no', label: 'Internal Lot No.' },
    { key: 'buyer_lot_no', label: 'Buyer Lot No.' },
    { key: 'delivery_ocid', label: 'Delivery OCID' },
    { key: 'fulfillment_type', label: 'Fulfillment Type' },
    { key: 'initial_pcd_date', label: 'Initial PCD Date' },
    { key: 'first_buyer_delivery_date', label: 'First Buyer Delivery Date' },
    { key: 'packing_code', label: 'Packing Code (SKU)' },
    { key: 'make_to_stock', label: 'Make to Stock' },
    { key: 'split', label: 'Split' }
  ]

  return (
    <div className="extracted-data-table">
      <div className="table-header">
        <div className="table-info">
          <h3>Extracted Data</h3>
          <p>{data.length} line items</p>
        </div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              {allColumns.map(column => (
                <th key={column.key} className={column.isNumber ? 'number-column' : ''}>
                  {column.label}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {paginatedData.map((row, index) => (
              <tr key={startIndex + index}>
                {allColumns.map(column => (
                  <td key={column.key} className={column.isNumber ? 'number-column' : ''}>
                    {column.isNumber ? (
                      <div className="cell-content">
                        {startIndex + index + 1}
                      </div>
                    ) : (
                      <div className="cell-content" title={row[column.key] || '-'}>
                        {row[column.key] || '-'}
                      </div>
                    )}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {totalPages > 1 && (
        <div className="pagination">
          <button
            onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
            disabled={currentPage === 1}
            className="pagination-btn"
          >
            Previous
          </button>
          
          <div className="pagination-info">
            Page {currentPage} of {totalPages}
          </div>
          
          <button
            onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
            disabled={currentPage === totalPages}
            className="pagination-btn"
          >
            Next
          </button>
        </div>
      )}
    </div>
  );
};

export default ExtractedDataTable;
