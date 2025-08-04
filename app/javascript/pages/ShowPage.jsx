import React, { useState, useEffect } from 'react';
import DocumentSummary from '../components/DocumentSummary';
import ExtractedDataTable from '../components/ExtractedDataTable';
import { documentsAPI, downloadBlob } from '../utils/api';
import { navigateToHome } from '../utils/navigation';

const ShowPage = ({ documentId }) => {
  const [document, setDocument] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [message, setMessage] = useState(null);
  const [isExporting, setIsExporting] = useState(false);

  // Auto-refresh if document is still processing
  useEffect(() => {
    if (document && (document.status === 'processing' || document.status === 'pending')) {
      const interval = setInterval(loadDocument, 3000);
      return () => clearInterval(interval);
    }
  }, [document]);

  useEffect(() => {
    loadDocument();
  }, [documentId]);

  const loadDocument = async () => {
    try {
      const data = await documentsAPI.get(documentId);
      setDocument(data);
    } catch (error) {
      console.error('Failed to load document:', error);
      showMessage('error', 'Failed to load document');
    } finally {
      setIsLoading(false);
    }
  };

  const handleBack = () => {
    navigateToHome();
  };

  const handleDownloadOriginal = () => {
    documentsAPI.downloadOriginal(documentId);
  };

  const handleExport = async () => {
    if (!document || document.status !== 'completed') {
      showMessage('error', 'Document is not ready for export');
      return;
    }

    setIsExporting(true);
    try {
      const blob = await documentsAPI.exportDocument(documentId);
      const filename = `${document.name}_export_${new Date().toISOString().slice(0, 10)}.xlsx`;
      downloadBlob(blob, filename);
      showMessage('success', 'Document exported successfully');
    } catch (error) {
      console.error('Export failed:', error);
      showMessage('error', 'Export failed. Please try again.');
    } finally {
      setIsExporting(false);
    }
  };

  const showMessage = (type, text) => {
    setMessage({ type, text });
    setTimeout(() => setMessage(null), 5000);
  };

  const closeMessage = () => {
    setMessage(null);
  };

  if (isLoading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <h3>Loading document...</h3>
      </div>
    );
  }

  if (!document) {
    return (
      <div className="error-container">
        <h3>Document not found</h3>
        <p>The requested document could not be found.</p>
        <button className="btn btn-primary" onClick={handleBack}>
          Back to Documents
        </button>
      </div>
    );
  }

  return (
    <div className="show-page">
      {/* Header */}
      <div className="page-header">
        <div className="header-content">
          <button className="btn btn-secondary" onClick={handleBack}>
            ← Back to Documents
          </button>
        </div>
        
        <div className="header-actions">
          <button 
            className="btn btn-outline"
            onClick={handleDownloadOriginal}
          >
            Download Original
          </button>
          
          {document.status === 'completed' && document.total_line_items > 0 && (
            <button 
              className="btn btn-success"
              onClick={handleExport}
              disabled={isExporting}
            >
              {isExporting ? 'Exporting...' : 'Export Excel'}
            </button>
          )}
        </div>
      </div>

      {/* Messages */}
      {message && (
        <div className={`message message-${message.type}`}>
          <span>{message.text}</span>
          <button className="message-close" onClick={closeMessage}>×</button>
        </div>
      )}

      {/* Document Summary */}
      <DocumentSummary document={document} />

      {/* Processing State */}
      {(document.status === 'processing' || document.status === 'pending') && (
        <div className="processing-state">
          <div className="processing-content">
            <div className="processing-spinner"></div>
            <div className="processing-text">
              <h3>
                {document.status === 'pending' ? 'Queued for Processing' : 'Processing Document'}
              </h3>
              <p>
                {document.status === 'pending' 
                  ? 'Your document is queued and will be processed shortly.'
                  : 'Extracting data from your document. This may take a few minutes.'}
              </p>
              <p className="processing-note">This page will update automatically when complete.</p>
            </div>
          </div>
        </div>
      )}

      {/* Failed State */}
      {document.status === 'failed' && (
        <div className="failed-state">
          <div className="failed-content">
            <div className="failed-icon">⚠️</div>
            <div className="failed-text">
              <h3>Processing Failed</h3>
              <p>We couldn't extract data from this document.</p>
              {document.error_message && (
                <details className="error-details">
                  <summary>Error Details</summary>
                  <pre>{document.error_message}</pre>
                </details>
              )}
              <p>You can try uploading the document again or contact support if the problem persists.</p>
            </div>
          </div>
        </div>
      )}

      {/* Extracted Data */}
      {document.status === 'completed' && (
        <div className="data-display-section">
          {document.total_line_items > 0 ? (
            <ExtractedDataTable 
              data={document.excel_data || []} 
              documentName={document.name}
            />
          ) : (
            <div className="no-data-state">
              <div className="no-data-icon">📄</div>
              <h3>Processing Complete</h3>
              <p>The document was processed successfully, but no purchase order data was found.</p>
              <p>This might happen if the document format is not recognized or contains no structured data.</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default ShowPage;
