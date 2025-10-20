library(geojsonsf)
library(RUnit)

setwd(paste0(dirname(rstudioapi::getActiveDocumentContext()$path), "/../.."))

source("scripts/geomUtils.R")

galiano <- geojsonsf::geojson_sf("Analysis_inputs/Galiano_Coarse_Boundary.geojson")

gridframe <- make_grid_frame(galiano, 30)

bbox <- gridframe$bbox

testCorners <- function () {
    topLeft <- point_to_cell(gridframe, bbox$xmin, bbox$ymax)
    checkEquals(0, topLeft)
    topLeftN <- point_to_cell(gridframe, bbox$xmin + 0.0001, bbox$ymax - 0.0001)
    checkEquals(0, topLeftN)
    topRight <- point_to_cell(gridframe, bbox$xmax, bbox$ymax)
    checkEquals(702, topRight)
}

# Unwrap obnoxious return values from st_touches, st_contains
expect_st <- function (expected, st_value) {
  checkEquals(expected, length(st_value[[1]]))
}

testCell <- function () {
    tl <- st_point(c(bbox$xmin, bbox$ymax))
    tlpoly <- cell_id_to_polygon(gridframe, 0)
    expect_st(1, st_touches(tlpoly, tl))
    
    # Just inside top left point
    tlp <- st_point(c(bbox$xmin + 0.0001, bbox$ymax - 0.0001))
    expect_st(1, st_contains(tlpoly, tlp))
    
    # Just outside top left point
    tlo <- st_point(c(bbox$xmin - 0.0001, bbox$ymax - 0.0001))
    expect_st(0, st_contains(tlpoly, tlo))
    
    # Pick a random polygon, compute its centroid, and check that it looks up to itself
    midPoly = cell_id_to_polygon(gridframe, 5000)
    midCent = st_centroid(midPoly)
    
    midCent_id <- point_to_cell(gridframe, midCent[[1]], midCent[[2]])
    checkEquals(5000, midCent_id)
}

testCorners()
testCell()
