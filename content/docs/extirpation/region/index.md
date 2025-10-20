---
title: Pooling search effort
description: Calculating the posterior distribution for a region
categories: [Examples, Placeholders]
tags: [test, docs]
weight: 2
---

Having arrived at individual values for the beta parameters for each
cell in a region (historical or potential), we then transfer these
into beta parameters for a regional distribution using moment matching:


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
