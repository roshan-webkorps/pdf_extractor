import React, { useState } from 'react';

const ExtractedDataTable = ({ data, documentName }) => {
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(50);
  const [searchTerm, setSearchTerm] = useState('');
  const [sortColumn, setSortColumn] = useState('');
  const [sortDirection, setSortDirection] = useState('asc');

  if (!data || data.length === 0) {
    return (
      <div className="no-data-state">
        <div className="no-data-icon">📊</div>
        <h3>No data extracted</h3>
        <p>This document didn't contain any extractable purchase order data.</p>
      </div>
    );
  }

  // Filter data based on search term
  const filteredData = data.filter(row => {
    const searchLower = searchTerm.toLowerCase();
    return Object.values(row).some(value => 
      value && value.toString().toLowerCase().includes(searchLower)
    );
  });

  // Sort data
  const sortedData = [...filteredData].sort((a, b) => {
    if (!sortColumn) return 0;
    
    const aVal = a[sortColumn] || '';
    const bVal = b[sortColumn] || '';
    
    if (sortDirection === 'asc') {
      return aVal.toString().localeCompare(bVal.toString());
    } else {
      return bVal.toString().localeCompare(aVal.toString());
    }
  });

  // Paginate data
  const totalPages = Math.ceil(sortedData.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedData = sortedData.slice(startIndex, startIndex + itemsPerPage);

  const handleSort = (column) => {
    if (sortColumn === column) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      setSortColumn(column);
      setSortDirection('asc');
    }
  };

  const getSortIcon = (column) => {
    if (sortColumn !== column) return '↕️';
    return sortDirection === 'asc' ? '↑' : '↓';
  };

  // Define the columns we want to display (key ones)
  const displayColumns = [
    { key: 'buyer_po_num', label: 'PO Number' },
    { key: 'buyer', label: 'Buyer' },
    { key: 'ship_under_po_ref', label: 'Material' },
    { key: 'currency', label: 'Currency' },
    { key: 'season', label: 'Season' },
    { key: 'color', label: 'Color' },
    { key: 'size', label: 'Size' },
    { key: 'total_qty', label: 'Quantity' },
    { key: 'price', label: 'Price' },
    { key: 'buyer_order_date', label: 'Order Date' },
    { key: 'buyer_delivery_date', label: 'Delivery Date' }
  ];

  return (
    <div className="extracted-data-table">
      <div className="table-header">
        <div className="table-info">
          <h3>Extracted Data</h3>
          <p>{filteredData.length} of {data.length} line items</p>
        </div>
        
        <div className="table-controls">
          <input
            type="text"
            placeholder="Search data..."
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value);
              setCurrentPage(1);
            }}
            className="search-input"
          />
        </div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              {displayColumns.map(column => (
                <th 
                  key={column.key}
                  onClick={() => handleSort(column.key)}
                  className="sortable-header"
                >
                  <div className="header-content">
                    <span>{column.label}</span>
                    <span className="sort-icon">{getSortIcon(column.key)}</span>
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {paginatedData.map((row, index) => (
              <tr key={startIndex + index}>
                {displayColumns.map(column => (
                  <td key={column.key}>
                    <div className="cell-content">
                      {row[column.key] || '-'}
                    </div>
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
