export const navigateToDocument = (documentId) => {
  window.location.href = `/documents/${documentId}`;
};

export const navigateToHome = () => {
  window.location.href = '/';
};

export const navigateBack = () => {
  if (window.history.length > 1) {
    window.history.back();
  } else {
    navigateToHome();
  }
};
