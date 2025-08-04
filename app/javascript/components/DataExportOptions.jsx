import React, { useState } from 'react';

const DataExportOptions = ({ document, onExport }) => {
  const [isExporting, setIsExporting] = useState(false);

  if (!document || document.status !== 'completed' || !document.total_line_items) {
    return null;
  }

  const handleExport = async () => {
    setIsExporting(true);
    try {
      await onExport();
    } finally {
      setIsExporting(false);
    }
  };

  const summary = document.export_summary || {};

  return (
    <div className="data-export-options">
      <div className="export-header">
        <h3>Export Data</h3>
        <p>Download the extracted data as an Excel spreadsheet</p>
      </div>
      
      <div className="export-summary">
        <div className="export-stats">
          <div className="export-stat">
            <span className="stat-value">{document.total_line_items}</span>
            <span className="stat-label">Line Items</span>
          </div>
          
          {summary.unique_pos && (
            <div className="export-stat">
              <span className="stat-value">{summary.unique_pos}</span>
              <span className="stat-label">Purchase Orders</span>
            </div>
          )}
          
          {summary.unique_buyers && (
            <div className="export-stat">
              <span className="stat-value">{summary.unique_buyers}</span>
              <span className="stat-label">Unique Buyers</span>
            </div>
          )}
          
          {summary.total_quantity && (
            <div className="export-stat">
              <span className="stat-value">{summary.total_quantity.toLocaleString()}</span>
              <span className="stat-label">Total Quantity</span>
            </div>
          )}
        </div>
        
        <button 
          className="btn btn-success btn-large"
          onClick={handleExport}
          disabled={isExporting}
        >
          {isExporting ? 'Generating Export...' : 'Download Excel File'}
        </button>
      </div>
    </div>
  );
};

export default DataExportOptions;
