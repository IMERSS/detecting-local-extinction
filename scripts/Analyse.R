# 2024-09-16
# Antranig Basman

library(sf)
library(geojsonsf)
library(tidyverse)
library(readxl)
library(stringr)
library(viridis)
library(scales)
library(HDInterval)

# Before running this script, run fetchMaterials.R to fetch Analysis_inputs from the project's Google Drive folder

# Principal output is the table of inferred extinction probabilities in Analysis_outputs/extirpation_statistics.csv
# This will contain an entry for every taxon configured in config.R focalTargets

# Additional output: Analysis_outputs/search_effort_phenology.csv which contains phenological data sourcing Table 1
# in the main paper

# Other functions dump various other figures, tables and statistics referred to in the paper and supplementary materials

# Set relative paths (https://stackoverflow.com/questions/13672720/r-command-for-setting-working-directory-to-source-file-location-in-rstudio)
setwd(paste0(dirname(rstudioapi::getActiveDocumentContext()$path), "/.."))

# Load geometric utilities for dealing with gridded data
source("scripts/geomUtils.R")

# Load core configuration for analysis which sets up coordinate grid frame and taxa of interest
source("scripts/config.R")

source("scripts/utils.R")


# Read Solow prior estimates of extinction probabilities described in section 3.1.1 of the paper
solow_dat <- read.csv("Analysis_inputs/direct_solow_dat.csv")

# Configures the exponential weighting prior that reduces with distance from historical habitat
# These kernels described in section 3.1.2 of the paper and estimated in section 3.1.2 of supplementary materials
distance_exp <- read.csv("Analysis_inputs/exp_weight.csv")

# For sensitivity analysis, multiplies the values of distance kernels by this value
exp_multiplier <- 1

# Core adjustable parameter scales weight of prior distribution relative to data - 1-3 is a reasonable compromise between being
# entirely uninformative and not swamping observations but cases could be made for values between, say, 0.5 and 10
prior_weight <- 4

# Other adjustable parameter scales value of search effort - this has to be considered relative to prior_weight, and intended
# to give a particular confidence of extirpation (e.g. 95%) once search effort reaches, say 1.2ks
search_weight <- 20

allcentroids_sf <- data.frame(cell_id = 1:(galgrid$latcount*galgrid$longcount)) %>% assign_cell_centroids_sf(galgrid)

galianoFine <- geojsonsf::geojson_sf("Analysis_inputs/Galiano_Fine_Boundary.geojson")
galpoints <- allcentroids_sf %>% st_filter(y = galianoFine, .predicate=st_intersects)

historical <- read.csv("Analysis_inputs/Occurrences/target_plant_records_2024.csv")

historical_sf <- st_as_sf(historical %>% dplyr::filter(!is.na(decimalLatitude)), coords=c("decimalLongitude", "decimalLatitude"))
st_crs(historical_sf) <- "WGS84"

historical_sf <- (assign_cell_id(historical_sf, galgrid) %>% dplyr::mutate(OID = dplyr::row_number()))

landClass <- mx_read("Analysis_inputs/Habitat_model/LandClass/land class apr04.shp")

# Step 4: Polygons with feature attributes corresponding to land classifications describing the habitat of target species
landClass_Habitat <- landClass %>% dplyr::filter(CLASS == "CL" | CLASS == "HB" | CLASS == "WD") %>% dplyr::mutate(HPID = dplyr::row_number())
st_crs(landClass_Habitat) <- "WGS84"

allHabitat <- st_union(landClass_Habitat)

# Generate cell candidates by linear expansion from centroids - using st_is_within_distance is far too slow
habitatcell_cand_ids <- cells_for_polygons(galpoints, landClass_Habitat) %>% expandCells(galgrid)
habitatcell_cands <- data.frame(cell_id = habitatcell_cand_ids) %>% assign_cell_geometry_sf(galgrid)

# Pick only those cells which genuinely intersect habitat - habitat becomes an sf dataframe of (cellid, geometry) for final accepted centroids
habitatcell_ids <- cells_for_polygons(habitatcell_cands, landClass_Habitat)
habitatcells <- data.frame(cell_id = habitatcell_ids) %>% assign_cell_centroids_sf(galgrid)

habitatOverrides <- read.csv("Analysis_inputs/Habitat_model/historical_habitat.csv")
habitatOverridesSplit <- split(habitatOverrides$cell_id, habitatOverrides$Population)
habitatOverrideKeys <- unique(habitatOverrides$Population)

habitatOverridesWithRegion <- subset(habitatOverrides, filter_region != "")
habitatOverridesPolygons <- setNames(
  lapply(habitatOverridesWithRegion$filter_region, function(region) {
    sf_obj <- st_read(paste0("Analysis_inputs/Habitat_model/", region), quiet = TRUE)
    return (sf_obj) # Ensure it is an sf object and not a list
  }),
  habitatOverridesWithRegion$Population
)

communityLookup = read.csv("Analysis_inputs/community_lookup.csv")

#' Replace assigned community values derived from historical record indices in a data frame
#` with friendly values based on a lookup table.
#'
#' @param df A data frame to modify.
#' @param col A string representing the name of the column in `df` to be modified.
#' @param lookup_df A data frame containing the lookup table with columns `Index` and `Name`.
#'
#' @return The modified data frame with the specified column updated based on the lookup table.
#'
replace_assigned_community <- function(df, col, lookup_df) {
  # df: data frame to modify
  # col: column name as a string
  # lookup_df: data frame with columns Index and Name
  
  # Ensure lookup map
  lookup <- setNames(as.character(lookup_df$Name), as.character(lookup_df$Index))
  lookup <- c("0" = "pot", lookup)
  lookup <- c("all" = "all", lookup)

  values <- as.character(df[[col]])
  
  # Replace only where value exists in lookup
  df[[col]] <- ifelse(values %in% names(lookup), lookup[values], values)
  
  return(df)
}

#' Assign a community to a habitat cell based on proximity and overrides.
#'
#' This function determines the community assignment for a given habitat cell
#' based on its distance to a historical population center, predefined override lists,
#' and optional override polygons. If the cell is within the specified radius of a population center,
#' it is assigned to that community. Otherwise, it may be assigned based on overrides.
#'
#' @param cell_id An integer representing the ID of the habitat cell.
#' @param NEAR_DIST A numeric value representing the distance of the cell to the nearest historical population center.
#' @param radius A numeric value representing the radius of influence for the population center.
#' @param OID An integer representing the ID of the historical population center.
#'
#' @return An integer representing the assigned community ID. Returns `OID` if the cell is assigned to a community,
#'   or `0` if no community is assigned.
#'
assign_community <- function (cell_id, NEAR_DIST, radius, OID) {
  key <- as.character(OID)
  overrideList <- habitatOverridesSplit[[key]]
  hasOverrideList <- !is.null(overrideList) && !identical(overrideList, NA) # Don't use is.na which coerces to list
  overrideListApply <- ifelse(hasOverrideList, cell_id %in% overrideList, FALSE)
  overridePolygon <- habitatOverridesPolygons[[key]]
  hasOverridePolygon <- !is.null(overridePolygon)
  if (NEAR_DIST < radius) {
    if (hasOverridePolygon) {
      centroid <- st_point(cell_id_to_centroid(galgrid, cell_id))
      inPolygon <- st_intersects(centroid, overridePolygon, sparse = FALSE)
      return (ifelse(inPolygon, OID, 0))
      centroid_sf <- st_sfc(centroid, crs = "WGS84")
    } else if (hasOverrideList) {
      return (ifelse(overrideListApply, OID, 0))
    } else {
      return (OID)
    }
  } else {
    if (overrideListApply) {
      wg("Override habitat assignment for cell {cell_id} which is at distance {radius} > {NEAR_DIST} from historical observation for population {OID}")
      return (OID)
    }
    return (0)
  }
}

assign_community_vector <- function (cell_id_in, NEAR_DIST, radius, OID) {
  mapply(function (ci, nd, ra, oi) {
    assign_community(ci, nd, ra, oi)
  }, cell_id_in, NEAR_DIST, radius, OID)
}


# Assign empty global frames to accumulate results

allPhenology <- data.frame()

allAcceptedSearch <- data.frame()

allPriorStats <- data.frame()

# Construct parameters of beta distribution given central parameter and weight
# In terms of https://distribution-explorer.github.io/continuous/beta.html construct alpha, beta given psi and kappa
make_beta <- function (prob, weight) {
  c(prob * weight, (1 - prob) * weight)
}

# Beta distribution statistics from https://en.wikipedia.org/wiki/Beta_distribution
beta_mean <- function (bf) {
  bf$alpha / (bf$alpha + bf$beta)
}

beta_variance <- function (bf) {
  bf$alpha * bf$beta / ((bf$alpha + bf$beta)^2 * (bf$alpha + bf$beta + 1))
}

# Compute beta parameters given moments
# Taken from https://stats.stackexchange.com/a/12239
beta_params_from_moments <- function (mu, var) {
  alpha <- ((1 - mu) / var - 1 / mu) * mu ^ 2
  beta <- alpha * (1 / mu - 1)
  return (params = list(alpha = alpha, beta = beta))
}

#' The highest density interval (HDI) for a Beta(a,b) distribution
#' @param a a positive number.
#' @param b a positive number.
#' @param p confidence level for the HDI.
#' @return Vector containing the limits of the HDI.
#' @keywords character
#' @importFrom stats qbeta dbeta pbeta pgamma
#' @examples
#' hdiBeta(2, 2, 0.9)
#
# Adapated from https://rdrr.io/rforge/nclbayes/src/R/hdi.R
hdiBeta <- function(a, b, p = 0.95) {
  if (a == b) {
    lower = qbeta((1 - p)/2, a, b); upper = qbeta((1 + p)/2, a, b)
  } else if ((a <= 1) & (b > 1)) {
    lower = 0; upper = qbeta(p, a, b)
  } else if ((a > 1) & (b <= 1)) {
    lower = qbeta(1 - p, a, b); upper = 1
  } else {
    zerofn = function(x){(dbeta(qbeta(p+pbeta(x,a,b),a,b), a, b)-dbeta(x, a, b))^2}
    maxl = qbeta(1 - p, a, b)
    res = optimize(zerofn, interval = c(0, maxl))
    lower = res$minimum; upper = qbeta(p + pbeta(lower, a, b), a, b)
  }
  c(lower, upper)
}


calc_extinction_beta <- function (prior_weight, search_weight, exp_weight, solow_prob, fringe_dist, search_effort, area_prop, half_solow = TRUE) {
  # Earlier version with minimum distance prior at half Solow - actually works fairly well
  exp_value <-  exp(-exp_weight * fringe_dist)
  prior <- make_beta(solow_prob * (ifelse(half_solow, 1, 0) + exp_value) / 2, prior_weight)

  # Very old version with separate solow and distance priors
  # solow_prior <- make_beta(solow_prob *  prior_weight)
  # distance_prior <- make_beta(exp_prior, prior_weight)
  # Central adjustable parameter here - interpretation of search_weight in paper section 3.2.1
  # See weird explanation on why we can't use ifelse here: https://stackoverflow.com/a/56915974/1381443
  search_beta <- `if`(search_effort == 0, c(0, 0), make_beta(0, search_weight * search_effort / area_prop))
  all_beta <- prior + search_beta
}

calc_extinction_beta_vector <- function (prior_weight, search_weight, exp_weight, solow_prob, fringe_dist, search_effort, area_prop, half_solow = TRUE) {
  result <- mapply(function (fd, se, ap) {
    calc_extinction_beta(prior_weight, search_weight, exp_weight, solow_prob, fd, se, ap, half_solow)
  }, fringe_dist, search_effort, area_prop)

  df <- data.frame(t(result))
  colnames(df) <- c("alpha", "beta")
  df <- df %>% mutate(mean = beta_mean(.), variance = beta_variance(.))

  return(df)
}

# Plot a "beta sweep" of a variety of different search_effort weightings for a particular Solow value to evaluate intuitions
# on how search effort should be interpreted within a single cell
plot_beta_sweep <- function (solow_prob) {
  sweep_effort = seq(from = 0, to = 4, by = 0.05)
  sweep_frame = data.frame(search_effort = sweep_effort, fringe_dist = 0, area_prop = 1)
  swr <- seq(from = 5, to = 60, by = 5)

  all_ebv <- map_dfr(swr, function(lsw) {
    ebv <- calc_extinction_beta_vector(
      prior_weight, lsw, 1, solow_prob,
      sweep_frame$fringe_dist,
      sweep_frame$search_effort,
      sweep_frame$area_prop
    )
    bind_cols(ebv, sweep_frame) %>%
      mutate(extinction_prob = 1 - mean, search_weight = lsw)
  })

  ggplot(all_ebv, aes(x = search_effort, y = extinction_prob, color = as.factor(search_weight))) +
    geom_line() +
    scale_x_continuous(breaks = seq(0, 10, by = 0.4)) +
    labs(
      #title = "Extinction Probability vs Search Effort for Various Weights",
      x = "Search effort in ks",
      y = "Extinction probability",
      color = "Search weight"
    ) +
    theme_minimal()
}

# Generate the figure for the paper's Supplementary Materials Figure 2 in section 3.2.1
supporting_figure_S3 <- function () {
  betaplot <- plot_beta_sweep(0.46)
  betaplot
  ggsave("Analysis_outputs/Figures/supporting_figure_S3_beta_sweep.jpg", dpi = 1000, units = "in",
         height = 4, width = 6)
}

supporting_figure_S2 <- function () {
  # Parameters for the Beta distribution
  location <- 0.46
  concentration <- 4

  # Compute alpha and beta parameters
  alpha <- location * (concentration - 1)
  beta <- (1 - location) * (concentration - 1)

  x_values <- seq(0, 1, by = 0.001)
  y_values <- dbeta(x_values, shape1 = alpha, shape2 = beta)
  data <- data.frame(x = x_values, y = y_values)

  # Create the plot
  ggplot(data, aes(x = x, y = y)) +
    stat_function(
      fun = dbeta,
      args = list(shape1 = alpha, shape2 = beta),
      color = "#3081ba",
      size = 1
    ) +
    scale_x_continuous(
      breaks = seq(0, 1, 0.1),  # Tick marks every 0.1
      limits = c(0, 1),
      expand = c(0.0015, 0.0015)
      ) +
    scale_y_continuous(
      breaks = seq(0, 1.4, 0.1),  # Tick marks every 0.1
      limits = c(0, 1.4),
      expand = c(0.0015, 0.0015)
    ) +
    labs(
      # title = "Beta Distribution",
      x = "y",
      y = "Density"
    ) +
    theme_minimal() +
    theme(
      plot.margin = unit(c(0.2, 0.2, 0.2, 0.2), "in"),
      axis.text = element_text(size=14),
      axis.line = element_line(color = "black"),          # Black axes
      axis.ticks = element_line(color = "black")
    )
  ggsave("Analysis_outputs/Figures/supporting_figure_S2_beta.jpg", dpi = 1000, units = "in",
         height = 4.5, width = 6)
}

#st_write(landClass_Habitat, str_glue("landClass_Habitat.shp"), driver="ESRI Shapefile", delete_dsn = TRUE)

# Round percentage for stats reporting
rp <- function (v) {
  percent(v, accuracy = 0.1)
}
# Round value for stats reporting
rv <- function (v) {
  round (v, 2)
}

#' Apply region moments to compute Beta distribution parameters and HDI.
#'
#' This function calculates the parameters of a Beta distribution and the highest density interval (HDI)
#' for a given region based on the provided mean and variance. It updates the input statistics list
#' with the computed values.
#'
#' @param stats A list containing the current statistics for the region.
#' @param mu A numeric value representing the mean of the region.
#' @param var A numeric value representing the variance of the region.
#'
#' @return A modified list of statistics with additional fields for Beta distribution parameters
#'   (`alpha`, `beta`), the central estimate, and the HDI limits (`Low`, `High`).
#'
apply_region_moments <- function (stats, mu, var) {
  params <- beta_params_from_moments(mu, var)

  hdi <- hdiBeta(params$alpha, params$beta, p = 0.9)
  fields <- list(Central = rp(1 - mu), Low = rp(1 - hdi[2]), High = rp(1 - hdi[1]), alpha = rv(params$alpha), beta = rv(params$beta), mu = mu, var = var)
  modifyList(stats, fields)
}

#' Generate summary statistics for a region based on beta distribution parameters.
#'
#' This function calculates summary statistics for a given region using beta distribution
#' parameters (`alpha`, `beta`) from the input dataframe. It computes weighted means for and applies
#' regional moments to update the statistics list.
#'
#' @param x A dataframe containing beta distribution parameters (`alpha`, `beta`) and other relevant data for the region.
#' @param exp_cells A numeric value representing the expected number of cells enclosed within a certain distance (experimental)
#' @param weight_vector An optional numeric vector of weights for calculating weighted means.
#'   If `NULL`, equal weights are used.
#'
#' @return A list containing the calculated summary statistics for the region, including
#'   the number of cells, the number of searched cells, the estimated number of populations,
#'   the proportion of habitat searched, and updated beta distribution statistics.
#'
region_stats <- function (x, exp_cells, weight_vector = NULL) {
  cells <- nrow(x)
  searched <- nrow(x %>% filter(search_effort > 0))

  if (is.null(weight_vector)) {
    weight_vector = rep(1, cells)
  }

  # Attempt at weighted average - abandoned since Meconella prob goes high over historical
  # weights <- 104 - 100 / (15.8 * x$search_effort + 1)

  mu <- weighted.mean(x$mean, weight_vector)
  var <- weighted.mean(x$variance, weight_vector) # Possibility is pop * mean / cells but becomes too tight

  # Estimate of number of distinct populations we believe the cells can be attributed to
  pops <- ifelse(exp_cells > cells, 1, cells / exp_cells)

  stats <- list(cells = cells, searched = searched, pops = rv(pops), habitatSearched = rp(searched / cells))
  stats <- apply_region_moments(stats, mu, var)
}

agm_to_summary <- function (accepted_grouped_merged, exp_weight, solow_prob, half_solow = TRUE) {
  extinction_beta <- calc_extinction_beta_vector(prior_weight, search_weight, exp_weight, solow_prob,
                                                 accepted_grouped_merged$fringe_dist, accepted_grouped_merged$search_effort, accepted_grouped_merged$area_prop, half_solow)
  accepted_summary <- assign_cell_geometry_sf(accepted_grouped_merged, galgrid) %>% bind_cols(extinction_beta) %>% mutate(extinction_prob = 1 - mean)
}

stats_to_df <- function (stats) {
  # Convert list to dataframe
  # Old version worked when stats was a list of vectors
  # stats_df <- as.data.frame(do.call(rbind, stats)) %>% tibble::remove_rownames()
  # Now when it is a list of lists attested at https://stackoverflow.com/a/68162050/1381443
  stats_df <- do.call(rbind, lapply(stats, data.frame)) %>% tibble::remove_rownames()
  stats_df <- stats_df %>% mutate("Population" = rownames(stats))
}

#' Analyse accepted habitat cells and compute extinction probabilities.
#'
#' This function processes accepted habitat cells, calculates extinction probabilities,
#' and generates summary statistics for a given target species. It also writes the results
#' to shapefiles and intermediate CSV files for further analysis.
#'
#' @param thisTarget A string representing the target species being analyzed.
#' @param accepted_grouped_merged A data frame containing grouped and merged data of accepted habitat cells,
#'   including search effort, fringe distance, and assigned community information.
#' @param habitat_to_centres A data frame mapping habitat cells to the nearest historical population centers.
#' @param exp_weight A numeric value representing the exponential weighting factor for distance from historical habitat.
#' @param solow_prob A numeric value representing the Solow prior probability of extinction.
#' @param set_name A string used to name the output files generated by this function.
#'
#' @return A data frame containing summary statistics for the analyzed habitat cells.
#'
analyse_accepted <- function (thisTarget, accepted_grouped_merged, habitat_to_centres, exp_weight, solow_prob, set_name) {

  accepted_summary <- agm_to_summary(accepted_grouped_merged, exp_weight, solow_prob)

  st_write(accepted_summary, str_glue("Analysis_outputs/{thisTarget}_{set_name}.shp"), driver="ESRI Shapefile", delete_dsn = TRUE)

  accepted_in_historical <- nrow(accepted_summary %>% filter(assigned_community > 0 & search_effort > 0) )
  historical_habitat_cells <- nrow(habitat_to_centres %>% filter(assigned_community > 0))

  cat("Accepted a total of ", nrow(accepted_summary), " cells within range of valid habitat, of which ", accepted_in_historical, " lie in historical habitat\n")
  writeLines(str_glue("Accepted cells are proportion {accepted_in_historical}/{historical_habitat_cells} ({round(100*accepted_in_historical/historical_habitat_cells, 2)}%) of all historical habitat\n"))

  # Distance at which exponential function decays to 10% of its central height indicating lack of significant interaction
  exp_dist <- -log(0.1) / exp_weight
  # Number of cells enclosed in this distance
  exp_cells <- exp_dist^2 / gridcell^2

  stats <- tapply(accepted_summary, accepted_summary$assigned_community, region_stats, exp_cells = exp_cells)

  # Produce blank regional stats so that we can plot graphs in figure xxxx
  blank_agm <- accepted_grouped_merged %>% mutate(search_effort = 0)
  blank_as <- agm_to_summary(blank_agm, exp_weight, solow_prob)
  blank_stats <- tapply(blank_as, blank_as$assigned_community, region_stats, exp_cells = exp_cells)
  blank_stats_df <- stats_to_df(blank_stats) %>% mutate("target" = thisTarget, prior_ER = rv(1 - solow_prob))

  allPriorStats <<- rbind(allPriorStats, blank_stats_df)

  stats_df <- stats_to_df(stats)

  writeLines("Summary statistics [Population `0` represents valid habitat not part of historical habitat]:\n")

  print(stats_df)

  writeLines("")

  blank_nohalf_as <- agm_to_summary(blank_agm, exp_weight, solow_prob, half_solow = TRUE) %>% mutate(one = 1)

  regional_sr <- blank_nohalf_as %>% st_drop_geometry %>% group_by(assigned_community) %>% summarise(mean_sr = mean(1 - extinction_prob), count = sum(one)) %>% mutate(sum_sr = mean_sr / count)

  regional_sr_weight <- accepted_summary %>% st_drop_geometry %>%
    left_join(regional_sr, by = join_by(assigned_community)) %>%
    pull(sum_sr)

  # Original method of computing all stats - simply concatenates all cells together, but with weighting
  allStats <- c(region_stats(accepted_summary, exp_cells, regional_sr_weight), "Population" = "all")

  stats_df <- rbind(stats_df, allStats)

  stats_df <- stats_df %>% mutate("target" = thisTarget, prior_ER = rv(1 - solow_prob))
  stats_df_rewrite <- replace_assigned_community(stats_df, "Population", communityLookup)
  
  timedWrite(stats_df_rewrite, str_glue("Analysis_outputs/Intermediate/{thisTarget}_stats.csv"))
  
  stats_df
}

analyse_target <- function (thisTarget, detected = FALSE) {
  wg("Processing target {thisTarget}\n")

  # Step 3: Historical plant records for target species
  target_plant_records <- historical_sf %>% dplyr::filter(str_detect(scientificName, thisTarget))

  wg("Acquired {nrow(target_plant_records)} historical records\n")

  historical_centres <- target_plant_records %>% select(coordinateUncertaintyInMeters, OID) %>% group_by(geometry) %>%
    summarize(across(everything(), first)) %>%
    ungroup()

  wg("Summarised to {nrow(historical_centres)} unique historical populations")

  nearest_centres <- st_nearest_feature(habitatcells, historical_centres)
  nearest_distances <- st_distance(habitatcells, historical_centres[nearest_centres,], by_element = TRUE)

  # For each habitat cell map it to the nearest historical population centre together with assigned_community set if it is within the community's radius
  habitat_to_centres <- data.frame(
    OID = historical_centres$OID[nearest_centres],
    cell_id = habitatcells$cell_id,
    NEAR_DIST = as.numeric(nearest_distances),
    uc = historical_centres$coordinateUncertaintyInMeters[nearest_centres]
  ) %>% mutate_at(vars(uc), ~replace_na(., 50)) %>% mutate(
      radius = uc + gridcell * sqrt(2) / 2,
      assigned_community = assign_community_vector(cell_id, NEAR_DIST, radius, OID),
      fringe_dist = ifelse(assigned_community == 0, NEAR_DIST, 0))

  community_counts <- habitat_to_centres %>%
    group_by(assigned_community) %>%
    summarize(
      OID = first(OID),
      uc = first(uc),
      count = n()
    ) %>% ungroup()

  nc <- nrow(community_counts)

  wg("Analysed historical habitat into {nc} centre{ifelse(nc == 1, '', 's')}")

  for(i in 1:nrow(community_counts)) {
    row <- community_counts[i,]
    if (row$assigned_community != 0) {
      wg("--> Community centred on record {row$OID} with radius {row$uc}m covering {row$count} habitat cells")
    }
  }

  searchEffort <- read.csv(str_glue("Analysis_inputs/Search_Effort/Target_Summaries/{thisTarget}.csv")) %>% select(cell_id, effortId, search_effort)

  #searchEffort_max <- searchEffort %>%
  #  group_by(cell_id) %>%
  #  slice_max(search_effort, with_ties = FALSE) %>%
  #  ungroup() %>% select(cell_id, effortId, search_effort)

  blank_cell_ids <- setdiff(habitatcells$cell_id, unique(searchEffort$cell_id))
  blankSearchEffort = data.frame(cell_id = blank_cell_ids) %>% mutate(effortId = "prior", search_effort = 0)

  allSearchEffort <- rbind(searchEffort, blankSearchEffort)

  # Assign each effort cell to a historical community. Those which lie outside communities but in habitat will have OID of 0, those
  # which lie outside habitat entirely will have OID of NA - but because of fringing we still want to include a few of these
  effortCells <- merge(allSearchEffort, habitat_to_centres, by = "cell_id", all.x = TRUE)
  effortCells_sf <- effortCells %>% assign_cell_centroids_sf(galgrid)

  habitat_to_centres_sf <- assign_cell_centroids_sf(habitat_to_centres, galgrid)

  # For each effort cell, what is the nearest habitat polygon to it
  habitat_nearest_cells <- st_nearest_feature(effortCells_sf, habitat_to_centres_sf)
  habitat_nearest_cell_distances <- as.numeric(st_distance(effortCells_sf, habitat_to_centres_sf[habitat_nearest_cells,], by_element = TRUE))

  searchEffort_habitat <- effortCells %>% rename(original_cell_id = cell_id) %>% mutate(
                                                        cell_id = habitat_to_centres_sf$cell_id[habitat_nearest_cells],
                                              #          fringe_dist = habitat_to_centres_sf$fringe_dist[habitat_nearest_cells],
                                                        nearest_habitat_distance = habitat_nearest_cell_distances,
                                                        assigned_community = habitat_to_centres_sf$assigned_community[habitat_nearest_cells])

  effortCells_to_nearest_habitat = data.frame(
    cell_id = effortCells$cell_id,
    nearest_habitat_cell_id = habitat_to_centres_sf$cell_id[habitat_nearest_cells],
    fringe_dist = habitat_to_centres_sf$fringe_dist[habitat_nearest_cells]
    #nearest_habitat_distance = habitat_nearest_cell_distances
    )

  # Now take the original search effort and "nudge" it into the closest habitat cells
  #searchEffort_habitat <- merge(x = searchEffort %>% select(cell_id, effortId, search_effort), y = effortCells_to_nearest_habitat, by = "cell_id", all.x = TRUE)
  # Determine the assigned community corresponding to the target of nudge
  #searchEffort_habitat <- merge(x = searchEffort_habitat, y = habitat_to_centres %>% select(cell_id, assigned_community), by.x = "nearest_habitat_cell_id", by.y = "cell_id", all.x = TRUE)

  discarded <- searchEffort_habitat[searchEffort_habitat$nearest_habitat_distance > gridcell, ]

  wg("Discarding {nrow(discarded)} search effort cells as greater than threshold of {gridcell}m from suitable habitat",
    " for total search effort of {round(sum(discarded$search_effort), 2)}ks")

  accepted <- searchEffort_habitat[searchEffort_habitat$nearest_habitat_distance <= gridcell, ]

  wg("Processing {nrow(accepted)} search effort cells for total search effort of {round(sum(accepted$search_effort), 2)}ks")

  # Sanity check that all "accepted" search effort is indeed assigned to some community

  unassigned_accepted <- sum(is.na(accepted$assigned_community))
  if (unassigned_accepted > 0) {
    wg("Error in analysis - {unassigned_accepted} accepted effort cells were not assigned to a community")
    stop()
  }

  # Produce phenology outputs for Table 1
  accepted_month <- accepted %>% mutate(month = as.numeric(str_extract(effortId, "(\\d{4})-(\\d{2})", group = 2))) %>% group_by(month) %>% summarise(total_search_effort = round(sum(search_effort), 2))
  accepted_month_filled <- tibble(month = 2:11) %>% left_join(accepted_month, by = "month") %>% replace(is.na(.), 0)
  # Transpose so that data layout matches that in the table
  amf_transpose <- as.data.frame(t(accepted_month_filled$total_search_effort))
  colnames(amf_transpose) <- accepted_month_filled$month
  rownames(amf_transpose) <- thisTarget

  allPhenology <<- rbind(allPhenology, amf_transpose)
  allAcceptedSearch <<- rbind(allAcceptedSearch, accepted)

  # Actually do the "nudge" and assign all search effort from cells neighbouring habitat into those actually within it
  accepted_grouped <- accepted %>%
    group_by(effortId, cell_id) %>%
    summarize(
      search_effort = sum(search_effort)
    ) %>%
    ungroup() %>% arrange(cell_id) %>%
    left_join(habitat_to_centres %>% select(cell_id, fringe_dist, assigned_community))

  # We formerly accepted just the maximum search effort for a cell
  # accepted_grouped_max <- accepted_grouped %>%
  #   group_by(cell_id) %>%
  #   slice_max(search_effort, with_ties = FALSE) %>%
  #   ungroup()

  accepted_grouped_sum <- accepted_grouped %>%
    group_by(cell_id) %>%
    summarize(
      effortId = paste(effortId, collapse = ", "),
      search_effort = sum(search_effort, na.rm = TRUE),
      fringe_dist = first(fringe_dist),  # Assuming fringe_dist and assigned_community don't change for each cell_id
      assigned_community = first(assigned_community)
    ) %>%
    ungroup()

  accepted_grouped_sf <- accepted_grouped_sum %>% assign_cell_geometry_sf(galgrid)

  oneArea <- gridcell * gridcell
  # Assemble the cells which truly lie within the habitat together with their proportion of overlap
  effortCells_intersect <- st_intersection((accepted_grouped_sf %>% filter(search_effort > 0)), allHabitat) %>% mutate(area = st_area(.) %>% as.numeric(), area_prop = area / oneArea) %>% select(cell_id, area, area_prop) %>% st_drop_geometry()

  accepted_grouped_merged <- accepted_grouped_sum %>% left_join(effortCells_intersect)
  accepted_grouped_merged_rewrite <- replace_assigned_community(accepted_grouped_merged, "assigned_community", communityLookup)

  timedWrite(accepted_grouped_merged_rewrite, str_glue("Analysis_outputs/Intermediate/{thisTarget}_accepted_grouped_merged.csv"))
  
  if (!detected) {
    exp_weight <- (distance_exp %>% dplyr::filter(str_detect(Species, thisTarget)))$Exp_weight * exp_multiplier
    solow_records <- solow_dat %>% dplyr::filter(str_detect(Species, thisTarget))
    # Pick the lowest (that is, lowest "sighting rate" = greatest prob of extirpation) record, corresponding to 1958 burgman/solow value
    solow_low <- min(solow_records$DirectSolowPP)
    # wg("Acquired {nrow(solow_records)} Solow records with prior range between {round(solow_low, 3)} and {round(solow_high, 3)}")
    lowSet <- analyse_accepted(thisTarget, accepted_grouped_merged, habitat_to_centres, exp_weight = exp_weight, solow_prob = solow_low, set_name = "Solow_low")
    return (lowSet)
  }
}

allStats <- data.frame()

for (thisTarget in focalTargets) {
  thisStats <- analyse_target(thisTarget)
  allStats <- rbind(allStats, thisStats)
}

for (thisTarget in detectedTargets) {
  analyse_target(thisTarget, TRUE)
}

write.csv(allStats, str_glue("Analysis_outputs/extirpation_statistics.csv"), na = "", row.names = FALSE)
allPhenology <- allPhenology[ order(row.names(allPhenology)), ]
write.csv(allPhenology, str_glue("Analysis_outputs/search_effort_phenology.csv"), na = "")

# Figure of (currently 728) distinct cells feeding into "Effective search efforts were thus estimated at" figure in Results of paper
allAcceptedActualSearch = allAcceptedSearch %>% filter(search_effort > 0) %>% distinct(cell_id)

allAcceptedUnique <- allAcceptedSearch %>%
  group_by(cell_id, effortId) %>%
  slice_head(n = 1) %>%
  ungroup()

cat("Search efforts in valid habitat estimated at ", sum(allAcceptedUnique$search_effort), "ks")

allAcceptedUniqueHistorical <- allAcceptedUnique %>% filter(assigned_community != 0)

cat("Search efforts in historical habitat estimated at ", sum(allAcceptedUniqueHistorical$search_effort), "ks")

cat("Effective search efforts were estimated at ", nrow(allAcceptedActualSearch), " cells")
