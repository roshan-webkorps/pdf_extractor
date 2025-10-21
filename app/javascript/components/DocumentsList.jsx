import React from 'react';
import StatusBadge from './StatusBadge';

const DocumentsList = ({ documents, onView, onRename, onDelete, onExport }) => {
  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
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

  const handleRename = (document) => {
    const newName = prompt('Enter new name:', document.name);
    if (newName && newName.trim() && newName !== document.name) {
      onRename(document.id, { name: newName.trim() });
    }
  };

  const handleDelete = (document) => {
    if (confirm(`Are you sure you want to delete "${document.name}"?`)) {
      onDelete(document.id);
    }
  };

  if (documents.length === 0) {
    return (
      <div className="empty-state">
        <div className="empty-state-icon">📄</div>
        <h3>No documents uploaded yet</h3>
        <p>Upload your first document to get started with OCR processing.</p>
      </div>
    );
  }

  return (
    <div className="documents-table-container">
      <table className="documents-table">
        <thead>
          <tr>
            <th>Document</th>
            <th>Buyer</th>
            <th>Status</th>
            <th>Size</th>
            <th>Uploaded</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {documents.map((document) => (
            <tr key={document.id}>
              <td>
                <div className="document-info">
                  <div className="document-name">{document.name}</div>
                  <div className="document-filename">{document.original_filename}</div>
                </div>
              </td>
              <td>
                {document.buyer_display_name ? (
                  <div className="buyer-cell">
                    <span className="buyer-name">{document.buyer_display_name}</span>
                    {document.buyer_detection === 'auto' && (
                      <span className="auto-badge" title="Automatically detected"></span>
                    )}
                  </div>
                ) : (
                  <span className="text-muted">-</span>
                )}
              </td>
              <td>
                <StatusBadge status={document.status} />
                {document.error_message && (
                  <div className="error-message" title={document.error_message}>
                    ⚠️ Error
                  </div>
                )}
              </td>
              <td>{formatFileSize(document.file_size)}</td>
              <td>{formatDate(document.created_at)}</td>
              <td>
                <div className="action-buttons">
                  <button
                    className="btn btn-small"
                    onClick={() => onView(document.id)}
                  >
                    View
                  </button>
                  <button
                    className="btn btn-small btn-secondary"
                    onClick={() => handleRename(document)}
                  >
                    Rename
                  </button>
                  {document.status === 'completed' && document.total_line_items > 0 && (
                    <button
                      className="btn btn-small btn-success"
                      onClick={() => onExport(document.id)}
                    >
                      Export
                    </button>
                  )}
                  <button
                    className="btn btn-small btn-danger"
                    onClick={() => handleDelete(document)}
                  >
                    Delete
                  </button>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default DocumentsList;
