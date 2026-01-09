const revealables = document.querySelectorAll('.reference-card, .contact-card');

const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
        if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            observer.unobserve(entry.target);
        }
    });
}, { threshold: 0.15, rootMargin: '0px 0px -10% 0px' });

revealables.forEach((el, idx) => {
    el.classList.add('reveal');
    el.style.transitionDelay = `${idx * 40}ms`;
    observer.observe(el);
});

window.addEventListener('load', () => {
    const heroCopy = document.querySelector('.hero-copy');
    if (heroCopy) {
        heroCopy.classList.add('reveal');
        setTimeout(() => heroCopy.classList.add('visible'), 80);
    }
});
