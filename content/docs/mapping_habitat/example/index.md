---
title: Example
description: ''
date: 2025-06-04
weight: 3
---

<link href="{{< blogdown/postref >}}index_files/pagedtable/css/pagedtable.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/pagedtable/js/pagedtable.js"></script>
<link href="{{< blogdown/postref >}}index_files/htmltools-fill/fill.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery-3.6.0.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/leaflet/leaflet.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/leaflet/leaflet.js"></script>
<link href="{{< blogdown/postref >}}index_files/leafletfix/leafletfix.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/proj4/proj4.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/Proj4Leaflet/proj4leaflet.js"></script>
<link href="{{< blogdown/postref >}}index_files/rstudio_leaflet/rstudio_leaflet.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/leaflet-binding/leaflet.js"></script>
<script src="{{< blogdown/postref >}}index_files/leaflet-providers/leaflet-providers_2.0.0.js"></script>
<script src="{{< blogdown/postref >}}index_files/leaflet-providers-plugin/leaflet-providers-plugin.js"></script>
<link href="{{< blogdown/postref >}}index_files/pagedtable/css/pagedtable.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/pagedtable/js/pagedtable.js"></script>
<link href="{{< blogdown/postref >}}index_files/htmltools-fill/fill.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery-3.6.0.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/leaflet/leaflet.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/leaflet/leaflet.js"></script>
<link href="{{< blogdown/postref >}}index_files/leafletfix/leafletfix.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/proj4/proj4.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/Proj4Leaflet/proj4leaflet.js"></script>
<link href="{{< blogdown/postref >}}index_files/rstudio_leaflet/rstudio_leaflet.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/leaflet-binding/leaflet.js"></script>
<script src="{{< blogdown/postref >}}index_files/leaflet-providers/leaflet-providers_2.0.0.js"></script>
<script src="{{< blogdown/postref >}}index_files/leaflet-providers-plugin/leaflet-providers-plugin.js"></script>

Here is an example of an manual override of algorithmic determination of historical habitat, as described in section [historical_habitat](../historical_habitat).

For Crassula connata, whose historical population is determined by
the record at row 46 of [target_plant_records_2024.csv](https://drive.google.com/open?id=1LniufBVQaevxvv3skPWtjfuBvZxkwLMb&usp=drive_copy)
has a coordinateUncertaintyInMeters value of 50:

``` r
plant_records <- read.csv("Analysis_inputs/Occurrences/target_plant_records_2024.csv");
cracon <- plant_records %>% dplyr::filter(scientificName == "Crassula connata")
paged_table(cracon)
```

<div data-pagedtable="false">

<script data-pagedtable-source type="application/json">
{"columns":[{"label":["scientificName"],"name":[1],"type":["chr"],"align":["left"]},{"label":["scientificNameAuthorship"],"name":[2],"type":["chr"],"align":["left"]},{"label":["taxonID"],"name":[3],"type":["int"],"align":["right"]},{"label":["kingdom"],"name":[4],"type":["chr"],"align":["left"]},{"label":["phylum"],"name":[5],"type":["chr"],"align":["left"]},{"label":["class"],"name":[6],"type":["chr"],"align":["left"]},{"label":["order"],"name":[7],"type":["chr"],"align":["left"]},{"label":["suborder"],"name":[8],"type":["lgl"],"align":["right"]},{"label":["infraorder"],"name":[9],"type":["lgl"],"align":["right"]},{"label":["superfamily"],"name":[10],"type":["lgl"],"align":["right"]},{"label":["family"],"name":[11],"type":["chr"],"align":["left"]},{"label":["genus"],"name":[12],"type":["chr"],"align":["left"]},{"label":["subgenus"],"name":[13],"type":["lgl"],"align":["right"]},{"label":["specificEpithet"],"name":[14],"type":["chr"],"align":["left"]},{"label":["infraspecificEpithet"],"name":[15],"type":["chr"],"align":["left"]},{"label":["taxonRank"],"name":[16],"type":["chr"],"align":["left"]},{"label":["institutionCode"],"name":[17],"type":["chr"],"align":["left"]},{"label":["collectionCode"],"name":[18],"type":["lgl"],"align":["right"]},{"label":["catalogNumber"],"name":[19],"type":["chr"],"align":["left"]},{"label":["datasetName"],"name":[20],"type":["chr"],"align":["left"]},{"label":["occurrenceID"],"name":[21],"type":["lgl"],"align":["right"]},{"label":["recordedBy"],"name":[22],"type":["chr"],"align":["left"]},{"label":["recordNumber"],"name":[23],"type":["int"],"align":["right"]},{"label":["fieldNumber"],"name":[24],"type":["lgl"],"align":["right"]},{"label":["eventDate"],"name":[25],"type":["chr"],"align":["left"]},{"label":["year"],"name":[26],"type":["int"],"align":["right"]},{"label":["month"],"name":[27],"type":["int"],"align":["right"]},{"label":["day"],"name":[28],"type":["int"],"align":["right"]},{"label":["basisOfRecord"],"name":[29],"type":["chr"],"align":["left"]},{"label":["locality"],"name":[30],"type":["chr"],"align":["left"]},{"label":["locationRemarks"],"name":[31],"type":["chr"],"align":["left"]},{"label":["island"],"name":[32],"type":["chr"],"align":["left"]},{"label":["stateProvince"],"name":[33],"type":["chr"],"align":["left"]},{"label":["country"],"name":[34],"type":["chr"],"align":["left"]},{"label":["countryCode"],"name":[35],"type":["chr"],"align":["left"]},{"label":["decimalLatitude"],"name":[36],"type":["dbl"],"align":["right"]},{"label":["decimalLongitude"],"name":[37],"type":["dbl"],"align":["right"]},{"label":["coordinateUncertaintyInMeters"],"name":[38],"type":["int"],"align":["right"]},{"label":["georeferencedBy"],"name":[39],"type":["chr"],"align":["left"]},{"label":["georeferenceVerificationStatus"],"name":[40],"type":["chr"],"align":["left"]},{"label":["georeferenceProtocol"],"name":[41],"type":["chr"],"align":["left"]},{"label":["georeferenceRemarks"],"name":[42],"type":["chr"],"align":["left"]},{"label":["habitat"],"name":[43],"type":["chr"],"align":["left"]},{"label":["verbatimDepth"],"name":[44],"type":["lgl"],"align":["right"]},{"label":["verbatimElevation"],"name":[45],"type":["chr"],"align":["left"]},{"label":["occurrenceStatus"],"name":[46],"type":["chr"],"align":["left"]},{"label":["samplingProtocol"],"name":[47],"type":["lgl"],"align":["right"]},{"label":["occurrenceRemarks"],"name":[48],"type":["chr"],"align":["left"]},{"label":["individualCount"],"name":[49],"type":["lgl"],"align":["right"]},{"label":["sex"],"name":[50],"type":["lgl"],"align":["right"]},{"label":["establishmentMeans"],"name":[51],"type":["chr"],"align":["left"]},{"label":["provincialStatus"],"name":[52],"type":["chr"],"align":["left"]},{"label":["nationalStatus"],"name":[53],"type":["chr"],"align":["left"]},{"label":["identifiedBy"],"name":[54],"type":["chr"],"align":["left"]},{"label":["identificationQualifier"],"name":[55],"type":["lgl"],"align":["right"]},{"label":["identificationRemarks"],"name":[56],"type":["chr"],"align":["left"]},{"label":["previousIdentifications"],"name":[57],"type":["lgl"],"align":["right"]},{"label":["bibliographicCitation"],"name":[58],"type":["chr"],"align":["left"]},{"label":["associatedReferences"],"name":[59],"type":["chr"],"align":["left"]}],"data":[{"1":"Crassula connata","2":"(Ruiz & Pav.) A. Berger","3":"57016","4":"Plantae","5":"Tracheophyta","6":"Magnoliopsida","7":"Saxifragales","8":"NA","9":"NA","10":"NA","11":"Crassulaceae","12":"Crassula","13":"NA","14":"connata","15":"","16":"species","17":"V","18":"NA","19":"V129552","20":"","21":"NA","22":"Harvey Janszen","23":"NA","24":"NA","25":"1983-03-27","26":"1983","27":"3","28":"27","29":"PreservedSpecimen","30":"Bellhouse Park","31":"","32":"Galiano Island","33":"British Columbia","34":"Canada","35":"CA","36":"48.87148","37":"-123.311","38":"50","39":"Andrew Simon","40":"50m coordinate uncertainty assigned; conservative estimate for this GPS waypoint, recorded with Garmin GPS and locality verified by Harvey Janszen; margin of uncertainty increased because the waypoint was remapped to the shoreline","41":"Coordinates slightly adjusted; original coordinates proximate but mapped in the ocean","42":"coordinates slightly adjusted to be proximate to original coordinates but on shoreline instead of the ocean; this location is consistent with what Harvey personally described as the collection site","43":"","44":"NA","45":"","46":"present","47":"NA","48":"","49":"NA","50":"NA","51":"native","52":"S2S3 (2019)","53":"","54":"","55":"NA","56":"","57":"NA","58":"Janszen H (2003) Outer Gulf Islands Vascular Plant Checklist. Unpublished species list.","59":"Janszen H (2003) Outer Gulf Islands Vascular Plant Checklist. Unpublished species list."}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>

</div>

Intersecting this with the site classification habitat model would select a set
of 10 30x30 grid cells which have some overlap with this circle:

``` r
cracon_agm_aut <- read.csv("Analysis_outputs/Intermediate/Crassula connata_accepted_grouped_merged_automatic.csv")
cracon_historical_aut <- cracon_agm_aut %>% dplyr::filter(assigned_community == "CC1")
cracon_sf_aut = assign_cell_geometry_sf(cracon_historical_aut, galgrid)

pal <- colorNumeric(palette = "viridis", domain = range(c(0, cracon_sf_aut$search_effort), na.rm = TRUE))
m <- leaflet(data = cracon_sf_aut) %>%
  # Add a Tiles layer to the map
  addProviderTiles("Esri.WorldImagery") %>%
  # Add the grid layer to the map
  addPolygons(fillColor = ~pal(search_effort), fillOpacity = 0.8, 
              color = "#BDBDC3", weight = 1) %>%
  # Add a legend
  addLegend(pal = pal, values = c(0, max(cracon_sf_aut$search_effort, na.rm = TRUE)),
            opacity = 0.8, title = "Accumulated Search Effort in ks")

# Print the map
m
```

<div class="leaflet html-widget html-fill-item" id="htmlwidget-1" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addProviderTiles","args":["Esri.WorldImagery",null,null,{"errorTileUrl":"","noWrap":false,"detectRetina":false}]},{"method":"addPolygons","args":[[[[{"lng":[-123.3117168329,-123.3113078329,-123.3113078329,-123.3117168329,-123.3117168329],"lat":[48.87178904193872,48.87178904193872,48.87205804193872,48.87205804193872,48.87178904193872]}]],[[{"lng":[-123.3113078329,-123.3108988329,-123.3108988329,-123.3113078329,-123.3113078329],"lat":[48.87178904193872,48.87178904193872,48.87205804193872,48.87205804193872,48.87178904193872]}]],[[{"lng":[-123.3108988329,-123.3104898329,-123.3104898329,-123.3108988329,-123.3108988329],"lat":[48.87178904193872,48.87178904193872,48.87205804193872,48.87205804193872,48.87178904193872]}]],[[{"lng":[-123.3117168329,-123.3113078329,-123.3113078329,-123.3117168329,-123.3117168329],"lat":[48.87152004193872,48.87152004193872,48.87178904193873,48.87178904193873,48.87152004193872]}]],[[{"lng":[-123.3113078329,-123.3108988329,-123.3108988329,-123.3113078329,-123.3113078329],"lat":[48.87152004193872,48.87152004193872,48.87178904193873,48.87178904193873,48.87152004193872]}]],[[{"lng":[-123.3108988329,-123.3104898329,-123.3104898329,-123.3108988329,-123.3108988329],"lat":[48.87152004193872,48.87152004193872,48.87178904193873,48.87178904193873,48.87152004193872]}]],[[{"lng":[-123.3121258329,-123.3117168329,-123.3117168329,-123.3121258329,-123.3121258329],"lat":[48.87125104193872,48.87125104193872,48.87152004193872,48.87152004193872,48.87125104193872]}]],[[{"lng":[-123.3117168329,-123.3113078329,-123.3113078329,-123.3117168329,-123.3117168329],"lat":[48.87125104193872,48.87125104193872,48.87152004193872,48.87152004193872,48.87125104193872]}]],[[{"lng":[-123.3113078329,-123.3108988329,-123.3108988329,-123.3113078329,-123.3113078329],"lat":[48.87125104193872,48.87125104193872,48.87152004193872,48.87152004193872,48.87125104193872]}]],[[{"lng":[-123.3108988329,-123.3104898329,-123.3104898329,-123.3108988329,-123.3108988329],"lat":[48.87125104193872,48.87125104193872,48.87152004193872,48.87152004193872,48.87125104193872]}]]],null,null,{"interactive":true,"className":"","stroke":true,"color":"#BDBDC3","weight":1,"opacity":0.5,"fill":true,"fillColor":["#424186","#453681","#25858E","#2A788E","#26828E","#FDE725","#471366","#481B6D","#482576","#481E6F"],"fillOpacity":0.8,"smoothFactor":1,"noClip":false},null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addLegend","args":[{"colors":["#440154 , #440154 0%, #433E85 17.8794706251409%, #2E6E8E 35.7589412502818%, #1F998A 53.6384118754227%, #4BC16D 71.5178825005636%, #B8DE29 89.3973531257045%, #FDE725 "],"labels":["0","1","2","3","4","5"],"na_color":null,"na_label":"NA","opacity":0.8,"position":"topright","type":"numeric","title":"Accumulated Search Effort in ks","extra":{"p_1":0,"p_n":0.8939735312570448},"layerId":null,"className":"info legend","group":null}]}],"limits":{"lat":[48.87125104193872,48.87205804193872],"lng":[-123.3121258329,-123.3104898329]}},"evals":[],"jsHooks":[]}</script>

This includes several grid cells which contextual knowledge indicates do not actually contain valid habitat.
We override them by supplying the following 6 entries in the [historical_habitat.csv](https://drive.google.com/file/d/1DVTOppn58YA-c8Om7hVQo_ehiay73Xp7/view?usp=drive_link) file:

``` r
historical_habitat <- read.csv("Analysis_inputs/Habitat_model/historical_habitat.csv");
hh_cracon <- historical_habitat %>% dplyr::filter(Population == 44)
paged_table(hh_cracon)
```

<div data-pagedtable="false">

<script data-pagedtable-source type="application/json">
{"columns":[{"label":["Population"],"name":[1],"type":["int"],"align":["right"]},{"label":["cell_id"],"name":[2],"type":["int"],"align":["right"]},{"label":["filter_region"],"name":[3],"type":["chr"],"align":["left"]},{"label":["taxon"],"name":[4],"type":["chr"],"align":["left"]}],"data":[{"1":"44","2":"376090","3":"","4":"Crassula connata"},{"1":"44","2":"376091","3":"","4":"Crassula connata"},{"1":"44","2":"376092","3":"","4":"Crassula connata"},{"1":"44","2":"376793","3":"","4":"Crassula connata"},{"1":"44","2":"376794","3":"","4":"Crassula connata"},{"1":"44","2":"376795","3":"","4":"Crassula connata"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>

</div>

With these overrides the appropriate determination of historical habitat appears with 6
cells as follows, and in the [extirpation example](../../extirpation_historical/example-ii):

``` r
cracon_agm <- read.csv("Analysis_outputs/Intermediate/Crassula connata_accepted_grouped_merged.csv")
cracon_historical <- cracon_agm %>% dplyr::filter(assigned_community == "CC1")
cracon_sf = assign_cell_geometry_sf(cracon_historical, galgrid)

pal <- colorNumeric(palette = "viridis", domain = range(c(0, cracon_sf$search_effort), na.rm = TRUE))
m <- leaflet(data = cracon_sf) %>%
  # Add a Tiles layer to the map
  addProviderTiles("Esri.WorldImagery") %>%
  # Add the grid layer to the map
  addPolygons(fillColor = ~pal(search_effort), fillOpacity = 0.8, 
              color = "#BDBDC3", weight = 1) %>%
  # Add a legend
  addLegend(pal = pal, values = c(0, max(cracon_sf$search_effort, na.rm = TRUE)),
            opacity = 0.8, title = "Accumulated Search Effort in ks")

# Print the map
m
```

<div class="leaflet html-widget html-fill-item" id="htmlwidget-2" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-2">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addProviderTiles","args":["Esri.WorldImagery",null,null,{"errorTileUrl":"","noWrap":false,"detectRetina":false}]},{"method":"addPolygons","args":[[[[{"lng":[-123.3117168329,-123.3113078329,-123.3113078329,-123.3117168329,-123.3117168329],"lat":[48.87152004193872,48.87152004193872,48.87178904193873,48.87178904193873,48.87152004193872]}]],[[{"lng":[-123.3113078329,-123.3108988329,-123.3108988329,-123.3113078329,-123.3113078329],"lat":[48.87152004193872,48.87152004193872,48.87178904193873,48.87178904193873,48.87152004193872]}]],[[{"lng":[-123.3108988329,-123.3104898329,-123.3104898329,-123.3108988329,-123.3108988329],"lat":[48.87152004193872,48.87152004193872,48.87178904193873,48.87178904193873,48.87152004193872]}]],[[{"lng":[-123.3117168329,-123.3113078329,-123.3113078329,-123.3117168329,-123.3117168329],"lat":[48.87125104193872,48.87125104193872,48.87152004193872,48.87152004193872,48.87125104193872]}]],[[{"lng":[-123.3113078329,-123.3108988329,-123.3108988329,-123.3113078329,-123.3113078329],"lat":[48.87125104193872,48.87125104193872,48.87152004193872,48.87152004193872,48.87125104193872]}]],[[{"lng":[-123.3108988329,-123.3104898329,-123.3104898329,-123.3108988329,-123.3108988329],"lat":[48.87125104193872,48.87125104193872,48.87152004193872,48.87152004193872,48.87125104193872]}]]],null,null,{"interactive":true,"className":"","stroke":true,"color":"#BDBDC3","weight":1,"opacity":0.5,"fill":true,"fillColor":["#2A788E","#26828E","#FDE725","#481B6D","#482576","#481E6F"],"fillOpacity":0.8,"smoothFactor":1,"noClip":false},null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addLegend","args":[{"colors":["#440154 , #440154 0%, #433E85 17.8794706251409%, #2E6E8E 35.7589412502818%, #1F998A 53.6384118754227%, #4BC16D 71.5178825005636%, #B8DE29 89.3973531257045%, #FDE725 "],"labels":["0","1","2","3","4","5"],"na_color":null,"na_label":"NA","opacity":0.8,"position":"topright","type":"numeric","title":"Accumulated Search Effort in ks","extra":{"p_1":0,"p_n":0.8939735312570448},"layerId":null,"className":"info legend","group":null}]}],"limits":{"lat":[48.87125104193872,48.87178904193873],"lng":[-123.3117168329,-123.3104898329]}},"evals":[],"jsHooks":[]}</script>
