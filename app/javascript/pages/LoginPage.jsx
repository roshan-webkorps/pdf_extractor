import React, { useState } from 'react'
import { authAPI } from '../utils/api'

const LoginPage = () => {
  const [formData, setFormData] = useState({
    email_address: '',
    password: ''
  })
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState(null)
  const [showPassword, setShowPassword] = useState(false)

  const handleInputChange = (e) => {
    const { name, value } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: value
    }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setIsLoading(true)
    setError(null)

    try {
      await authAPI.login(formData)
      window.location.href = '/'
    } catch (err) {
      setError('Invalid email or password')
    } finally {
      setIsLoading(false)
    }
  }

  const togglePasswordVisibility = () => {
    setShowPassword(!showPassword)
  }

  return React.createElement('div', { className: 'login-page' },
    React.createElement('div', { className: 'login-container' },
      React.createElement('div', { className: 'login-card' },
        React.createElement('div', { className: 'login-header' },
          React.createElement('h1', {}, 'OCR Document Processor'),
          React.createElement('p', {}, 'Sign in to your account')
        ),
        
        error && React.createElement('div', { className: 'message message-error' },
          React.createElement('span', {}, error),
          React.createElement('button', { 
            onClick: () => setError(null), 
            className: 'message-close' 
          }, '×')
        ),
        
        React.createElement('form', { onSubmit: handleSubmit, className: 'login-form' },
          React.createElement('div', { className: 'form-group' },
            React.createElement('label', { 
              htmlFor: 'email_address', 
              className: 'form-label' 
            }, 'Email Address'),
            React.createElement('input', {
              type: 'email',
              id: 'email_address',
              name: 'email_address',
              value: formData.email_address,
              onChange: handleInputChange,
              placeholder: 'Enter your email address',
              required: true,
              autoFocus: true,
              autoComplete: 'email',
              className: 'form-input',
              disabled: isLoading
            })
          ),
          
          React.createElement('div', { className: 'form-group' },
            React.createElement('label', { 
              htmlFor: 'password', 
              className: 'form-label' 
            }, 'Password'),
            React.createElement('div', { className: 'password-field-container' },
              React.createElement('input', {
                type: showPassword ? 'text' : 'password',
                id: 'password',
                name: 'password',
                value: formData.password,
                onChange: handleInputChange,
                placeholder: 'Enter your password',
                required: true,
                autoComplete: 'current-password',
                className: 'form-input password-input',
                disabled: isLoading
              }),
              React.createElement('button', {
                type: 'button',
                onClick: togglePasswordVisibility,
                className: 'password-toggle-text',
                disabled: isLoading
              }, showPassword ? 'HIDE' : 'SHOW')
            )
          ),
          
          React.createElement('div', { className: 'form-actions' },
            React.createElement('button', {
              type: 'submit',
              className: 'btn btn-primary btn-full',
              disabled: isLoading
            }, isLoading ? 'Signing In...' : 'Sign In')
          )
        )
      )
    )
  )
}

export default LoginPage
