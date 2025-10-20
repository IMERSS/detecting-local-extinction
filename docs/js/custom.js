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
