---
title: Pooling search effort
description: Calculating the posterior distribution for a region
math: true
weight: 4
---

<p>Once we have values for \( \alpha \) and \( \beta \) for each individual cell, we combine them into a single regional distribution. Instead of averaging the raw values directly, we match the statistical moments of the regional data to those of a beta distribution. This gives us new regional \( \alpha \) and \( \beta \) values that reflect both the overall mean and the uncertainty across all cells.</p>

<p>
  <a class="btn btn-primary" data-bs-toggle="collapse" href="#collapseExample" role="button" aria-expanded="false" aria-controls="collapseExample">
    Expand for mathematical details
  </a>
</p>
<div class="collapse" id="collapseExample">
  <div class="card card-body">



<p>
Having arrived at individual values \(  (\alpha_t, \beta_t) \) for the beta parameters for each
cell in a region (historical or potential), we then transfer these
into beta parameters for a regional distribution using moment matching:
</p>

```R
# Compute beta parameters given moments
# Taken from https://stats.stackexchange.com/a/12239
beta_params_from_moments <- function (mu, var) {
  alpha <- ((1 - mu) / var - 1 / mu) * mu ^ 2
  beta <- alpha * (1 / mu - 1)
  return (params = list(alpha = alpha, beta = beta))
}

apply_region_moments <- function (stats, mu, var) {
  params <- beta_params_from_moments(mu, var)
  
  hdi <- hdiBeta(params$alpha, params$beta, p = 0.9)
  fields <- list(Central = rp(1 - mu), Low = rp(1 - hdi[2]), High = rp(1 - hdi[1]),
      alpha = rv(params$alpha), beta = rv(params$beta), mu = mu, var = var)
  modifyList(stats, fields)
}

```
</div>
</div>
