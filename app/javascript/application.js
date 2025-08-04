import React from 'react'
import { createRoot } from 'react-dom/client'
import HomePage from './pages/HomePage'
import ShowPage from './pages/ShowPage'
import LoginPage from './pages/LoginPage'

document.addEventListener('DOMContentLoaded', () => {
  const reactApp = document.getElementById('react-app')
  
  if (reactApp) {
    const page = reactApp.dataset.page
    const root = createRoot(reactApp)
    
    switch (page) {
      case 'index':
        root.render(React.createElement(HomePage))
        break
      case 'show':
        const documentId = reactApp.dataset.documentId
        if (documentId) {
          root.render(React.createElement(ShowPage, { documentId: parseInt(documentId) }))
        }
        break
      case 'login':
        root.render(React.createElement(LoginPage))
        break
    }
  }
})
