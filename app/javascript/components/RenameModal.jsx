import React, { useState, useEffect } from 'react';

const RenameModal = ({ document, onConfirm, onCancel }) => {
  const [newName, setNewName] = useState(document.name);

  useEffect(() => {
    setNewName(document.name);
  }, [document]);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (newName.trim() && newName !== document.name) {
      onConfirm(newName.trim());
    }
  };

  return (
    <div className="modal-overlay" onClick={onCancel}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h3>Rename Document</h3>
          <button className="modal-close" onClick={onCancel}>×</button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="modal-body">
            <div className="form-group">
              <label htmlFor="document-name">Document Name</label>
              <input
                type="text"
                id="document-name"
                className="form-input"
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                placeholder="Enter document name"
                autoFocus
                required
              />
              <p className="form-hint">Original file: {document.original_filename}</p>
            </div>
          </div>

          <div className="modal-footer">
            <button type="button" className="btn btn-secondary" onClick={onCancel}>
              Cancel
            </button>
            <button 
              type="submit" 
              className="btn btn-primary"
              disabled={!newName.trim() || newName === document.name}
            >
              Rename
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default RenameModal;
