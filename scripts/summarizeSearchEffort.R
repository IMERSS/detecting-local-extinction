# R Script for summarizing search effort by target species

# Set relative paths (https://stackoverflow.com/questions/13672720/r-command-for-setting-working-directory-to-source-file-location-in-rstudio)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) 

# Load libraries

library(dplyr)

search_effort <- read.csv("../Analysis_inputs/Search_Effort/Search_Effort_Summary.csv")

summary.by.species <- search_effort %>% group_by(Target.Species, Month) %>% summarize(effort = sum(Duration.x.Observers.mins))

summary.by.species$effort <- summary.by.species$effort*0.06

summary.by.unique.event <- search_effort %>% group_by(Location, Date) %>% summarize(effort = sum(Duration.x.Observers.mins))

sum(summary.by.unique.event$effort)/60 # Total 2281.717 cumulative hours of search effort