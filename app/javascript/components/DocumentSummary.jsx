import React from 'react';
import StatusBadge from './StatusBadge';

const DocumentSummary = ({ document }) => {
  const formatDate = (dateString) => {
    if (!dateString) return '-';
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const formatFileSize = (bytes) => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  return (
    <div className="document-summary">
      <div className="summary-header">
        <div className="document-title">
          <h2>{document.name}</h2>
          <StatusBadge status={document.status} />
        </div>
        
        {document.original_filename && (
          <div className="original-filename">
            Original file: {document.original_filename}
          </div>
        )}
      </div>

      <div className="summary-grid">
        <div className="summary-item">
          <label>File Size</label>
          <value>{formatFileSize(document.file_size)}</value>
        </div>
        
        <div className="summary-item">
          <label>Uploaded</label>
          <value>{formatDate(document.created_at)}</value>
        </div>
        
        {document.processed_at && (
          <div className="summary-item">
            <label>Processed</label>
            <value>{formatDate(document.processed_at)}</value>
          </div>
        )}
        
        {document.status === 'completed' && (
          <>
            <div className="summary-item">
              <label>Purchase Orders</label>
              <value>{document.total_pos}</value>
            </div>
            
            <div className="summary-item">
              <label>Line Items</label>
              <value>{document.total_line_items}</value>
            </div>
            
            {document.export_summary && (
              <>
                <div className="summary-item">
                  <label>Unique Buyers</label>
                  <value>{document.export_summary.unique_buyers || 0}</value>
                </div>
                
                <div className="summary-item">
                  <label>Total Quantity</label>
                  <value>{document.export_summary.total_quantity || 0}</value>
                </div>
                
                {document.export_summary.currencies && document.export_summary.currencies.length > 0 && (
                  <div className="summary-item">
                    <label>Currencies</label>
                    <value>{document.export_summary.currencies.join(', ')}</value>
                  </div>
                )}
              </>
            )}
          </>
        )}
        
        {document.status === 'failed' && document.error_message && (
          <div className="summary-item error-item">
            <label>Error</label>
            <value>{document.error_message}</value>
          </div>
        )}
      </div>
    </div>
  );
};

export default DocumentSummary;
