---
title: Kernel validation
description: Insights from metapopulation theory
categories: [Examples, Placeholders]
tags: [test, docs]
weight: 3
---

For detected species, negative-exponential kernels were estimated empirically by regressing the distances of species detections from the position of initial records, against the background of unsuccessful detections. This was done with the brms package (Bürkner, 2017) using Markov Chain Monte Carlo sampling in STAN. Our regression applies the Bernoulli distribution family to the target detection via a modelling function
\(occupancy_i 〜 q .exp( d_i) \) where  is the kernel width, q scales the overall detection rate (not of interest to this analysis) and di is the distance from historical habitat of occupancy observation \(occupancy_i\).

```
## Calibrating

```
