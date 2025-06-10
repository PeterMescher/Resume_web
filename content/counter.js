document.addEventListener ('DOMContentLoaded', () => {
  const pagePath = window.location.pathname;
  const apiBaseURL = 'https://api.crc.mescher.net/website_counter';
  const url = `${apiBaseURL}?page_name=${encodeURIComponent(pagePath)}`;

  fetch(url)
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.text();
    })
    .then(count => {
      document.getElementById('visit-count').textContent = count;
    })
    .catch(error => {
      console.error('There was a problem with the fetch operation:', error);
      document.getElementById('visit-count').textContent = 'Error';
    });
  });