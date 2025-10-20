# Analysis of historical and community science data
# 2024-10-11
# Andrew Simon

# Load packages
library(sf)
library(geojsonsf)
library(dplyr)
library(readxl)
library(stringr)
library(viridis)
library(scales)

setwd(rprojroot::find_rstudio_root_file())

# Read summary

# How many species were historically reported for Galiano Island, prior to the beginning of the
# Biodiversity Galiano project?

summary <- read.csv("Analysis_inputs/Galiano_Tracheophyta_summary_reviewed_2024-10-07.csv")

reported <- summary %>% filter(reportingStatus == 'reported')
confirmed <- summary %>% filter(reportingStatus == 'confirmed')
historical.reports <- rbind(reported, confirmed)

nrow(historical.reports) # There were 607 species historically known to Galiano Island, prior to
# the beginning of the Biodiversity Galiano project

historical.reports.native <- historical.reports %>% filter(origin == 'native')

nrow(historical.reports.native) # There were 309 native plant species reported for Galiano Island
# prior to the beginning of the BioGaliano project

# How many species were documented by 2020?
  
confirmed$year.confirmed <- as.numeric(substr(confirmed$firstObserved, start = 1, stop = 4))

confirmed.prior.2020 <- confirmed %>% filter(year.confirmed < 2020)

confirmed.prior.2020$year.confirmed <- NULL

nrow(confirmed.prior.2020) # 432/607 historical records confirmed by 2020

at.large.2020 <- anti_join(historical.reports, confirmed.prior.2020)
nrow(at.large.2020) # 175 species remained at large by 2020

native.at.large.2020 <- at.large.2020 %>% filter(origin == 'native')
nrow(native.at.large.2020)

new <- summary %>% filter(grepl("new", reportingStatus))

new$year.new <- as.numeric(substr(new$firstObserved, start = 1, stop = 4))

new.prior.2020 <- new %>% filter(year.new < 2020)

new.prior.2020$year.new <- NULL

nrow(new.prior.2020) # 127 species reported new for Galiano by 2020

confirmed.and.new.prior.2020 <- rbind(confirmed.prior.2020, new.prior.2020)

nrow(confirmed.and.new.prior.2020) # 559 species observed on BioGaliano by 2020

known.plants.prior.2020 <- rbind(reported, confirmed.prior.2020, new.prior.2020)

nrow(known.plants.prior.2020) # A total of 667 species were reported for Galiano by 2020, 
# inc. historical and contemporary reports

confirmed.and.reported.prior.2020 <- rbind(reported, confirmed.prior.2020)

nrow(confirmed.and.reported.prior.2020)

## How much new data has been generated with the advent of iNaturalist?

observations <- read.csv("Analysis_inputs/Galiano_Island_vascular_plant_records_2024-10-09.csv")

records.pre.2020 <- observations %>% filter(year <2020)
records.2015.to.2020 <- records.pre.2020 %>% filter(year >=2015)
records.post.2020 <- observations %>% filter(year>=2020)
records.post.2015 <- observations %>% filter(year>=2015)
records.pre.2015 <- observations %>% filter(year<2015)
iNat.records.pre.2015 <- records.pre.2015 %>% filter(datasetName == 'iNaturalist')
historical.records <- anti_join(records.pre.2015, iNat.records.pre.2015)

bio.galiano.records.pre.2020 <- rbind(records.post.2015, iNat.records.pre.2015)
nrow(bio.galiano.records.pre.2020)
