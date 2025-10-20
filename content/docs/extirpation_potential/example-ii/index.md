---
title: Example II
description: ''
date: 2025-06-04
weight: 5
---
<link href="{{< blogdown/postref >}}index_files/pagedtable/css/pagedtable.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/pagedtable/js/pagedtable.js"></script>





...
This produces posterior regional statistics for extirpation across all habitat as follows:

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["cells"],"name":[1],"type":["int"],"align":["right"]},{"label":["searched"],"name":[2],"type":["int"],"align":["right"]},{"label":["pops"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["habitatSearched"],"name":[4],"type":["chr"],"align":["left"]},{"label":["Central"],"name":[5],"type":["chr"],"align":["left"]},{"label":["Low"],"name":[6],"type":["chr"],"align":["left"]},{"label":["High"],"name":[7],"type":["chr"],"align":["left"]},{"label":["alpha"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["beta"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["mu"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["var"],"name":[11],"type":["dbl"],"align":["right"]},{"label":["Population"],"name":[12],"type":["chr"],"align":["left"]},{"label":["target"],"name":[13],"type":["chr"],"align":["left"]},{"label":["prior_ER"],"name":[14],"type":["dbl"],"align":["right"]}],"data":[{"1":"4067","2":"628","3":"69.04","4":"15.4%","5":"90.9%","6":"76.7%","7":"100.0%","8":"0.64","9":"6.33","10":"0.09139901","11":"0.01041984","12":"all","13":"Crassula connata","14":"0.59"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

These show the computed parameters of the posterior beta distribution for extirpation expressed in two different forms - the standard (alpha, beta) representation and (mu, var) as parameters for the central estimate for sighting probability and its dispersion. Confidence bands are placed for this at [76.7%, 100.0%].

Here is this posterior distribution graphed out - whilst the most probable extirpation value is 100% because of the folded nature of the beta distribution, this is a more dispersed distribution than that for historical habitat and the central estimate of extirpation probability is 90.9%.

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-3-1.png" width="672" />

