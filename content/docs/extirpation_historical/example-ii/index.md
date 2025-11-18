---
title: Example II
description: ''
date: 2025-06-04
weight: 6
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

Similarly to the previous vignette, this map plots this mean per-cell posterior extirpation likelihood for *Crassula connata* over its historical habitat covering 6 grid cells in Bellhouse Park.

``` r
cracon_accepted_sf <- st_read("Analysis_outputs/Crassula connata_Solow_low.shp", quiet=TRUE)
# Filter for region
cracon_historical_sf <- cracon_accepted_sf %>% dplyr::filter(assgnd_ == 44)
# Convert from mean likelihood of presence to mean likelihood of extirpation
cracon_historical_sf$mean_ep <- 1 - cracon_historical_sf$mean

pal <- colorNumeric(palette = "viridis", domain = range(c(0, cracon_historical_sf$mean_ep), na.rm = TRUE))
m <- leaflet(data = cracon_historical_sf) %>%
  # Add a Tiles layer to the map
  addProviderTiles("Esri.WorldImagery") %>%
  # Add the grid layer to the map
  addPolygons(fillColor = ~pal(mean_ep), fillOpacity = 0.8, 
              color = "#BDBDC3", weight = 1) %>%
  # Add a legend
  addLegend(pal = pal, values = c(0, max(cracon_historical_sf$mean_ep, na.rm = TRUE)),
            opacity = 0.8, title = "Mean likelihood of extirpation")

# Print the map
m
```

<div id="htmlwidget-1" style="width:672px;height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addProviderTiles","args":["Esri.WorldImagery",null,null,{"errorTileUrl":"","noWrap":false,"detectRetina":false}]},{"method":"addPolygons","args":[[[[{"lng":[-123.3117168329,-123.3117168329,-123.3113078329,-123.3113078329,-123.3117168329],"lat":[48.87152004193872,48.87178904193873,48.87178904193873,48.87152004193872,48.87152004193872]}]],[[{"lng":[-123.3113078329,-123.3113078329,-123.3108988329,-123.3108988329,-123.3113078329],"lat":[48.87152004193872,48.87178904193873,48.87178904193873,48.87152004193872,48.87152004193872]}]],[[{"lng":[-123.3108988329,-123.3108988329,-123.3104898329,-123.3104898329,-123.3108988329],"lat":[48.87152004193872,48.87178904193873,48.87178904193873,48.87152004193872,48.87152004193872]}]],[[{"lng":[-123.3117168329,-123.3117168329,-123.3113078329,-123.3113078329,-123.3117168329],"lat":[48.87125104193872,48.87152004193872,48.87152004193872,48.87125104193872,48.87125104193872]}]],[[{"lng":[-123.3113078329,-123.3113078329,-123.3108988329,-123.3108988329,-123.3113078329],"lat":[48.87125104193872,48.87152004193872,48.87152004193872,48.87125104193872,48.87125104193872]}]],[[{"lng":[-123.3108988329,-123.3108988329,-123.3104898329,-123.3104898329,-123.3108988329],"lat":[48.87125104193872,48.87152004193872,48.87152004193872,48.87125104193872,48.87125104193872]}]]],null,null,{"interactive":true,"className":"","stroke":true,"color":"#BDBDC3","weight":1,"opacity":0.5,"fill":true,"fillColor":["#F0E51D","#EFE51C","#FDE725","#DCE318","#E0E318","#E9E51A"],"fillOpacity":0.8,"smoothFactor":1,"noClip":false},null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addLegend","args":[{"colors":["#440154 , #440154 0%, #404588 20.3221604870709%, #297A8E 40.6443209741418%, #24AA83 60.9664814612127%, #82D34C 81.2886419482836%, #FDE725 "],"labels":["0.0","0.2","0.4","0.6","0.8"],"na_color":null,"na_label":"NA","opacity":0.8,"position":"topright","type":"numeric","title":"Mean likelihood of extirpation","extra":{"p_1":0,"p_n":0.8128864194828365},"layerId":null,"className":"info legend","group":null}]}],"limits":{"lat":[48.87125104193872,48.87178904193873],"lng":[-123.3117168329,-123.3104898329]}},"evals":[],"jsHooks":[]}</script>

Gridded search data are passed for computing regional statistics as the second argument to the `analyse_accepted` function in Analyse.R. This data format is explained in the [previous example](../example-i)

This produces posterior regional statistics for extirpation in historical habitat as follows:

``` r
target_stats <- read.csv("Analysis_outputs/Intermediate/Crassula connata_stats.csv")
target_stats_historical <- target_stats %>% dplyr::filter(Population == "CC1")
paged_table(target_stats_historical)
```

<div data-pagedtable="false">

<script data-pagedtable-source type="application/json">
{"columns":[{"label":["cells"],"name":[1],"type":["int"],"align":["right"]},{"label":["searched"],"name":[2],"type":["int"],"align":["right"]},{"label":["pops"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["habitatSearched"],"name":[4],"type":["chr"],"align":["left"]},{"label":["Central"],"name":[5],"type":["chr"],"align":["left"]},{"label":["Low"],"name":[6],"type":["chr"],"align":["left"]},{"label":["High"],"name":[7],"type":["chr"],"align":["left"]},{"label":["alpha"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["beta"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["mu"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["var"],"name":[11],"type":["dbl"],"align":["right"]},{"label":["Population"],"name":[12],"type":["chr"],"align":["left"]},{"label":["target"],"name":[13],"type":["chr"],"align":["left"]},{"label":["prior_ER"],"name":[14],"type":["dbl"],"align":["right"]}],"data":[{"1":"6","2":"6","3":"1","4":"100.0%","5":"95.5%","6":"91.1%","7":"99.8%","8":"1.88","9":"39.93","10":"0.04492573","11":"0.001002404","12":"CC1","13":"Crassula connata","14":"0.47"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>

</div>

These show the computed parameters of the posterior beta distribution for extirpation expressed in two different forms - the standard (alpha, beta) representation and (mu, var) as parameters for the central estimate for sighting probability and its dispersion. Confidence bands are placed for this at \[91.1%, 99.8%\].

Here is this posterior distribution graphed out:

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-4-1.png" width="672" />
