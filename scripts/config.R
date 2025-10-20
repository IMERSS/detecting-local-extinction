## Core Configuration for synthesis and analysis
## Sets up common parameters such as the grid cell size, grid frame and taxa of interest

## Size of grid cell in m
gridcell <- 30

galianoCoarse <- geojsonsf::geojson_sf("Analysis_inputs/Galiano_Coarse_Boundary.geojson")

cat("Making grid at scale ", gridcell, "m\n")

galgrid <- make_grid_frame(galianoCoarse, gridcell)
cat("Constructed grid with ", galgrid$longcount * galgrid$latcount, " cells\n")

focalTargets <- c("Plagiobothrys tenellus", "Meconella oregana", "Primula pauciflora", "Crassula connata")
detectedTargets <- c("Aquilegia formosa", "Castilleja attenuata", "Lepidium virginicum", "Perideridia gairdneri", "Platanthera unalascensis", "Trifolium dichotomum")
allTargets <- c(focalTargets, detectedTargets)
