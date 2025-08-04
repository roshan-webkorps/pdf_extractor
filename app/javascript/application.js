import React from 'react';
import { createRoot } from 'react-dom/client';
import HomePage from './pages/HomePage';

// Initialize React apps based on page data
document.addEventListener('DOMContentLoaded', () => {
  const reactApp = document.getElementById('react-app');
  
  if (reactApp) {
    const page = reactApp.dataset.page;
    const root = createRoot(reactApp);
    
    switch (page) {
      case 'index':
        root.render(React.createElement(HomePage));
        break;
      default:
        console.error(`Unknown page: ${page}`);
    }
  }
});
