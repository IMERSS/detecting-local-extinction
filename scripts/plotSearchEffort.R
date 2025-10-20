library(dplyr)
library(plotly)
library(glue)
library(geojsonio)
library(rjson)

# Utility to plot a choropleth of total accumulated search effort via the `condensed_final_sf` feature produced from
# synthesizeSearchEffort.R

toPlotRaw <- condensed_final_sf

toPlot <- filter(toPlotRaw, toPlotRaw$search_effort != 0)

grid.geojson.json <- geojson_json(toPlot)
grid.geojson <- rjson::fromJSON(grid.geojson.json)

bbox <- st_bbox(toPlotRaw)

map <- plot_ly(height = 800)

# cribbed from https://github.com/dkahle/ggmap/blob/master/R/calc_zoom.r

calc_zoom <- function (bbox) {
  lonlength <- bbox$xmax - bbox$xmin
  latlength <- bbox$ymax - bbox$ymin
  zoomlon <- ceiling(log2(360 * 2/lonlength))
  zoomlat <- ceiling(log2(180 * 2/latlength))
  zoom <- min(zoomlon, zoomlat)
}

map <- map %>% add_trace(
  toPlot,
  type = "choroplethmapbox",

  geojson = grid.geojson,
  locations = toPlot$cell_id,
  z = toPlot$search_effort,
  zmin = 0,
  zmax = 13,
  colorscale = "Viridis",
  featureidkey="properties.cell_id",
  marker=list(
    line=list(width=1),
    opacity=0.7
  )
)
map <- map %>% layout(
  # TODO: This title doesn't display
  legend = list(    title = "Search Effort"),
  mapbox=list(
    style="carto-positron",
    center = list(lon = ((bbox[1] + bbox[3]) / 2), lat = ((bbox[2] + bbox[4]) / 2)),
    zoom = calc_zoom(bbox) - 1.2,
    layers = list(list())
#    layers = list(list(
#      source = feature.geojson,
#      type = "fill", below = "traces", color = "forestgreen", opacity = 0.2))
    # Undocumented passthrough to plotly.js an array of numbers in [west, south, east, north] order
    #"_fitBounds" = list(bounds = bbox),
    # These options are not passed through by ancient plotly constructor
    #bounds = bbox
    #In the docs but doesn't work - can find no examples in the wild
    #bounds = list(west=bbox[1], east=bbox[3], north=bbox[4], south=bbox[2])
  )
)
print(map)
