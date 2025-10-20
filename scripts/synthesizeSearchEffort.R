# Initiated 2024-02-30
# Antranig Basman

# Synthesize materials for analysis from the following raw materials:
# * Central Search Effort table at Analysis_inputs/Search_Effort/Search_Effort_Summary.csv
# indexing all search effort events, each of which may be associated with a full GPS Trace, or else
# a trace to be imputed from iNaturalist observations matched on time range and observers
# * iNaturalist observations to be synthesized into search effort traces through linear interpolation
# * GPS traces indexed in Analysis_inputs/Search_Effort/GPS_Data/GPS_Data_table.csv
# Supplementary files:
# * Patch file censoring iNaturalist observations with dubious coordinates Analysis_inputs/Search_Effort/iNaturalist_Observations/iNat_obs_patch.csv
# * Table normalising iNaturalist handles and observer names Analysis_inputs/Search_Effort/iNaturalist_Observations/Observer_Names.csv
#
# Principal outputs:
# * Pooled complete search effort density accrued across all traces in Analysis_inputs/Search_Effort/Search_Effort_Density/all.shp
# 
# Outputs:
# * For each search event for which a trace is to be synthesized from iNaturalist observations, 
# ** A filtered list of those observations in Analysis_inputs/Search_Effort/iNaturalist_Observations/iNat_surveys
# ** The synthesized traces as KML in Analysis_inputs/Search_Effort/Synthesized_Search_Effort_Traces/{traceId}.kml
# 
# * Various diagnostics in Analysis_inputs/Search_Effort/iNaturalist_Observations for georeferencing of iNaturalist traces
# 

bench.start <- Sys.time()

# Set relative paths (https://stackoverflow.com/questions/13672720/r-command-for-setting-working-directory-to-source-file-location-in-rstudio)

setwd(paste0(dirname(rstudioapi::getActiveDocumentContext()$path), "/.."))

source("Scripts/geomUtils.R")

# Load packages

library(dplyr)
library(tibble)
library(stringr)
library(tidyr)
library(readr)
library(sf)
library(geojsonsf)
library(units)

# Load core configuration for analysis which sets up coordinate grid frame and taxa of interest
source("Scripts/config.R")

# Read central search effort table
effort <- read.csv("Analysis_inputs/Search_Effort/Search_Effort_Summary.csv")

# Read iNaturalist observations and other source files

obs <- read.csv("Analysis_inputs/Search_Effort/iNaturalist_Observations/iNat-obs-2024-11-04.csv")
observerNames <- read.csv("Analysis_inputs/Search_Effort/iNaturalist_Observations/Observer_Names.csv")

# Patch this localised taxon name to agree with iNat's taxonomy
effort$Target.Species <- sub("Perideridia montana", "Perideridia gairdneri", effort$Target.Species)

gpstable <- read.csv("Analysis_inputs/Search_Effort/GPS_Data/GPS_Data_table.csv")

obsPatch <- read.csv("Analysis_inputs/Search_Effort/iNaturalist_Observations/iNat_obs_patch.csv")
obsPatch$ID <- sub("https://www.inaturalist.org/observations/", "iNat:", obsPatch$ID)

## The number of seconds gap between trace entries synthesized from iNat observation
obsTraceEvery <- 15
## Observations without uncertainty assigned or below this value are assigned to this value
minimumCoordinateUncertainty <- 10

## If TRUE, issue a warning where speed of an interpolated trace segment exceeds a threshold
warnSpeed = TRUE

## A threshold in km/h for speed of an interpolated trace segment, above which a warning will be issued
warnSpeedThreshold = 2.5

# Left-pad Start and End times so they can form a valid ISO timestamp
effort$Start <- str_pad(effort$Start, 8, pad="0")
effort$End <- str_pad(effort$End, 8, pad="0")

parse_PST <- function(datetime) {
  as.POSIXct(parse_datetime(datetime, locale = locale(tz = "America/Vancouver")))
}

effort <- effort %>% mutate(startDatetime = ifelse(Start == "00000000", Date, paste(Date, Start, sep="T")),
                            endDatetime = ifelse(End == "00000000", Date, paste(Date, End, sep="T"))) %>%
  mutate(startTimestamp = parse_PST(startDatetime), endTimestamp = parse_PST(endDatetime))

parseEffortRow <- function (anEffort) {
  thisObservers <- str_trim(str_split(anEffort$Observers,",")[[1]])
  observerCount <- length(thisObservers)
  fileEffortStart <- gsub(":", "-", anEffort$startDatetime)
  effortRecorder <- thisObservers[1]
  effortId <- str_glue("{fileEffortStart}-{effortRecorder}")
  if (!is.na(anEffort$Day.effortId)) {
    effortId <- str_glue("{effortId}-{anEffort$Day.effortId}")
  }
  return (list(thisObservers = thisObservers, effortId = effortId, observerCount = observerCount, durationMins = anEffort$Duration.mins))
}

# https://stackoverflow.com/a/1699296/1381443
effort$effortId <- by(effort, seq_len(nrow(effort)), function(row) {
  parsedRow <- parseEffortRow(row)
  parsedRow$effortId
})

# Extract unique target species with valid names
effortWithTarget <- effort %>% filter(grepl("^[A-Z]", Target.Species))
allFoundTargets <- sort(unique(effortWithTarget$Target.Species))

obs$timestamp = as.POSIXct(parse_datetime(obs$Date.observed))

obs_sf <- st_as_sf(obs, coords=c("Longitude", "Latitude"))
st_crs(obs_sf) <- "WGS84"

# Linearly interpolate between two values
interp <- function (start, end, prop) {
  start + prop * (end - start)
}

# Undo obtuse wrapping of output of st_coordinates applied to sf geometry
to_coords <- function (sfp) {
  as.list((st_coordinates(sfp))[1,])
}

# Allocate some globals to accumulate diagnostics
badUncertaintyObs <- data.frame()
allUncertaintyStats <- data.frame()
allObsDistanceStats <- data.frame()
speedTrace <- data.frame(traceId=character(), time=as.POSIXct(character()), span=double(), speed=double())

impute_speed <- function(startTime, startPos, endTime, endPos) {
  distance <- st_distance(startPos, endPos)
  startC <- to_coords(startPos)
  endC <- to_coords(endPos)
  rawlag <- endTime - startTime
  units(rawlag) <- "secs"
  timelag <- as.numeric(rawlag)
  speed <- round(set_units(3.6 * distance / timelag, NULL), 2)
  return (list(speed = speed, timelag = timelag, distance = distance, startC = startC, endC = endC))
}

# Linearly Interpolate between start and end positions and times
# trace: dataframe with coordinates to have trace segment appended
# startTime, endTime: datetime
# startPos, endPos: sf points for start and end of trace
# grain: granularity of positions in seconds
# finalPoint: TRUE if final point should be included
obsTraceSpan <- function (effortId, startTime, startPos, endTime, endPos, grain, finalPoint=FALSE) {
  sr <- impute_speed(startTime, startPos, endTime, endPos)

  cat("Producing trace for time span of ", sr$timelag, "s with speed ", sr$speed, "km/h\n")
  if (warnSpeed & sr$timelag > 0 & sr$speed > warnSpeedThreshold) {
    cat(str_glue("*** Warning for observations in trace with id {effortId} at time {startTime} - imputed speed is {sr$speed}km/h which probably indicates data quality issue"))
    cat("\n")
  }
  lst <- speedTrace
  lst[nrow(lst) + 1,] = list(effortId, startTime, sr$timelag, sr$speed)
  speedTrace <<- lst
  points <- floor(sr$timelag / grain)
  prop <- seq(from = 0, by = 1/points, length.out = ifelse(finalPoint & points > 0, points + 1, points))

  pointTime <- interp(startTime, endTime, prop)
  pointLat <- interp(sr$startC$Y, sr$endC$Y, prop)
  pointLong <- interp(sr$startC$X, sr$endC$X, prop)

  trace <- data.frame(lat = pointLat, long = pointLong, time = pointTime)
}

trackToTrace <- function (effortId, sortedTrack_sf, effortRow, traceEvery) {
  tracelen <- nrow(sortedTrack_sf)

  if (tracelen == 1) {
    newTrace <- obsTraceSpan(
      effortId,
      effortRow$startTimestamp,
      sortedTrack_sf[1, ],
      effortRow$endTimestamp,
      sortedTrack_sf[1, ],
      traceEvery,
      finalPoint = TRUE)
  } else {
    traceList <- lapply(seq_len(tracelen - 1), function (track) {
      obsTraceSpan(
        effortId,
        sortedTrack_sf[[track, "timestamp"]],
        sortedTrack_sf[track, ],
        sortedTrack_sf[[track + 1, "timestamp"]],
        sortedTrack_sf[track + 1, ],
        traceEvery,
        finalPoint = ifelse(track == tracelen - 1, TRUE, FALSE)
      )
    })
    # https://stackoverflow.com/questions/69048444/fastest-alternative-to-rbind-fill
    newTrace <- bind_rows(traceList)
  }

  # Convert trace to sf dataframe
  newTrace_sf <- st_as_sf(newTrace, coords=c("long", "lat"))
  st_crs(newTrace_sf) <- "WGS84"
  newTrace_sf
}

trackToDistances <- function (sortedTrack_sf) {
  distances <- sapply(1:(nrow(sortedTrack_sf) - 1), function(i) {
    st_distance(sortedTrack_sf$geometry[i], sortedTrack_sf$geometry[i + 1])
  })
}

# Assign a cell_id to a trace and then sum up search effort by cell_id with supplied searchWeight
condenseTrace <- function (trace, searchWeight) {
  gridTrace <- st_drop_geometry(assign_cell_id(trace, galgrid))
  gridTrace_c <- gridTrace %>% count(cell_id) %>% mutate(search_effort = n * searchWeight) %>% select(-one_of(c("n")))
}

# Allocate globals to accumulate all density/traces

# See https://github.com/r-spatial/sf/issues/354#issuecomment-637562576
pointGeom <- st_sfc(crs = 4326)
class(pointGeom)[1] <- "sfc_POINT" # for points

missingTraces <- list()
allTraces <- st_sf(effortId=character(), time=as.POSIXct(character()), searchWeight=numeric(), geometry=pointGeom)

allCondensed <- data.frame()
condensedWithTarget <- data.frame()

applyTrace <- function (trace, searchWeight, effortId, targets) {

  trace$effortId = parsedEffortId
  trace$searchWeight = searchWeight
  allTraces <<- rbind(allTraces, trace)

  condensed <- condenseTrace(trace, searchWeight / 1000)
  allCondensed <<- rbind(allCondensed, condensed)

  condensed$effortId = effortId;
  for (target in thisTargets) {
    condensed$target = target
    condensedWithTarget <<- rbind(condensedWithTarget, condensed)
    cat("Applied gridded trace of ", nrow(condensed), " cells for ", target, "\n")
    }
}

## Deal with GPS Traces

gps.start <- Sys.time()

# KML files often contain a variety of "junk" layers, we expect that the largest layer corresponds to the data of interest
readLargestLayer <- function (filename) {
  layers_info <- st_layers(filename)
  # Get the name of the layer with the largest number of features
  largest_layer_name <- layers_info$name[which.max(layers_info$features)]
  # Read the largest layer using st_read
  largest_layer <- st_read(filename, layer = largest_layer_name)
}

fetchCombinedTrace <- function (gpsrows) {
  rowtraces <- lapply(gpsrows$Filename, function(filename) {
    cat("Filename ", filename, "\n")
    trace <- readLargestLayer(str_glue("Analysis_inputs/Search_Effort/GPS_Data/GPS_Tracks/{filename}.kml"))
    trace <- trace[c("geometry")]
    return (trace)
  })

  do.call(rbind, rowtraces)
}

effortWithTrace <- effortWithTarget %>% filter(Tracks == "yes")
effortWithTraceIds <- unique(effortWithTrace$effortId)
effortWithTraceIds

for (parsedEffortId in effortWithTraceIds) {
  thisEfforts <- filter(effortWithTarget, effortWithTarget$effortId == parsedEffortId)
  thisTargets <- thisEfforts$Target.Species
  anEffort <- thisEfforts[1,]
  parsed <- parseEffortRow(anEffort)
  thisObservers <- parsed$thisObservers
  observerCount <- parsed$observerCount
  cat("Considering effortId ", parsedEffortId, "\n")
  gpsrows <- filter(gpstable, effortId == parsedEffortId)
  noRows <- nrow(gpsrows) == 0
  cat(ifelse(noRows, "**** ", ""), "Found ", nrow(gpsrows), " GPS trace rows for effort\n")
  if (noRows) {
    missingTraces <- c(missingTraces, parsedEffortId)
  }
  trace <- fetchCombinedTrace(gpsrows)
  trace$time = anEffort$startTimestamp
  tracePoints <- nrow(trace)
  traceRate <- 60 * parsed$durationMins / tracePoints
  searchWeight <- traceRate * observerCount

  applyTrace(trace, searchWeight, parsedEffortId, thisTargets)
}

cat("Found ", length(missingTraces), " missing GPS Traces:\n")
missingTraces

gps.end <- Sys.time()
cat("Processed ", length(effortWithTraceIds), " GPS traces in ", gps.end - gps.start, "s")

## Deal with iNaturalist Observations

effortWithObs <- effort ## Assume that we will look for obs for every effort - could also %>% filter(Record == "observations")

effortWithObsIds <- unique(effortWithObs$effortId)
effortWithObsIds

appendINatNames <- function (thisObservers) {
  # Filter rows where Search.Effort.Name is in observer_names and iNat.Name is not NA
  matching_rows <- observerNames[observerNames$Search.Effort.Name %in% thisObservers & !is.na(observerNames$iNat.Name), ]

  # Extract the iNat.Name column
  iNat.Names <- matching_rows$iNat.Name

  # Append the iNat names to the observer names
  combined_result <- c(thisObservers, iNat.Names)

  return(combined_result)
}

obs_to_sf <- function (someObs) {
  obs_sf <- st_as_sf(someObs, coords=c("Longitude", "Latitude"))
  st_crs(obs_sf) <- "WGS84"
  obs_sf
}

sortedObsForEffort <- function (obs, anEffort, thisObservers) {
  useObservers <- appendINatNames(thisObservers)
  trackObs <- filter(obs, obs$Recorded.by %in% useObservers &
                       obs$timestamp >= anEffort$startTimestamp & obs$timestamp <= anEffort$endTimestamp)

  sortedTrack <- trackObs[order(trackObs$timestamp),]
}

bad_uncertainty <- function (value) {
  is.na(value) | value < minimumCoordinateUncertainty
}

distance_stats <- function (uncert, effortId) {
  list(effortId = effortId, min = round(min(uncert), 2), max = round(max(uncert), 2), mean = round(mean(uncert), 2))
}

emptyObsEfforts <- effortWithTarget[0,]

for (parsedEffortId in effortWithObsIds) {
  thisEfforts <- filter(effortWithTarget, effortWithTarget$effortId == parsedEffortId)
  thisTargets <- thisEfforts$Target.Species
  anEffort <- thisEfforts[1,]
  parsed <- parseEffortRow(anEffort)
  thisObservers <- parsed$thisObservers
  observerCount <- parsed$observerCount

  hasGPSTrack <- anEffort$Tracks != ""
  hasValidTarget <- length(intersect(allTargets, thisTargets) > 0)

  sortedTrack <- sortedObsForEffort(obs, anEffort, thisObservers)
  cat("Got track of ", nrow(sortedTrack), " observations for search effort of ", anEffort$Observers, " with effortId ", parsedEffortId, "\n")
  write.csv(sortedTrack, str_glue("Analysis_inputs/Search_Effort/iNaturalist_Observations/iNat_surveys/{parsedEffortId}.csv"), na = "", row.names = FALSE)

  if (nrow(sortedTrack) > 0) {
    sortedTrack_sf <- obs_to_sf(sortedTrack)

    filteredTrack_sf <- sortedTrack_sf %>% filter(!(observationId %in% obsPatch$ID))

    if (hasValidTarget && !hasGPSTrack) {
      # Apply minimum of minimumCoordinateUncertainty coordinate uncertainty to all obs and log those affected
      thisBadUncertaintyObs <- filteredTrack_sf %>% filter(bad_uncertainty(coordinateUncertaintyInMeters))
      badUncertaintyObs <<- rbind(badUncertaintyObs, thisBadUncertaintyObs)

      filteredTrack_sf$coordinateUncertaintyInMeters[sapply(filteredTrack_sf$coordinateUncertaintyInMeters, bad_uncertainty)] <- minimumCoordinateUncertainty

      thisUncertaintyStats <- distance_stats(filteredTrack_sf$coordinateUncertaintyInMeters, parsedEffortId)
      allUncertaintyStats <<- rbind(allUncertaintyStats, thisUncertaintyStats)
    }

    trackObservers <- unique(filteredTrack_sf$Recorded.by)
    trackObserverCount <- length(trackObservers)

    cat("Generating ", trackObserverCount, " traces for observers of effortId ", parsedEffortId, "\n")

    for (trackObserver in trackObservers) {
      traceId <- str_glue("{parsedEffortId}!{trackObserver}")
      obsFilteredTrack_sf <- filteredTrack_sf[filteredTrack_sf$Recorded.by == trackObserver,]

      if (nrow(obsFilteredTrack_sf) > 1 && !hasGPSTrack) {
        obsDistances <- trackToDistances(obsFilteredTrack_sf)
        obsDistanceStats <- distance_stats(obsDistances, traceId)
        allObsDistanceStats <<- rbind(allObsDistanceStats, obsDistanceStats)
      }

      newTrace_sf <- trackToTrace(parsedEffortId, obsFilteredTrack_sf, anEffort, obsTraceEvery)
      # Was newTrace_sf <- trackToTrace(parsedEffortId, filteredTrack_sf, anEffort, obsTraceEvery)
      newTrace_sf$effortId = parsedEffortId

      effortSpan <- as.numeric(anEffort$endTimestamp) - as.numeric(anEffort$startTimestamp)
      obsSpan <- as.numeric(tail(obsFilteredTrack_sf, n=1)$timestamp) - as.numeric(obsFilteredTrack_sf[[1, "timestamp"]])
      # Rescale all of the effort traces to account for discrepancy between total effort recorded in row and timelag between first and last actual obs
      timeReweight <- ifelse(nrow(obsFilteredTrack_sf) == 1, 1, effortSpan / obsSpan)

      # Rescale for discrepancy between number of reported observers and those who actually posted obs
      obsReweight <- observerCount / trackObserverCount

      searchWeight <- obsTraceEvery * timeReweight * obsReweight;
      newTrace_sf$searchWeight = searchWeight
      st_write(newTrace_sf, str_glue("Analysis_inputs/Search_Effort/Synthesized_Search_Effort_Traces/{traceId}.kml"), driver = "kml", delete_dsn = TRUE)

      # Don't double count by applying trace for search effort for which we already have a GPS track
      if (!hasGPSTrack) {
        applyTrace(newTrace_sf, searchWeight, parsedEffortId, thisTargets)
      }
    }
  } else if (!hasGPSTrack) {
    cat ("Unexpected empty obs for effort ", parsedEffortId)
    emptyObsEfforts[nrow(emptyObsEfforts) + 1,] <- anEffort
  }
}

writeTargetSummary <- function (condensedWithTarget, thisTarget) {
  forTarget <- condensedWithTarget[condensedWithTarget$target == thisTarget,]
  summary <- forTarget %>%
    group_by(cell_id, effortId) %>%
    summarise(
      search_effort = sum(search_effort)
    )
  summary <- assign_cell_centroids(summary, galgrid)
  write.csv(summary, str_glue("Analysis_inputs/Search_Effort/Target_Summaries/{thisTarget}.csv"), na = "", row.names = FALSE)
}

condensed_final <- allCondensed %>% drop_na(cell_id) %>% group_by(cell_id) %>% summarise(across(everything(), sum))
condensed_final_sf <- assign_cell_geometry_sf(condensed_final, galgrid)
st_write(condensed_final_sf, str_glue("Analysis_inputs/Search_Effort/Search_Effort_Density/all.shp"), driver="ESRI Shapefile", delete_dsn = TRUE)

allTraces <- st_zm(allTraces)
st_write(allTraces, str_glue("Analysis_inputs/Search_Effort/Synthesized_Search_Effort_Traces/Combined-Trace.kml"), driver = "kml", delete_dsn = TRUE)

condensedWithTarget <- condensedWithTarget %>% drop_na(cell_id)

foundTargets <- unique(condensedWithTarget$target)

for (thisTarget in foundTargets) {
  writeTargetSummary(condensedWithTarget, thisTarget)
}

write.csv(speedTrace, str_glue("Analysis_inputs/Search_Effort/iNaturalist_Observations/speed_trace.csv"), na = "", row.names = FALSE)
write.csv(emptyObsEfforts, str_glue("Analysis_inputs/Search_Effort/iNaturalist_Observations/empty_obs_traces.csv"), na = "", row.names = FALSE)
write.csv(badUncertaintyObs, str_glue("Analysis_inputs/Search_Effort/iNaturalist_Observations/bad_uncertainty_obs.csv"), na = "", row.names = FALSE)
write.csv(allUncertaintyStats, str_glue("Analysis_inputs/Search_Effort/iNaturalist_Observations/effort_uncertainty_stats.csv"), na = "", row.names = FALSE)
write.csv(allObsDistanceStats, str_glue("Analysis_inputs/Search_Effort/iNaturalist_Observations/trace_distance_stats.csv"), na = "", row.names = FALSE)

# https://stackoverflow.com/questions/34990298/r-clear-output-file-before-writing
close( file( "Analysis_inputs/missing_gps_traces.txt", open="w" ) )
lapply(missingTraces, cat, "\n", file="Analysis_inputs/missing_gps_traces.txt", append=TRUE)

# Benchmarking
bench.end <- Sys.time()

cat("Processed ", length(unique(condensedWithTarget$effortId)), " unique search efforts in ", format(bench.end - bench.start), "\n")
cat("Expected search efforts: ", length(unique(effort$effortId)), "\n")
cat("Expected total search effort across all targets: ", sum(effort$Duration.x.Observers.mins * 60 / 1000), "ks\n")
cat("Recorded total search effort across all targets: ", sum(condensedWithTarget$search_effort), "ks\n")

source ("scripts/plotSearchEffort.R")

# Figure for "The total area covered by search effort" - search in effective habitat is computed at the end of Analyse.R
searchArea <- nrow (uniqueCondensed <- condensedWithTarget %>% filter(target %in% allTargets) %>% distinct(cell_id))
cat("Total number of cells covered by targetted search effort ", searchArea)

# Use "condensedWithTarget" generated at the end of Synthesize to compute distinct search effort figure for target species
condensedWithoutTarget <- condensedWithTarget %>% filter(target %in% allTargets) %>%
  group_by(effortId, cell_id) %>% slice(1) %>%
  ungroup() %>%
  select(-target)

wg("Total distinct search effort for targetted species: {round(sum(condensedWithoutTarget$search_effort), 2)}ks")

distinct_observers <- effort %>% filter(Target.Species %in% allTargets) %>%
  separate_rows(Observers, sep = ",") %>%   # Step 1: Split by comma
  mutate(Observers = trimws(Observers)) %>% # Step 2: Trim leading/trailing spaces
  distinct(Observers) %>%                   # Step 3: Get distinct names
  summarise(num_distinct_observers = n(),   # Step 4: Count distinct names
            distinct_observers = list(Observers))

cat("Recorded effort from ", distinct_observers$num_distinct_observers, " distinct observers")
