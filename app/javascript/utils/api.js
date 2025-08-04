const API_BASE = '';

const getCsrfToken = () => {
  const token = document.querySelector('meta[name="csrf-token"]');
  return token ? token.content : '';
};

const apiRequest = async (url, options = {}) => {
  const defaultOptions = {
    headers: {
      'X-CSRF-Token': getCsrfToken(),
      ...options.headers,
    },
  };

  if (options.body && typeof options.body === 'string') {
    defaultOptions.headers['Content-Type'] = 'application/json';
  }

  const config = { ...defaultOptions, ...options };
  
  try {
    const response = await fetch(`${API_BASE}${url}`, config);
    
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.error || `HTTP ${response.status}`);
    }
    
    if (response.headers.get('content-type')?.includes('application/vnd.openxmlformats')) {
      return response.blob();
    }
    
    return await response.json();
  } catch (error) {
    console.error('API request failed:', error);
    throw error;
  }
};

export const authAPI = {
  login: async (credentials) => {
    const formData = new FormData();
    formData.append('email_address', credentials.email_address);
    formData.append('password', credentials.password);
    
    try {
      const response = await fetch('/login', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': getCsrfToken(),
          'Accept': 'application/json',
        },
        body: formData,
      });
      
      const responseText = await response.text();
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      return JSON.parse(responseText);
    } catch (error) {
      throw error;
    }
  },
  
  logout: () => {
    return apiRequest('/logout', {
      method: 'DELETE',
    });
  }
};

export const documentsAPI = {
  getAll: () => apiRequest('/documents.json'),
  
  get: (id) => apiRequest(`/documents/${id}.json`),
  
  upload: async (files) => {
    const formData = new FormData();
    
    files.forEach((file) => {
      formData.append('document[file]', file);
      formData.append('document[name]', file.name.replace(/\.[^/.]+$/, ''));
    });
    
    return apiRequest('/documents', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': getCsrfToken(),
      },
      body: formData,
    });
  },
  
  update: (id, data) => apiRequest(`/documents/${id}`, {
    method: 'PUT',
    body: JSON.stringify({ document: data }),
  }),
  
  delete: (id) => apiRequest(`/documents/${id}`, {
    method: 'DELETE',
  }),
  
  downloadOriginal: (id) => {
    window.location.href = `/documents/${id}/download_original`;
  },
  
  exportDocument: async (id) => {
    const blob = await apiRequest(`/documents/${id}/export`);
    return blob;
  },
  
  exportAll: async () => {
    const blob = await apiRequest('/documents/export_all');
    return blob;
  },
  
  getExportSummary: () => apiRequest('/documents/export_all_summary.json'),
};

export const downloadBlob = (blob, filename) => {
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  window.URL.revokeObjectURL(url);
  document.body.removeChild(a);
};
