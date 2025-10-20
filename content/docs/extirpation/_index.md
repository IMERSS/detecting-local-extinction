---
title: Inferring extirpation
description: Updating the posterior based on search effort
math: true
categories: [Examples, Placeholders]
tags: [test, docs]
weight: 6
sidebar:
  open: true
---

After a gridded search effort density dataframe has been assembled,
inference of extirpation risk proceeds in two stages.

In the first stage, we infer an posterior distribution for extirpation
probability for each cell in historical and potential habitat.

In the second stage, these per-cell estimates are pooled into regional
estimates for extirpation, forming quantified proxies for the IUCN
extinction criteria, complete with uncertainty estimates.

At both stages, prior and posterior estimates of extirpation are modelled using 
Bayesian inference on distributions from the beta family.
