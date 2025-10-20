---
title: Example II
description: ''
date: 2025-06-04
weight: 6
---
<link href="{{< blogdown/postref >}}index_files/pagedtable/css/pagedtable.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/pagedtable/js/pagedtable.js"></script>





Gridded search data are passed for computing regional statistics as the second argument to the ``analyse_accepted`` function in Analyse.R. This data format is explained in the [previous example](../example-i)

This produces posterior regional statistics for extirpation in historical habitat as follows:


``` r
target_stats <- read.csv("Analysis_outputs/Intermediate/Crassula connata_stats.csv")
target_stats_historical <- target_stats %>% dplyr::filter(Population == "CC1")
paged_table(target_stats_historical)
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["cells"],"name":[1],"type":["int"],"align":["right"]},{"label":["searched"],"name":[2],"type":["int"],"align":["right"]},{"label":["pops"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["habitatSearched"],"name":[4],"type":["chr"],"align":["left"]},{"label":["Central"],"name":[5],"type":["chr"],"align":["left"]},{"label":["Low"],"name":[6],"type":["chr"],"align":["left"]},{"label":["High"],"name":[7],"type":["chr"],"align":["left"]},{"label":["alpha"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["beta"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["mu"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["var"],"name":[11],"type":["dbl"],"align":["right"]},{"label":["Population"],"name":[12],"type":["chr"],"align":["left"]},{"label":["target"],"name":[13],"type":["chr"],"align":["left"]},{"label":["prior_ER"],"name":[14],"type":["dbl"],"align":["right"]}],"data":[{"1":"6","2":"6","3":"1","4":"100.0%","5":"95.5%","6":"90.7%","7":"100.0%","8":"1.46","9":"31.07","10":"0.04489118","11":"0.001278722","12":"CC1","13":"Crassula connata","14":"0.59"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

These show the computed parameters of the posterior beta distribution for extirpation expressed in two different forms - the standard (alpha, beta) representation and (mu, var) as parameters for the central estimate for sighting probability and its dispersion. Confidence bands are placed for this at [90.7%, 100.0%].

Here is this posterior distribution graphed out:

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-3-1.png" width="672" />

