# 20:20 Vision on Plant Extirpation:
# Tabulate search effort
# 2024-10-19
# Andrew Simon

# Set relative paths (https://stackoverflow.com/questions/13672720/r-command-for-setting-working-directory-to-source-file-location-in-rstudio)
setwd(paste0(dirname(rstudioapi::getActiveDocumentContext()$path), "/.."))

# Load packages

library(dplyr)
library(lubridate)
library(stringr)
library(tidyr)

# Read iNaturalist observations

effort <- read.csv("Analysis_inputs/Search_Effort/Search_Effort_Summary.csv")

effort <- effort[!(is.na(effort$Duration.x.Observer...Habitat.mins) | effort$Duration.x.Observer...Habitat.mins ==""), ]

# Remove taxa initially targeted but not included in research paper for various reasons

unique(effort$Target.Species)

effort <- subset(effort, !(Target.Species %in% c("Acmispon americanus", "Athysanus pusillus", "Hemitomes congestum", "Ranunculus aquatilis")))

# Total search effort

# Discrete events

discrete.events <- distinct(effort, Location, Date, .keep_all = TRUE)

nrow(discrete.events)

sum(discrete.events$Duration.x.Observer...Habitat.mins)/60

# Unique localities

unique(discrete.events$Location)

length(unique(discrete.events$Location))

# Unique observers

unique(discrete.events$Observers)

length(unique(discrete.events$Observers))

# Effort within historical collection sites

unique(discrete.events$Location)

effort.historical.sites <- subset(discrete.events, (Location %in% c("Bellhouse Park", "Bodega Ridge", "Mount Sutil", "Mount Galiano", "Stockade Hill", "Bluff Park", "Stockade Hill (north)", "North of Mount Sutil", "Georgeson Bay Road")))

sum(effort.historical.sites$Duration.x.Observers.mins)

# Check for errors in search effort calculations
# TO DO: Restore this test before publication (though Antranig has probably already validated this in his analysis; confirm)

# effort.test <- effort[!(is.na(effort$End) | effort$End ==""), ]
# effort.test <- effort.test[!(is.na(effort.test$Start) | effort.test$Start ==""), ]

# effort.test$Date <- as.Date(effort.test$Date)

# effort.test$Start <- hms::as.hms(effort.test$Start)
# effort.test$End <- hms::as.hms(effort.test$End)

# effort.test$Start <- paste(effort.test$Date, effort.test$Start, sep=' ')
# effort.test$End <- paste(effort.test$Date, effort.test$End, sep=' ')

# effort.test$Start <- as.POSIXct(effort.test$Start)
# effort.test$End <- as.POSIXct(effort.test$End)

# effort.test$time.diff <- difftime(effort.test$End,effort.test$Start, units="mins")

# effort.test$time.diff <- as.numeric(effort.test$time.diff)

# effort.test$error <- effort.test$time.diff - effort.test$Duration.mins

# Summarize search effort by species

effort.events <- effort %>% select(Target.Species, Date, Location)

effort.events <- effort %>% count(Target.Species)

AQUFOR <- effort %>% filter(Target.Species == 'Aquilegia formosa')

AQUFOR$effort <- sum(AQUFOR$Duration.x.Observer...Habitat.mins)
AQUFOR$sites <- length(unique(AQUFOR$Location))
AQUFOR$detections <- sum(AQUFOR$Detection)

CASATT <- effort %>% filter(Target.Species == 'Castilleja attenuata')

CASATT$effort <- sum(CASATT$Duration.x.Observer...Habitat.mins)
CASATT$sites <- length(unique(CASATT$Location))
CASATT$detections <- sum(CASATT$Detection)

CRACON <- effort %>% filter(Target.Species == 'Crassula connata')

CRACON$effort <- sum(CRACON$Duration.x.Observer...Habitat.mins)
CRACON$sites <- length(unique(CRACON$Location))
CRACON$detections <- sum(CRACON$Detection)

LEPVIR <- effort %>% filter(Target.Species == 'Lepidium virginicum')

LEPVIR$effort <- sum(LEPVIR$Duration.x.Observer...Habitat.mins)
LEPVIR$sites <- length(unique(LEPVIR$Location))
LEPVIR$detections <- sum(LEPVIR$Detection)

MECORE <- effort %>% filter(Target.Species == 'Meconella oregana')

MECORE$effort <- sum(MECORE$Duration.x.Observer...Habitat.mins)
MECORE$sites <- length(unique(MECORE$Location))
MECORE$detections <- sum(MECORE$Detection)

PERMON <- effort %>% filter(Target.Species == 'Perideridia montana')

PERMON$effort <- sum(PERMON$Duration.x.Observer...Habitat.mins)
PERMON$sites <- length(unique(PERMON$Location))
PERMON$detections <- sum(PERMON$Detection)

PRIPAU <- effort %>% filter(Target.Species == 'Primula pauciflora')

PRIPAU$effort <- sum(PRIPAU$Duration.x.Observer...Habitat.mins)
PRIPAU$sites <- length(unique(PRIPAU$Location))
PRIPAU$detections <- sum(PRIPAU$Detection)

PLAUNA <- effort %>% filter(Target.Species == 'Platanthera unalascensis')

PLAUNA$effort <- sum(PLAUNA$Duration.x.Observer...Habitat.mins)
PLAUNA$sites <- length(unique(PLAUNA$Location))
PLAUNA$detections <- sum(PLAUNA$Detection)

PLATEN <- effort %>% filter(Target.Species == 'Plagiobothrys tenellus')

PLATEN$effort <- sum(PLATEN$Duration.x.Observer...Habitat.mins)
PLATEN$sites <- length(unique(PLATEN$Location))
PLATEN$detections <- sum(PLATEN$Detection)

TRIDIC <- effort %>% filter(Target.Species == 'Trifolium dichotomum')

TRIDIC$effort <- sum(TRIDIC$Duration.x.Observer...Habitat.mins)
TRIDIC$sites <- length(unique(TRIDIC$Location))
TRIDIC$detections <- sum(TRIDIC$Detection)

summary <- rbind(AQUFOR,CASATT,CRACON,LEPVIR,MECORE,PERMON,PLATEN,PLAUNA,PRIPAU,TRIDIC)

summary$Detection <- NULL
summary$Location <- NULL
summary$Historical.site. <- NULL
summary$Habitat <- NULL
summary$Date <- NULL
summary$Record <- NULL
summary$Tracks <- NULL
summary$Observers <- NULL
summary$Observer.number <- NULL
summary$Start <- NULL
summary$End <- NULL
summary$Duration.mins <- NULL
summary$Duration.x.Observers.mins <- NULL
summary$Duration.x.Observer...Habitat.mins <- NULL
summary$Note <- NULL
summary$time.diff <- NULL
summary$error <- NULL
summary$Day.effortId <- NULL
summary$Month <- NULL

summary <- unique(summary)

summary <- left_join(summary, effort.events)

names(summary) <- c("taxa","effort (min)","sites","detections","events")

summary <- summary[,c(1,3,5,2,4)] 

write.csv(summary, "Analysis_outputs/search_effort_summary_pre_spatial_constraints.csv", row.names = FALSE)

table(summary)

