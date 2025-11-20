source("R/site_globals.R")
source("scripts/geomUtils.R")
source("scripts/config.R")
library(leaflet)
library(rmarkdown)
library(dplyr)
library(ggplot2)

prim_agm <- read.csv("Analysis_outputs/Intermediate/Primula pauciflora_accepted_grouped_merged.csv")
prim_historical <- prim_agm %>% dplyr::filter(assigned_community == "PP1")
prim_sf = assign_cell_geometry_sf(prim_historical, galgrid)
prim_sf$scaled_se = prim_sf$search_effort / prim_sf$area_prop

eps <- 1e-6

f_transform <- function(x, eps = 1e-6) log(0.3 + log(x + eps))
f_inverse   <- function(y) exp(exp(y) - 0.3)

min_val <- min(c(prim_sf$search_effort, prim_sf$scaled_se), na.rm = TRUE)
max_val <- max(c(prim_sf$search_effort, prim_sf$scaled_se), na.rm = TRUE)

domain_trans <- f_transform(c(min_val, max_val))

pal <- colorNumeric(
  palette = "viridis",
  domain = domain_trans
)

m <- leaflet(data = prim_sf) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(
    fillColor = ~pal(f_transform(search_effort)),
    fillOpacity = 0.8,
    color = "#BDBDC3",
    weight = 1
  ) %>%
  addLegend(
    pal = pal,
    values = domain_trans,
    labFormat = leaflet::labelFormat(
      transform = function(y) f_inverse(y),
      digits = 2
    ),
    opacity = 0.8,
    title = "Accumulated Search Effort (ks)"
  )

m

m <- leaflet(data = prim_sf) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(
    fillColor = ~pal(f_transform(scaled_se)),
    fillOpacity = 0.8,
    color = "#BDBDC3",
    weight = 1
  ) %>%
  addLegend(
    pal = pal,
    values = domain_trans,
    labFormat = leaflet::labelFormat(
      transform = function(y) f_inverse(y),
      digits = 2
    ),
    opacity = 0.8,
    title = "Accumulated Search Effort (ks)"
  )

m


cracon_agm <- read.csv("Analysis_outputs/Intermediate/Crassula connata_accepted_grouped_merged.csv")
cracon_historical <- cracon_agm %>% dplyr::filter(assigned_community == "CC1")
cracon_sf = assign_cell_geometry_sf(cracon_historical, galgrid)

cracon_sf$scaled_se = cracon_sf$search_effort / cracon_sf$area_prop

eps <- 1e-6

# Scale legend palette for legibility

f_transform <- function(x, eps = 1e-6) {
  log(1 + log(x + eps))
}

f_inverse <- function(y) {
  exp(exp(y) -1)
}

min_val <- min(c(cracon_sf$search_effort, cracon_sf$scaled_se), na.rm = TRUE)
max_val <- max(c(cracon_sf$search_effort, cracon_sf$scaled_se), na.rm = TRUE)

domain_trans <- f_transform(c(min_val, max_val))

pal <- colorNumeric(
  palette = "viridis",
  domain = domain_trans
)

m <- leaflet(data = cracon_sf) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(
    fillColor = ~pal(f_transform(search_effort)),
    fillOpacity = 0.8,
    color = "#BDBDC3",
    weight = 1
  ) %>%
  addLegend(
    pal = pal,
    values = domain_trans,
    labFormat = leaflet::labelFormat(
      transform = function(y) f_inverse(y),
      digits = 2
    ),
    opacity = 0.8,
    title = "Accumulated Search Effort in ks"
  )

m

m <- leaflet(data = cracon_sf) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(
    fillColor = ~pal(f_transform(scaled_se)),
    fillOpacity = 0.8,
    color = "#BDBDC3",
    weight = 1
  ) %>%
  addLegend(
    pal = pal,
    values = domain_trans,
    labFormat = leaflet::labelFormat(
      transform = function(y) f_inverse(y),
      digits = 2
    ),
    opacity = 0.8,
    title = "Accumulated Search Effort in ks"
  )

m
