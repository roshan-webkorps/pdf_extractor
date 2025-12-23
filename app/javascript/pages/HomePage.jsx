// app/javascript/pages/HomePage.jsx
import React, { useState, useEffect } from 'react';
import DocumentsList from '../components/DocumentsList';
import FileUpload from '../components/FileUpload';
import { documentsAPI, downloadBlob } from '../utils/api';
import { navigateToDocument } from '../utils/navigation';
import RenameModal from '../components/RenameModal';
import DeleteConfirmModal from '../components/DeleteConfirmModal';
import DocumentFilters from '../components/DocumentFilters';

const HomePage = () => {
  const [documents, setDocuments] = useState([]);
  const [pagination, setPagination] = useState({
    current_page: 1,
    per_page: 10,
    total_documents: 0,
    total_pages: 1,
    has_previous: false,
    has_next: false
  });
  const [isLoading, setIsLoading] = useState(true);
  const [isUploading, setIsUploading] = useState(false);
  const [showUploadModal, setShowUploadModal] = useState(false);
  const [message, setMessage] = useState(null);
  const [filters, setFilters] = useState({
    status: '',
    buyer: '',
    search: ''
  });
  const [selectedDocuments, setSelectedDocuments] = useState([]);

  useEffect(() => {
    const hasProcessingDocs = documents.some(doc => doc.status === 'processing' || doc.status === 'pending');
    
    if (hasProcessingDocs) {
      const interval = setInterval(() => loadDocuments(pagination.current_page), 5000);
      return () => clearInterval(interval);
    }
  }, [documents, pagination.current_page]);

  useEffect(() => {
    // Read page from URL query parameter
    const urlParams = new URLSearchParams(window.location.search);
    const pageFromUrl = parseInt(urlParams.get('page')) || 1;
    loadDocuments(pageFromUrl);
  }, []);

  useEffect(() => {
    if (isLoading) return; // Don't run on initial load
    loadDocuments(1);
  }, [filters.status, filters.buyer, filters.search]);

  const loadDocuments = async (page = 1) => {
    try {
      // Build query string with filters
      const params = new URLSearchParams();
      if (filters.status) params.append('status', filters.status);
      if (filters.buyer) params.append('buyer', filters.buyer);
      if (filters.search) params.append('search', filters.search);
      
      const response = await documentsAPI.getAll(page, params.toString());
      
      if (response.documents) {
        setDocuments(response.documents);
        if (response.pagination) {
          setPagination(response.pagination);
        }
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
      await loadDocuments(pagination.current_page);
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

  const [renameModal, setRenameModal] = useState(null);

  const handleRename = (document) => {
    setRenameModal(document);
  };

  const handleRenameConfirm = async (newName) => {
    try {
      await documentsAPI.update(renameModal.id, { name: newName });
      showMessage('success', 'Document renamed successfully');
      setRenameModal(null);
      await loadDocuments(pagination.current_page);
    } catch (error) {
      console.error('Rename failed:', error);
      showMessage('error', 'Failed to rename document');
    }
  };

  const handleRenameCancel = () => {
    setRenameModal(null);
  };

  const [deleteModal, setDeleteModal] = useState(null);

  const handleDelete = (document) => {
    setDeleteModal(document);
  };

  const handleDeleteConfirm = async () => {
    try {
      await documentsAPI.delete(deleteModal.id);
      showMessage('success', 'Document deleted successfully');
      setDeleteModal(null);
      
      if (documents.length === 1 && pagination.current_page > 1) {
        await loadDocuments(pagination.current_page - 1);
      } else {
        await loadDocuments(pagination.current_page);
      }
    } catch (error) {
      console.error('Delete failed:', error);
      showMessage('error', 'Failed to delete document');
    }
  };

  const handleDeleteCancel = () => {
    setDeleteModal(null);
  };

  const handleRetry = async (documentId) => {
    try {
      await documentsAPI.retry(documentId);
      showMessage('success', 'Document queued for reprocessing');
      await loadDocuments(pagination.current_page);
    } catch (error) {
      console.error('Retry failed:', error);
      showMessage('error', 'Failed to retry document processing');
    }
  };

  const handleFilterChange = (newFilters) => {
    setFilters(newFilters);
  };
  
  const handleSelectDocument = (documentId) => {
    setSelectedDocuments(prev => {
      if (prev.includes(documentId)) {
        return prev.filter(id => id !== documentId);
      } else {
        return [...prev, documentId];
      }
    });
  };

  const handleSelectAll = () => {
    const exportableDocuments = documents.filter(
      doc => doc.status === 'completed' && doc.total_line_items > 0
    );
    
    if (selectedDocuments.length === exportableDocuments.length) {
      setSelectedDocuments([]);
    } else {
      setSelectedDocuments(exportableDocuments.map(doc => doc.id));
    }
  };

  const handleExportSelected = async () => {
    if (selectedDocuments.length === 0) {
      showMessage('error', 'Please select documents to export');
      return;
    }

    try {
      const blob = await documentsAPI.exportSelected(selectedDocuments);
      const filename = `selected_documents_export_${new Date().toISOString().slice(0, 10)}.xlsx`;
      downloadBlob(blob, filename);
      showMessage('success', `${selectedDocuments.length} document(s) exported successfully`);
      setSelectedDocuments([]);
    } catch (error) {
      console.error('Export selected failed:', error);
      showMessage('error', 'Export failed. Please try again.');
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

  const handlePageChange = (newPage) => {
    // Update URL with page parameter
    const url = new URL(window.location);
    url.searchParams.set('page', newPage);
    window.history.pushState({}, '', url);
    
    loadDocuments(newPage);
    window.scrollTo(0, 0);
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
      {/* Hero Section */}
      <div className="page-hero">
        <div className="page-hero-content">
          <h1>Purchase Orders</h1>
          <div className="hero-actions">
            <button 
              className="btn btn-primary"
              onClick={() => setShowUploadModal(true)}
            >
              Upload Documents
            </button>
            {selectedDocuments.length > 0 ? (
              <button 
                className="btn btn-success"
                onClick={handleExportSelected}
              >
                Export Selected ({selectedDocuments.length})
              </button>
            ) : (
              <button 
                className="btn btn-success"
                onClick={handleExportAll}
              >
                Export All
              </button>
            )}
          </div>
        </div>
      </div>

      <div className="content-wrapper">
        {/* Messages */}
        {message && (
          <div className={`message message-${message.type}`}>
            <span>{message.text}</span>
            <button className="message-close" onClick={closeMessage}>×</button>
          </div>
        )}

        {/* Filters */}
        <DocumentFilters
          filters={filters}
          onFilterChange={handleFilterChange}
        />

        {/* Documents List */}
        <div className="documents-section">
          <DocumentsList
            documents={documents}
            onView={handleView}
            onRename={handleRename}
            onDelete={handleDelete}
            onExport={handleExportDocument}
            onRetry={handleRetry}
            selectedDocuments={selectedDocuments}
            onSelectDocument={handleSelectDocument}
            onSelectAll={handleSelectAll}
          />
        </div>

        {/* Pagination */}
        {pagination.total_pages > 1 && (
          <div className="pagination">
            <button
              onClick={() => handlePageChange(pagination.current_page - 1)}
              disabled={!pagination.has_previous}
              className="pagination-btn"
            >
              Previous
            </button>
            
            {/* Page Numbers */}
            <div className="pagination-pages">
              {Array.from({ length: pagination.total_pages }, (_, i) => i + 1).map((pageNum) => (
                <button
                  key={pageNum}
                  onClick={() => handlePageChange(pageNum)}
                  className={`pagination-page ${pageNum === pagination.current_page ? 'active' : ''}`}
                >
                  {pageNum}
                </button>
              ))}
            </div>
            
            <button
              onClick={() => handlePageChange(pagination.current_page + 1)}
              disabled={!pagination.has_next}
              className="pagination-btn"
            >
              Next
            </button>
          </div>
        )}
      </div>

      {/* Upload Modal */}
      {showUploadModal && (
        <FileUpload
          onUpload={handleFileUpload}
          isUploading={isUploading}
          onClose={() => !isUploading && setShowUploadModal(false)}
        />
      )}

      {/* Rename Modal */}
      {renameModal && (
        <RenameModal
          document={renameModal}
          onConfirm={handleRenameConfirm}
          onCancel={handleRenameCancel}
        />
      )}

      {/* Delete Modal */}
      {deleteModal && (
        <DeleteConfirmModal
          document={deleteModal}
          onConfirm={handleDeleteConfirm}
          onCancel={handleDeleteCancel}
        />
      )}
    </div>
  );
};

export default HomePage;
