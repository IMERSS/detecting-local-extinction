const betaMarkup =
    `<div class="beta-inner">
        <h1 class="beta-title">Beta Distribution</h1>
        <div class="beta-subtitle">Probability Density Function (PDF) with α-β parametrization</div>
        <div class="beta-controls">
            <div class="beta-slider-group">
                <label class="beta-label" htmlFor="beta-alpha">α (alpha):</label>
                <div class="beta-slider-container">
                    <input type="range" class="beta-slider" id="beta-alpha" min="0.01" max="10" step="0.01" value="@{alpha}">
                    <span class="beta-value-display" id="beta-alpha-value">@{alpha}</span>
                </div>
            </div>
            <div class="beta-slider-group">
                <label class="beta-label" htmlFor="beta-beta">β (beta):</label>
                <div class="beta-slider-container">
                    <input type="range" class="beta-slider" id="beta-beta" min="0.01" max="10" step="0.01" value="@{beta}">
                    <span class="beta-value-display" id="beta-beta-value">@{beta}</span>
                </div>
            </div>
        </div>
        <div class="beta-plot" id="beta-plot"></div>
        <div class="beta-stats">
            <div class="beta-stat-row">
                <span class="beta-stat-label">Mean:</span>
                <span class="beta-stat-value" id="beta-mean">-</span>
            </div>
            <div class="beta-stat-row">
                <span class="beta-stat-label">Variance:</span>
                <span class="beta-stat-value" id="beta-variance">-</span>
            </div>
            <div class="beta-stat-row">
                <span class="beta-stat-label">Mode:</span>
                <span class="beta-stat-value" id="beta-mode">-</span>
            </div>
        </div>
    </div>
`

const atTemplateRE = /@\{((?:.)+?)\}/g;

const stringTemplate = function (template, values) {
    return template.replace(atTemplateRE, (match, key) => {
        return Object.prototype.hasOwnProperty.call(values, key)
            ? String(values[key])
            : "";
    });
};

// Gamma function using Lanczos approximation
function gamma(z) {
    const g = 7;
    const C = [
        0.99999999999980993,
        676.5203681218851,
        -1259.1392167224028,
        771.32342877765313,
        -176.61502916214059,
        12.507343278686905,
        -0.13857109526572012,
        9.9843695780195716e-6,
        1.5056327351493116e-7
    ];
    if (z < 0.5) {
        return Math.PI / (Math.sin(Math.PI * z) * gamma(1 - z));
    }
    z -= 1;
    let x = C[0];
    for (let i = 1; i < g + 2; i++) {
        x += C[i] / (z + i);
    }
    const t = z + g + 0.5;
    return Math.sqrt(2 * Math.PI) * Math.pow(t, z + 0.5) * Math.exp(-t) * x;
}
// Beta function
function betaFunc(a, b) {
    return gamma(a) * gamma(b) / gamma(a + b);
}
// Beta PDF
function betaPDF(x, alpha, beta) {
    if (x <= 0 || x >= 1) return 0;
    return Math.pow(x, alpha - 1) * Math.pow(1 - x, beta - 1) / betaFunc(alpha, beta);
}
// Calculate stats
function calculateStats(alpha, beta) {
    const mean = alpha / (alpha + beta);
    const variance = (alpha * beta) / (Math.pow(alpha + beta, 2) * (alpha + beta + 1));
    let mode;
    if (alpha > 1 && beta > 1) {
        mode = (alpha - 1) / (alpha + beta - 2);
    } else if (alpha <= 1 && beta <= 1) {
        mode = "undefined (U-shaped)";
    } else if (alpha < 1 || beta < 1) {
        mode = "undefined";
    } else {
        mode = "undefined";
    }
    return { mean, variance, mode };
}
// Update plot
function updatePlot() {
    const alpha = parseFloat(document.getElementById("beta-alpha").value);
    const beta = parseFloat(document.getElementById("beta-beta").value);
    // Update value displays
    document.getElementById("beta-alpha-value").textContent = alpha.toFixed(2);
    document.getElementById("beta-beta-value").textContent = beta.toFixed(2);
    // Generate data points
    const x = [];
    const y = [];
    const numPoints = 200;
    for (let i = 0; i <= numPoints; i++) {
        const xi = i / numPoints;
        x.push(xi);
        y.push(betaPDF(xi, alpha, beta));
    }
    // Create plot
    const trace = {
        x: x,
        y: y,
        type: "scatter",
        mode: "lines",
        line: {
            color: "#1f77b4",
            width: 2
        },
        fill: "tozeroy",
        fillcolor: "rgba(31, 119, 180, 0.2)"
    };
    const layout = {
        xaxis: {
            title: "θ",
            range: [0, 1],
            showgrid: true,
            gridcolor: "#e0e0e0",
            zeroline: true,
            zerolinecolor: "#999",
            tickmode: "linear",
            tick0: 0,
            dtick: 0.2
        },
        yaxis: {
            title: "f(θ; α, β)",
            showgrid: true,
            gridcolor: "#e0e0e0",
            zeroline: true,
            zerolinecolor: "#999"
        },
        margin: {
            l: 60,
            r: 30,
            t: 20,
            b: 50
        },
        plot_bgcolor: "#fff",
        paper_bgcolor: "#fff",
        showlegend: false
    };
    const config = {
        responsive: true,
        displayModeBar: false
    };
    Plotly.newPlot("beta-plot", [trace], layout, config);
    // Update stats
    const stats = calculateStats(alpha, beta);
    document.getElementById("beta-mean").textContent = stats.mean.toFixed(3);
    document.getElementById("beta-variance").textContent = stats.variance.toFixed(3);
    document.getElementById("beta-mode").textContent = typeof stats.mode === "number" ? stats.mode.toFixed(3) : "None";
}

window.makeBetaWidget = function (alpha, beta) {
    const options = {alpha, beta};

    const container = document.querySelector(".beta-container");
    container.innerHTML = stringTemplate(betaMarkup, options);

    document.getElementById("beta-alpha").addEventListener("input", updatePlot);
    document.getElementById("beta-beta").addEventListener("input", updatePlot);
    updatePlot();
};
