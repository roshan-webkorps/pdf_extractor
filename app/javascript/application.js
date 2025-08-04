// app/javascript/application.js
console.log("JavaScript loaded!");

import React from 'react';
import { createRoot } from 'react-dom/client';
import HomePage from './pages/HomePage';
import ShowPage from './pages/ShowPage';

document.addEventListener('DOMContentLoaded', () => {
  console.log("DOM loaded, looking for react-app...");
  
  const reactApp = document.getElementById('react-app');
  
  if (reactApp) {
    console.log("Found react-app element:", reactApp.dataset);
    
    const page = reactApp.dataset.page;
    const root = createRoot(reactApp);
    
    switch (page) {
      case 'index':
        console.log("Rendering HomePage");
        root.render(React.createElement(HomePage));
        break;
      case 'show':
        const documentId = reactApp.dataset.documentId;
        if (documentId) {
          console.log("Rendering ShowPage for document:", documentId);
          root.render(React.createElement(ShowPage, { documentId: parseInt(documentId) }));
        } else {
          console.error('Document ID not found');
        }
        break;
      default:
        console.error(`Unknown page: ${page}`);
    }
  } else {
    console.log("No react-app element found");
  }
});
