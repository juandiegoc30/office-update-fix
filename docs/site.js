'use strict';
const copyStatus = document.getElementById('copy-status');
for (const button of document.querySelectorAll('[data-copy]')) {
  const label = button.textContent;
  let resetTimer;
  button.addEventListener('click', async () => {
    clearTimeout(resetTimer);
    try {
      await navigator.clipboard.writeText(button.closest('.command').querySelector('code').textContent);
      button.textContent = button.dataset.success;
      copyStatus.textContent = button.dataset.success;
    } catch {
      copyStatus.textContent = button.dataset.error;
    }
    resetTimer = window.setTimeout(() => { button.textContent = label; }, 1800);
  });
}
const checklist = document.querySelector('[data-checklist]');
if (checklist) {
  const count = checklist.querySelector('[data-check-count]');
  const boxes = [...checklist.querySelectorAll('input[type="checkbox"]')];
  const updateCount = () => { count.textContent = `${boxes.filter(box => box.checked).length} / ${boxes.length} ${count.dataset.word}`; };
  checklist.addEventListener('change', updateCount);
  updateCount();
}
const imageDialog = document.querySelector('.image-dialog');
for (const link of document.querySelectorAll('[data-zoom]')) {
  link.addEventListener('click', event => {
    if (!imageDialog || typeof imageDialog.showModal !== 'function' || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
    event.preventDefault();
    const image = link.querySelector('img');
    const enlarged = imageDialog.querySelector('img');
    enlarged.src = image.src;
    enlarged.alt = image.alt;
    imageDialog.querySelector('p').textContent = link.closest('figure').querySelector('figcaption').textContent;
    imageDialog.showModal();
  });
}
if (imageDialog) {
  imageDialog.addEventListener('click', event => {
    if (event.target !== imageDialog) return;
    const rect = imageDialog.getBoundingClientRect();
    if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) imageDialog.close();
  });
}
const sections = [...document.querySelectorAll('.guide-section')];
const navigation = [...document.querySelectorAll('[data-nav]')];
if (sections.length && 'IntersectionObserver' in window) {
  const visibleSections = new Set();
  const observer = new IntersectionObserver(entries => {
    for (const entry of entries) {
      if (entry.isIntersecting) visibleSections.add(entry.target);
      else visibleSections.delete(entry.target);
    }
    const activeSection = sections.find(section => visibleSections.has(section));
    for (const link of navigation) {
      if (activeSection && link.hash === `#${activeSection.id}`) link.setAttribute('aria-current', 'location');
      else link.removeAttribute('aria-current');
    }
  }, {rootMargin: '-70px 0px -55% 0px', threshold: 0});
  sections.forEach(section => observer.observe(section));
}
