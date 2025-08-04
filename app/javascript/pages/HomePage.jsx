import React, { useState, useEffect } from 'react';
import DocumentsList from '../components/DocumentsList';
import FileUpload from '../components/FileUpload';
import { documentsAPI, downloadBlob } from '../utils/api';
import { navigateToDocument } from '../utils/navigation';

const HomePage = () => {
  const [documents, setDocuments] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isUploading, setIsUploading] = useState(false);
  const [showUploadModal, setShowUploadModal] = useState(false);
  const [message, setMessage] = useState(null);

  useEffect(() => {
    const hasProcessingDocs = documents.some(doc => doc.status === 'processing' || doc.status === 'pending');
    
    if (hasProcessingDocs) {
      const interval = setInterval(loadDocuments, 5000);
      return () => clearInterval(interval);
    }
  }, [documents]);

  useEffect(() => {
    loadDocuments();
  }, []);

  const loadDocuments = async () => {
    try {
      const response = await documentsAPI.getAll();
      
      if (response.documents) {
        setDocuments(response.documents);
      } else if (Array.isArray(response)) {
        setDocuments(response);
      } else {
        setDocuments([]);
      }
    } catch (error) {
      console.error('Failed to load documents:', error);
      showMessage('error', 'Failed to load documents');
    } finally {
      setIsLoading(false);
    }
  };

  const handleFileUpload = async (files) => {
    setIsUploading(true);
    try {
      await documentsAPI.upload(files);
      showMessage('success', `Successfully uploaded ${files.length} file${files.length !== 1 ? 's' : ''}. Processing started.`);
      setShowUploadModal(false);
      await loadDocuments();
    } catch (error) {
      console.error('Upload failed:', error);
      showMessage('error', 'Upload failed. Please try again.');
    } finally {
      setIsUploading(false);
    }
  };

  const handleView = (documentId) => {
    navigateToDocument(documentId);
  };

  const handleRename = async (documentId, data) => {
    try {
      await documentsAPI.update(documentId, data);
      showMessage('success', 'Document renamed successfully');
      await loadDocuments();
    } catch (error) {
      console.error('Rename failed:', error);
      showMessage('error', 'Failed to rename document');
    }
  };

  const handleDelete = async (documentId) => {
    try {
      await documentsAPI.delete(documentId);
      showMessage('success', 'Document deleted successfully');
      await loadDocuments();
    } catch (error) {
      console.error('Delete failed:', error);
      showMessage('error', 'Failed to delete document');
    }
  };

  const handleExportDocument = async (documentId) => {
    try {
      const blob = await documentsAPI.exportDocument(documentId);
      const document = documents.find(d => d.id === documentId);
      const filename = `${document.name}_export_${new Date().toISOString().slice(0, 10)}.xlsx`;
      downloadBlob(blob, filename);
      showMessage('success', 'Document exported successfully');
    } catch (error) {
      console.error('Export failed:', error);
      showMessage('error', 'Export failed. Please try again.');
    }
  };

  const handleExportAll = async () => {
    try {
      const blob = await documentsAPI.exportAll();
      const filename = `all_purchase_orders_export_${new Date().toISOString().slice(0, 10)}.xlsx`;
      downloadBlob(blob, filename);
      showMessage('success', 'All documents exported successfully');
    } catch (error) {
      console.error('Export all failed:', error);
      showMessage('error', 'Export failed. Please try again.');
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
        <h3>Loading documents...</h3>
      </div>
    );
  }

  return (
    <div className="home-page">
      {/* Header */}
      <div className="page-header">
        <div className="header-content">
          <h1>OCR Document Processor</h1>
        </div>
        <div className="header-actions">
          <button 
            className="btn btn-primary"
            onClick={() => setShowUploadModal(true)}
          >
            Upload Documents
          </button>
          <button 
            className="btn btn-success"
            onClick={handleExportAll}
          >
            Export All
          </button>
        </div>
      </div>

      {/* Messages */}
      {message && (
        <div className={`message message-${message.type}`}>
          <span>{message.text}</span>
          <button className="message-close" onClick={closeMessage}>×</button>
        </div>
      )}

      {/* Documents List */}
      <div className="documents-section">
        <DocumentsList
          documents={documents}
          onView={handleView}
          onRename={handleRename}
          onDelete={handleDelete}
          onExport={handleExportDocument}
        />
      </div>

      {/* Upload Modal */}
      {showUploadModal && (
        <FileUpload
          onUpload={handleFileUpload}
          isUploading={isUploading}
          onClose={() => !isUploading && setShowUploadModal(false)}
        />
      )}
    </div>
  );
};

export default HomePage;
