---
title: The beta distribution
math: true
weight: 1
---

## A convenient choice for rapid Bayesian inference

<p>The beta distribution is a convenient choice for representing Bayesian inference on
a probabilistic quantity such as probability of extirpation or probability of sighting.
It is a distribution on the interval \([0, 1]\) which allows us to quickly estimate
these probabilities and also summarise our confidence of these estimates, represented
by how peaked the distribution is around its maximum.
</p>

<p>You can explore the different forms the beta distribution takes by adjusting the
parameters using the sliders below. The initial parameters reflect the posterior
distribution for extirpation that we will derive for <i>Primula pauciflora</i> in all
habitat in the <a href="../../extirpation_potential/example-i/">upcoming example</a> 
(with alpha and beta switched since we are considering probability of extirpation rather
than presence).
</p>

<style>
    .beta-container {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        max-width: 800px;
        margin: 40px auto;
        padding: 20px;
        background: #f9f9f9;
    }
    .beta-inner {
        background: white;
        border-radius: 8px;
        padding: 30px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    .beta-title {
        color: #333;
        font-size: 24px;
        margin-bottom: 10px;
    }
    .beta-subtitle {
        color: #666;
        font-size: 14px;
        margin-bottom: 30px;
    }
    .beta-controls {
        margin-bottom: 30px;
    }
    .beta-slider-group {
        margin-bottom: 25px;
    }
    .beta-label {
        display: block;
        margin-bottom: 8px;
        color: #333;
        font-weight: 500;
        font-size: 14px;
    }
    .beta-slider-container {
        display: flex;
        align-items: center;
        gap: 15px;
    }
    .beta-slider {
        flex: 1;
        height: 6px;
        border-radius: 3px;
        background: #ddd;
        outline: none;
        -webkit-appearance: none;
    }
    .beta-slider::-webkit-slider-thumb {
        -webkit-appearance: none;
        appearance: none;
        width: 18px;
        height: 18px;
        border-radius: 50%;
        background: #4285f4;
        cursor: pointer;
    }
    .beta-slider::-moz-range-thumb {
        width: 18px;
        height: 18px;
        border-radius: 50%;
        background: #4285f4;
        cursor: pointer;
        border: none;
    }
    .beta-value-display {
        min-width: 60px;
        text-align: right;
        font-family: system-ui;
        font-size: 14px;
        color: #333;
    }
    .beta-plot {
        width: 100%;
        height: 400px;
    }
    .beta-stats {
        margin-top: 20px;
        padding: 15px;
        background: #f5f5f5;
        border-radius: 6px;
        font-size: 14px;
    }
    .beta-stat-row {
        display: flex;
        justify-content: space-between;
        margin-bottom: 8px;
        font-family: system-ui;
    }
    .beta-stat-label {
        font-weight: 500;
        color: #555;
    }
    .beta-stat-value {
        font-family: system-ui;
        color: #333;
    }
</style>

<div class="beta-container">
    <div class="beta-inner">
        <h1 class="beta-title">Beta Distribution</h1>
        <div class="beta-subtitle">Probability Density Function (PDF) with α-β parametrization</div>
        <div class="beta-controls">
            <div class="beta-slider-group">
                <label class="beta-label" for="beta-alpha">α (alpha):</label>
                <div class="beta-slider-container">
                    <input type="range" class="beta-slider" id="beta-alpha" min="0.01" max="10" step="0.01" value="5.79">
                    <span class="beta-value-display" id="beta-alpha-value">5.79</span>
                </div>
            </div>
            <div class="beta-slider-group">
                <label class="beta-label" for="beta-beta">β (beta):</label>
                <div class="beta-slider-container">
                    <input type="range" class="beta-slider" id="beta-beta" min="0.01" max="10" step="0.01" value="1.13">
                    <span class="beta-value-display" id="beta-beta-value">1.13</span>
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
</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/plotly.js/2.26.0/plotly.min.js"></script>
<script>
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
        const alpha = parseFloat(document.getElementById('beta-alpha').value);
        const beta = parseFloat(document.getElementById('beta-beta').value);
        // Update value displays
        document.getElementById('beta-alpha-value').textContent = alpha.toFixed(2);
        document.getElementById('beta-beta-value').textContent = beta.toFixed(2);
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
            type: 'scatter',
            mode: 'lines',
            line: {
                color: '#1f77b4',
                width: 2
            },
            fill: 'tozeroy',
            fillcolor: 'rgba(31, 119, 180, 0.2)'
        };
        const layout = {
            xaxis: {
                title: 'θ',
                range: [0, 1],
                showgrid: true,
                gridcolor: '#e0e0e0',
                zeroline: true,
                zerolinecolor: '#999',
                tickmode: 'linear',
                tick0: 0,
                dtick: 0.2
            },
            yaxis: {
                title: 'f(θ; α, β)',
                showgrid: true,
                gridcolor: '#e0e0e0',
                zeroline: true,
                zerolinecolor: '#999'
            },
            margin: {
                l: 60,
                r: 30,
                t: 20,
                b: 50
            },
            plot_bgcolor: '#fff',
            paper_bgcolor: '#fff',
            showlegend: false
        };
        const config = {
            responsive: true,
            displayModeBar: false
        };
        Plotly.newPlot('beta-plot', [trace], layout, config);
        // Update stats
        const stats = calculateStats(alpha, beta);
        document.getElementById('beta-mean').textContent = stats.mean.toFixed(3);
        document.getElementById('beta-variance').textContent = stats.variance.toFixed(3);
        document.getElementById('beta-mode').textContent = typeof stats.mode === 'number' ? stats.mode.toFixed(3) : "None";
    }
    // Event listeners
    document.getElementById('beta-alpha').addEventListener('input', updatePlot);
    document.getElementById('beta-beta').addEventListener('input', updatePlot);
    // Initial plot
    updatePlot();
</script>

<p>
  <a class="btn btn-primary" data-bs-toggle="collapse" href="#collapseExample" role="button" aria-expanded="false" aria-controls="collapseExample">
    Expand for mathematical details
  </a>
</p>
<div class="collapse" id="collapseExample">
  <div class="card card-body">

```R
make_beta <- function (prob, weight) {
  c(prob * weight, (1 - prob) * weight)
}

# Beta distribution statistics from https://en.wikipedia.org/wiki/Beta_distribution
beta_mean <- function (bf) {
  bf$alpha / (bf$alpha + bf$beta)
}

beta_variance <- function (bf) {
  bf$alpha * bf$beta / ((bf$alpha + bf$beta)^2 * (bf$alpha + bf$beta + 1))
}
```

<p>
 We model the probability of a species’ extirpation in a particular area. For consistency with mathematical treatments, we present calculations with a random variable \(θ\)
 encoding the probability of presence in the range \([0, 1]\) and convert to \(1-θ\), the probability of extirpation when we summarise our results. 
 Observations of presence or absence \(y_t\) are governed by a Bernoulli process with parameter \(θ\), where \(p(y_t |θ)=θ\) if \(y_t =1\) represents presence. 
</p>
<p>
Following the notation of Royle and Dorazio (2008), we updated our prior beliefs (prior distribution \(π(θ)\)) using a probabilistic model (likelihood function \(f(y|θ)\)) to derive posterior beliefs (posterior distribution \(π(θ|y)\)). This produces the classical form of Bayes theorem for inference written as:
 $$π(θ|y) ∝ π(θ)f(y|θ)$$ (Equation 1)
</p>
<p>
We modeled the probability of presence by the beta distribution on \([0, 1]\), which is described by two shape parameters \(α\) and \(β\) and takes the form:
                  $$f(y|α,β) ∝ y^{(α-1)} (1-y)^{(β-1)}$$   (Equation 2)
</p>
<p>
This is a convenient choice because, under the Bayesian framework, we can select a conjugate prior within this family, which leads to a posterior distribution in the same family. Given our observations of target species take the form of binary variables (all representing non-detection), these can be placed within a hierarchical Bayesian modeling context where the shape parameters \(α\) and \(β\) represent hyperparameters for our modeled distributions.
</p>
  </div>
</div>
