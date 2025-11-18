---
title: Example I
description: ''
date: 2025-06-04
math: true
weight: 5
---

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/leaflet/leaflet.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/leaflet/leaflet.js"></script>
<link href="{{< blogdown/postref >}}index_files/leafletfix/leafletfix.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/proj4/proj4.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/Proj4Leaflet/proj4leaflet.js"></script>
<link href="{{< blogdown/postref >}}index_files/rstudio_leaflet/rstudio_leaflet.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/leaflet-binding/leaflet.js"></script>
<script src="{{< blogdown/postref >}}index_files/leaflet-providers/leaflet-providers_1.9.0.js"></script>
<script src="{{< blogdown/postref >}}index_files/leaflet-providers-plugin/leaflet-providers-plugin.js"></script>
<link href="{{< blogdown/postref >}}index_files/pagedtable/css/pagedtable.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/pagedtable/js/pagedtable.js"></script>
<div class="para">The inference process described in the section on <a href="../../extirpation/single_cell">per-cell extirpation</a> has resulted in per-cell parameters $ (\alpha_t, \beta_t) $ for the beta distribution for extirpation from which we can infer a central estimate of extirpation in that cell by computing the mean of the distribution as $ (\alpha_t + \beta_t) / 2$</div>

This map plots this mean per-cell posterior extirpation likelihood for *Primula pauciflora* over its historical habitat covering 9 grid cells in Bellhouse Park.

``` r
prim_accepted_sf <- st_read("Analysis_outputs/Primula pauciflora_Solow_low.shp", quiet=TRUE)
# Filter for region
prim_historical_sf <- prim_accepted_sf %>% dplyr::filter(assgnd_ == 77)
# Convert from mean likelihood of presence to mean likelihood of extirpation
prim_historical_sf$mean_ep <- 1 - prim_historical_sf$mean

pal <- colorNumeric(palette = "viridis", domain = range(c(0, prim_historical_sf$mean_ep), na.rm = TRUE))
m <- leaflet(data = prim_historical_sf) %>%
  # Add a Tiles layer to the map
  addProviderTiles("Esri.WorldImagery") %>%
  # Add the grid layer to the map
  addPolygons(fillColor = ~pal(mean_ep), fillOpacity = 0.8, 
              color = "#BDBDC3", weight = 1) %>%
  # Add a legend
  addLegend(pal = pal, values = c(0, max(prim_historical_sf$mean_ep, na.rm = TRUE)),
            opacity = 0.8, title = "Mean likelihood of extirpation")

# Print the map
m
```

<div id="htmlwidget-1" style="width:672px;height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addProviderTiles","args":["Esri.WorldImagery",null,null,{"errorTileUrl":"","noWrap":false,"detectRetina":false}]},{"method":"addPolygons","args":[[[[{"lng":[-123.3121258329,-123.3121258329,-123.3117168329,-123.3117168329,-123.3121258329],"lat":[48.87259604193872,48.87286504193872,48.87286504193872,48.87259604193872,48.87259604193872]}]],[[{"lng":[-123.3117168329,-123.3117168329,-123.3113078329,-123.3113078329,-123.3117168329],"lat":[48.87259604193872,48.87286504193872,48.87286504193872,48.87259604193872,48.87259604193872]}]],[[{"lng":[-123.3113078329,-123.3113078329,-123.3108988329,-123.3108988329,-123.3113078329],"lat":[48.87259604193872,48.87286504193872,48.87286504193872,48.87259604193872,48.87259604193872]}]],[[{"lng":[-123.3125348329,-123.3125348329,-123.3121258329,-123.3121258329,-123.3125348329],"lat":[48.87232704193872,48.87259604193872,48.87259604193872,48.87232704193872,48.87232704193872]}]],[[{"lng":[-123.3121258329,-123.3121258329,-123.3117168329,-123.3117168329,-123.3121258329],"lat":[48.87232704193872,48.87259604193872,48.87259604193872,48.87232704193872,48.87232704193872]}]],[[{"lng":[-123.3117168329,-123.3117168329,-123.3113078329,-123.3113078329,-123.3117168329],"lat":[48.87232704193872,48.87259604193872,48.87259604193872,48.87232704193872,48.87232704193872]}]],[[{"lng":[-123.3113078329,-123.3113078329,-123.3108988329,-123.3108988329,-123.3113078329],"lat":[48.87232704193872,48.87259604193872,48.87259604193872,48.87232704193872,48.87232704193872]}]],[[{"lng":[-123.3108988329,-123.3108988329,-123.3104898329,-123.3104898329,-123.3108988329],"lat":[48.87232704193872,48.87259604193872,48.87259604193872,48.87232704193872,48.87232704193872]}]],[[{"lng":[-123.3121258329,-123.3121258329,-123.3117168329,-123.3117168329,-123.3121258329],"lat":[48.87205804193872,48.87232704193872,48.87232704193872,48.87205804193872,48.87205804193872]}]]],null,null,{"interactive":true,"className":"","stroke":true,"color":"#BDBDC3","weight":1,"opacity":0.5,"fill":true,"fillColor":["#FDE725","#E6E419","#F3E61E","#F7E621","#FCE724","#D9E319","#D0E11C","#FAE723","#F7E621"],"fillOpacity":0.8,"smoothFactor":1,"noClip":false},null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addLegend","args":[{"colors":["#440154 , #440154 0%, #404588 20.3678637222951%, #297A8E 40.7357274445902%, #25AB82 61.1035911668853%, #83D44C 81.4714548891804%, #FDE725 "],"labels":["0.0","0.2","0.4","0.6","0.8"],"na_color":null,"na_label":"NA","opacity":0.8,"position":"topright","type":"numeric","title":"Mean likelihood of extirpation","extra":{"p_1":0,"p_n":0.8147145488918044},"layerId":null,"className":"info legend","group":null}]}],"limits":{"lat":[48.87205804193872,48.87286504193872],"lng":[-123.3125348329,-123.3104898329]}},"evals":[],"jsHooks":[]}</script>

This gridded search data is then passed for computing regional statistics as the second argument to the `analyse_accepted` function in Analyse.R:

    analyse_accepted(thisTarget, accepted_grouped_merged, habitat_to_centres, exp_weight = exp_weight, solow_prob = solow_low)

Here `exp_weight` is the exponential kernel distance weighting parameter and `solow_prob` is the Solow prior probability of sighting.
This produces posterior regional statistics for extirpation in historical habitat as follows:

``` r
target_stats <- read.csv("Analysis_outputs/Intermediate/Primula pauciflora_stats.csv")
target_stats_historical <- target_stats %>% dplyr::filter(Population == "PP1")
paged_table(target_stats_historical)
```

<div data-pagedtable="false">

<script data-pagedtable-source type="application/json">
{"columns":[{"label":["cells"],"name":[1],"type":["int"],"align":["right"]},{"label":["searched"],"name":[2],"type":["int"],"align":["right"]},{"label":["pops"],"name":[3],"type":["int"],"align":["right"]},{"label":["habitatSearched"],"name":[4],"type":["chr"],"align":["left"]},{"label":["Central"],"name":[5],"type":["chr"],"align":["left"]},{"label":["Low"],"name":[6],"type":["chr"],"align":["left"]},{"label":["High"],"name":[7],"type":["chr"],"align":["left"]},{"label":["alpha"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["beta"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["mu"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["var"],"name":[11],"type":["dbl"],"align":["right"]},{"label":["Population"],"name":[12],"type":["chr"],"align":["left"]},{"label":["target"],"name":[13],"type":["chr"],"align":["left"]},{"label":["prior_ER"],"name":[14],"type":["dbl"],"align":["right"]}],"data":[{"1":"9","2":"9","3":"1","4":"100.0%","5":"95.9%","6":"91.8%","7":"99.9%","8":"1.67","9":"39.43","10":"0.04059659","11":"0.0009252246","12":"PP1","13":"Primula pauciflora","14":"0.46"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>

</div>

These show the computed parameters of the posterior beta distribution for extirpation expressed in two different forms - the standard (alpha, beta) representation and (mu, var) as parameters for the central estimate for sighting probability and its dispersion. Confidence bands are placed for this at \[91.8%, 99.9%\].

Here is this posterior distribution graphed out:

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-4-1.png" width="672" />
