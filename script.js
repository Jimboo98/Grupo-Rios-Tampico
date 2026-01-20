const revealables = document.querySelectorAll(
    '.card, .identity-block, .slogan, .section-header, .pill-list, .split, .contact-grid, .media-grid, .video-grid, .book-grid'
);

const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
        if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            observer.unobserve(entry.target);
        }
    });
}, { threshold: 0.2, rootMargin: '0px 0px -10% 0px' });

revealables.forEach((el, idx) => {
    el.classList.add('reveal');
    el.style.transitionDelay = `${idx * 30}ms`;
    observer.observe(el);
});

window.addEventListener('load', () => {
    const heroCopy = document.querySelector('.hero-copy');
    if (heroCopy) {
        heroCopy.classList.add('reveal');
        setTimeout(() => heroCopy.classList.add('visible'), 80);
    }
});

const viewer = document.querySelector('.catalog-viewer');
const viewerFrame = document.querySelector('#catalogFrame');
const viewerBackdrop = viewer?.querySelector('.catalog-viewer__backdrop');
const closeViewer = viewer?.querySelector('.close-viewer');

const openCatalog = (file) => {
    if (!viewer || !viewerFrame || !file) return;
    viewerFrame.src = `${file}#toolbar=0&navpanes=0&scrollbar=0&statusbar=0&view=FitH`;
    viewer.classList.add('visible');
    viewer.setAttribute('aria-hidden', 'false');
    document.body.classList.add('no-scroll');
};

const hideCatalog = () => {
    if (!viewer || !viewerFrame) return;
    viewer.classList.remove('visible');
    viewer.setAttribute('aria-hidden', 'true');
    viewerFrame.src = '';
    document.body.classList.remove('no-scroll');
};

document.querySelectorAll('.open-catalog').forEach((btn) => {
    btn.addEventListener('click', () => {
        const file = btn.dataset.file;
        openCatalog(file);
    });
});

closeViewer?.addEventListener('click', hideCatalog);
viewerBackdrop?.addEventListener('click', hideCatalog);
document.addEventListener('keydown', (evt) => {
    if (evt.key === 'Escape' && viewer?.classList.contains('visible')) {
        hideCatalog();
    }
});
