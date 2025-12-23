import React from 'react';

const DocumentFilters = ({ filters, onFilterChange }) => {
  const handleStatusChange = (e) => {
    onFilterChange({ ...filters, status: e.target.value });
  };

  const handleBuyerChange = (e) => {
    onFilterChange({ ...filters, buyer: e.target.value });
  };

  const handleSearchChange = (e) => {
    onFilterChange({ ...filters, search: e.target.value });
  };

  const handleDateFromChange = (e) => {
    onFilterChange({ ...filters, dateFrom: e.target.value });
  };

  const handleDateToChange = (e) => {
    onFilterChange({ ...filters, dateTo: e.target.value });
  };

  const handleClearFilters = () => {
    onFilterChange({
        status: '',
        buyer: '',
        search: ''
    });
  };

  const hasActiveFilters = filters.status || filters.buyer || filters.search;

  return (
    <div className="filters-container">
      <div className="filters-row">
        {/* Search */}
        <div className="filter-group filter-search">
          <input
            type="text"
            placeholder="Search documents..."
            value={filters.search}
            onChange={handleSearchChange}
            className="filter-input"
          />
        </div>

        {/* Status Filter */}
        <div className="filter-group">
          <select
            value={filters.status}
            onChange={handleStatusChange}
            className="filter-select"
          >
            <option value="">All Status</option>
            <option value="completed">Completed</option>
            <option value="processing">Processing</option>
            <option value="failed">Failed</option>
          </select>
        </div>

        {/* Buyer Filter */}
        <div className="filter-group">
          <select
            value={filters.buyer}
            onChange={handleBuyerChange}
            className="filter-select"
          >
            <option value="">All Buyers</option>
            <option value="levis">Levi Strauss</option>
            <option value="pvh_tommy">PVH Tommy Hilfiger</option>
          </select>
        </div>

        {/* Clear Filters */}
        <button
          onClick={handleClearFilters}
          className="btn btn-secondary btn-small"
          disabled={!hasActiveFilters}
        >
          Clear Filters
        </button>
      </div>
    </div>
  );
};

export default DocumentFilters;
