function calculate_solow() {
    const T0 = parseFloat(document.getElementById("solow-t0").value);
    const tn = parseFloat(document.getElementById("solow-tn").value);
    const T = parseFloat(document.getElementById("solow-T").value);
    const n = parseFloat(document.getElementById("solow-n").value);

    // Validate inputs
    if (isNaN(T0) || isNaN(tn) || isNaN(T) || isNaN(n)) {
        showError("Please enter valid numbers for all fields");
        return;
    }

    if (n < 1) {
        showError("Number of observations (n) must be at least 1");
        return;
    }

    if (tn <= T0) {
        showError("Most recent sighting (tₙ) must be after T₀");
        return;
    }

    if (T <= tn) {
        showError("Current time (T) must be after most recent sighting (tₙ)");
        return;
    }

    // Calculate B(t) using Solow (1993) Equation 3
    const numerator = n === 1 ? 1 : n - 1;
    const ratio = (T - T0) / (tn - T0);
    const denominator = n === 1 ? Math.log(ratio) : (Math.pow(ratio, n - 1) - 1);

    if (denominator === 0) {
        showError("Invalid calculation: denominator is zero");
        return;
    }

    const Bt = numerator / denominator;
    const PPt = Bt / (1 + Bt);
    const EPt = 1 - PPt;

    // Display results
    document.getElementById("solow-bt").textContent = Bt.toFixed(2);
    document.getElementById("solow-bt").className = "result-value";

    document.getElementById("solow-pp").textContent = PPt.toFixed(2);
    document.getElementById("solow-pp").className = "result-value";

    document.getElementById("solow-ep").textContent = EPt.toFixed(2);
    document.getElementById("solow-ep").className = "result-value";
}

function showError(message) {
    document.getElementById("solow-bt").textContent = message;
    document.getElementById("solow-bt").className = "result-value error";
    document.getElementById("solow-pp").textContent = "--";
    document.getElementById("solow-ep").textContent = "--";
}

// Add event listeners to all input fields
document.addEventListener("DOMContentLoaded", function() {
    const inputs = ["solow-t0", "solow-tn", "solow-T", "solow-n"];
    inputs.forEach(function(id) {
        const element = document.getElementById(id);
        element.addEventListener("input", calculate_solow);
        element.addEventListener("change", calculate_solow);
    });

    // Calculate on page load
    calculate_solow();
});
