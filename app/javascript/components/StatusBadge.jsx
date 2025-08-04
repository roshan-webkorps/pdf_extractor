import React from 'react';

const StatusBadge = ({ status, className = '' }) => {
  const getStatusClass = (status) => {
    switch (status) {
      case 'completed':
        return 'status-badge status-completed';
      case 'processing':
        return 'status-badge status-processing';
      case 'failed':
        return 'status-badge status-failed';
      case 'pending':
        return 'status-badge status-pending';
      default:
        return 'status-badge status-unknown';
    }
  };

  const getStatusText = (status) => {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'processing':
        return 'Processing...';
      case 'failed':
        return 'Failed';
      case 'pending':
        return 'Pending';
      default:
        return 'Unknown';
    }
  };

  return (
    <span className={`${getStatusClass(status)} ${className}`}>
      {getStatusText(status)}
    </span>
  );
};

export default StatusBadge;
