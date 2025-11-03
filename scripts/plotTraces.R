# Load required libraries
library(sf)
library(dplyr)
library(leaflet)
library(geojsonsf)

# Load geometric utilities for dealing with gridded data
source("scripts/geomUtils.R")

# Load core configuration for analysis which sets up coordinate grid frame and taxa of interest
source("scripts/config.R")

# Read in the Bellhouse Park polygon from GeoJSON
bellhouse <- geojson_sf("Analysis_inputs/Bellhouse_Park.geojson")

obs <- read.csv("Analysis_inputs/Search_Effort/iNaturalist_Observations/all_used_obs.csv")

obs_sf <- st_as_sf(obs, coords=c("long", "lat"))
st_crs(obs_sf) <- "WGS84"

effortsWithUsedObs <- read.csv("Analysis_inputs/Search_Effort/iNaturalist_Observations/efforts_with_used_obs.csv")

allTraces <- read.csv("Analysis_inputs/Search_Effort/Synthesized_Search_Effort_Traces/Combined-Trace.csv")
allTraces_sf <- st_as_sf(allTraces, coords=c("long", "lat"))
st_crs(allTraces_sf) <- "WGS84"

obsTraces <- allTraces_sf %>% semi_join(effortsWithUsedObs, by = "effortId")
bellhouseObsTraces <- st_intersection(obsTraces, bellhouse)

obs_bellhouse <- st_intersection(obs_sf, bellhouse)

# Create a leaflet map of obs in Bellhouse
bellhouseObsMap <- leaflet() |>
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(data = bellhouse, stroke = FALSE, fill = FALSE, weight = 2) |>
  addCircles(
    data = bellhouseObsTraces,
    color = "white",
    fill = FALSE,
    radius = 10,
    weight = 1
  ) |> 
  addMarkers(data = obs_bellhouse) |>
  addLegend(
    position = "bottomright",
    colors = c("white", "#2981CA"),  # black for circles, blue for markers
    labels = c("Interpolated traces", "iNaturalist observations"),
    title = "Legend",
    opacity = 1
  )

bellhouseObsMap

traces_bellhouse <- st_intersection(allTraces_sf, bellhouse)

# Create a leaflet map of all traces
allTracesMap <- leaflet() |>
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(data = bellhouse, stroke = FALSE, fill = FALSE, weight = 2) |>
  addCircles(
    data = traces_bellhouse,
    color = "white",
    fill = FALSE,
    radius = 10,
    weight = 1
  )

allTracesMap

condensed_final_sf <- st_read("Analysis_inputs/Search_Effort/Search_Effort_Density/all.shp")

bellhouse_search_sf <- st_intersection(condensed_final_sf, bellhouse)

pal <- colorNumeric(palette = "viridis", domain = range(c(0, bellhouse_search_sf$srch_ff), na.rm = TRUE))
bellhouseSearchMap <- leaflet(data = bellhouse_search_sf) %>%
  # Add a Tiles layer to the map
  addProviderTiles("Esri.WorldImagery") %>%
  # Add the grid layer to the map
  addPolygons(fillColor = ~pal(srch_ff), fillOpacity = 0.8, 
              color = "#BDBDC3", weight = 1) %>%
  # Add a legend
  addLegend(pal = pal, values = c(0, max(bellhouse_search_sf$srch_ff, na.rm = TRUE)),
            opacity = 0.8, title = "Accumulated Search Effort in ks")

# Print the map
bellhouseSearchMap
