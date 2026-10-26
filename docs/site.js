'use strict';
for (const button of document.querySelectorAll('[data-copy]')) {
  button.addEventListener('click', async () => {
    const status = document.getElementById('copy-status');
    const label = button.textContent;
    try {
      await navigator.clipboard.writeText(button.previousElementSibling.textContent);
      button.textContent = button.dataset.success;
      status.textContent = button.dataset.success;
      window.setTimeout(() => { button.textContent = label; }, 1800);
    } catch {
      status.textContent = button.dataset.error;
      button.textContent = button.dataset.error;
    }
  });
}
