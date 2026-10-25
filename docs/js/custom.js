document.addEventListener("DOMContentLoaded", function () {
    const triggers = [...document.querySelectorAll('[data-bs-toggle="collapse"]')];
    triggers.forEach(trigger => {
        const targetSelector = trigger.getAttribute("href") || trigger.dataset.bsTarget;
        const target = document.querySelector(targetSelector);

        trigger.addEventListener("click", function (event) {
            event.preventDefault();

            const isExpanded = target.classList.contains("show");
            trigger.setAttribute("aria-expanded", !isExpanded);

            if (isExpanded) {
                target.classList.remove("show");
            } else {
                target.classList.add("show");
            }
        });
    });
});



/* Hextra 0.9.x — navbar dropdown interaction
   Place at: assets/js/custom.js  (or static/js/custom.js + add script tag)
   No dependencies. ~40 lines. */

(function () {
    'use strict';

    function initDropdowns() {
        const dropdowns = document.querySelectorAll(".hx-dropdown");

        dropdowns.forEach(function (dropdown) {
            const trigger = dropdown.querySelector(".hx-dropdown-trigger");
            if (!trigger) return;

            // Toggle on click
            trigger.addEventListener('click', function (e) {
                e.stopPropagation();
                e.preventDefault();
                const isOpen = dropdown.classList.contains("is-open");
                closeAll();
                if (!isOpen) open(dropdown, trigger);
            });

            // Keyboard: Enter / Space open; Escape closes
            trigger.addEventListener('keydown', function (e) {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    trigger.click();
                } else if (e.key === 'Escape') {
                    close(dropdown, trigger);
                    trigger.focus();
                }
            });
        });

        // Click outside closes all
        document.addEventListener('click', closeAll);

        // Escape anywhere closes all
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') closeAll();
        });
    }

    function open(dropdown, trigger) {
        dropdown.classList.add('is-open');
        trigger.setAttribute('aria-expanded', 'true');
    }

    function close(dropdown, trigger) {
        dropdown.classList.remove('is-open');
        if (trigger) trigger.setAttribute('aria-expanded', 'false');
    }

    function closeAll() {
        document.querySelectorAll('.hx-dropdown.is-open').forEach(function (d) {
            close(d, d.querySelector('.hx-dropdown-trigger'));
        });
    }

    // Run after DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initDropdowns);
    } else {
        initDropdowns();
    }
})();
