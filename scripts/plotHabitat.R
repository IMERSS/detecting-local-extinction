# Load required libraries
library(sf)
library(leaflet)
library(geojsonsf)

# Load geometric utilities for dealing with gridded data
source("scripts/geomUtils.R")

# Load core configuration for analysis which sets up coordinate grid frame and taxa of interest
source("scripts/config.R")

# Read in the shapefile
all_habitat <- st_read("Analysis_outputs/Intermediate/allHabitat.shp")

habitatcells <- read.csv("Analysis_outputs/Intermediate/habitatcells.csv")
habitatcells_sf <- assign_cell_geometry_sf(habitatcells, galgrid)

pp_habitat_to_centres <- read.csv("Analysis_outputs/Intermediate/Primula pauciflora_habitat_to_centres.csv")
h2c_sf <- assign_cell_geometry_sf(pp_habitat_to_centres, galgrid)

# Read in the Bellhouse Park polygon from GeoJSON
bellhouse <- geojson_sf("Analysis_inputs/Bellhouse_Park.geojson")

# Ensure both layers use the same coordinate reference system
bellhouse <- st_transform(bellhouse, st_crs(all_habitat))

# Intersect the shapefile polygons with the Bellhouse polygon
habitat_bellhouse <- st_intersection(all_habitat, bellhouse)
habitatcells_bellhouse <- st_intersection(habitatcells_sf, bellhouse)

pp_historical_h2c <- h2c_sf[h2c_sf$assigned_community == 77, ]

# Plot the resulting polygons on a Leaflet map
historicalHabitat <- leaflet() |>
  addTiles() |>
  addPolygons(data = habitat_bellhouse, color = "black", weight = 1, fillColor = "green", fillOpacity = 0.8, group = "Habitat Polygons") |>
  addPolygons(data = habitatcells_bellhouse, color = "black", weight = 1, opacity = 1, fill = FALSE, group = "Habitat Cells") |>
  addPolygons(data = pp_historical_h2c, color = "blue", weight = 1, opacity = 1, fillOpacity = 0.2, group = "Primula pauciflora Historical Habitat") |>
  addPolygons(data = bellhouse, stroke = FALSE, fill = FALSE, group = "Bellhouse Park Boundary") |>
#  addLayersControl(
#    overlayGroups = c("Habitat Polygons", "Habitat Gridded Cells", "Bellhouse Park Boundary"),
#    options = layersControlOptions(collapsed = FALSE)
#  ) |>
  addLegend(
    position = "topright",
    colors = c("green", "black", "blue"),
    labels = c("Habitat Polygons", "Habitat Gridded Cells", "Primula Pauciflora Historical Habitat"),
    opacity = 1,
    title = "Habitat Representation for Primula Pauciflora"
  )

historicalHabitat

# Compute bounding box of pp_habitat_to_centres
potential_bbox <- st_as_sfc(st_bbox(h2c_sf))

# Filter cells with assigned_community == 0
potential_h2c <- h2c_sf[h2c_sf$assigned_community == 0, ]

# Create a second leaflet map showing the bounding box and filtered cells
potentialHabitat <- leaflet() |>
  addTiles() |>
  addPolygons(data = potential_h2c, color = "black", weight = 1, fill = FALSE, opacity = 1, group = "Potential Habitat") |>
  addLegend(
    position = "topright",
    colors = c("black"),
    labels = c("Potential Habitat"),
    opacity = 1,
    title = "Map Legend",
    group = NULL
  )

potentialHabitat
