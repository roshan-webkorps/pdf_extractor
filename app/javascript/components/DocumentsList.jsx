import React from 'react';
import StatusBadge from './StatusBadge';

const DocumentsList = ({ documents, onView, onRename, onDelete, onExport, onRetry, selectedDocuments, onSelectDocument, onSelectAll }) => {
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
    onRename(document);
  };

  const handleDelete = (document) => {
    onDelete(document);
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
            <th className="checkbox-column">
              <input
                type="checkbox"
                checked={
                  documents.filter(d => d.status === 'completed' && d.total_line_items > 0).length > 0 &&
                  selectedDocuments.length === documents.filter(d => d.status === 'completed' && d.total_line_items > 0).length
                }
                onChange={onSelectAll}
                className="document-checkbox"
              />
            </th>
            <th>Document</th>
            <th>Buyer</th>
            <th>Status</th>
            <th>Size</th>
            <th>Total Pages</th>
            <th>Uploaded</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {documents.map((document) => (
            <tr key={document.id} className={selectedDocuments.includes(document.id) ? 'row-selected' : ''}>
              <td className="checkbox-column">
                {document.status === 'completed' && document.total_line_items > 0 ? (
                  <input
                    type="checkbox"
                    checked={selectedDocuments.includes(document.id)}
                    onChange={() => onSelectDocument(document.id)}
                    className="document-checkbox"
                    onClick={(e) => e.stopPropagation()}
                  />
                ) : null}
              </td>
              <td>
                <div className="document-info">
                  <div 
                    className="document-name document-name-link" 
                    onClick={() => onView(document.id)}
                  >
                    {document.name}
                  </div>
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
                  </div>
                )}
              </td>
              <td>{formatFileSize(document.file_size)}</td>
              <td className="page_count">{document.page_count}</td>
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
                  {document.status === 'failed' && (
                    <button
                      className="btn btn-small btn-warning"
                      onClick={() => onRetry(document.id)}
                    >
                      Retry
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
