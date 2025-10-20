setwd(paste0(dirname(rstudioapi::getActiveDocumentContext()$path), "/.."))

# When working from GitHub, this script should be run before synthesizing Analysis_inputs using synthesizeSearchEffort.R to fetch
# bulky inputs from Google Drive

# If you get an authorization error, run drive_auth() from the console to go to browser's authentication afresh

source("scripts/utils.R")

# From location IMERSS Research Projects/Community Research Projects/2020-2023 - 20:20 Plant Surveys/Data/Analysis/Habitat_model
# https://drive.google.com/drive/folders/1XGzMHXQzpuvvSbnsx7Y1ZGDrpt6oadW6
downloadGdriveFolder("1XGzMHXQzpuvvSbnsx7Y1ZGDrpt6oadW6", "Analysis_inputs/Habitat_model", FALSE)

# From location IMERSS Research Projects/Community Research Projects/2020-2023 - 20:20 Plant Surveys/Data/Analysis/Occurrences
# https://drive.google.com/drive/folders/1U7H0o_feGWy-Etxt53w6upL2fWyTfWi2
downloadGdriveFolder("1U7H0o_feGWy-Etxt53w6upL2fWyTfWi2", "Analysis_inputs/Occurrences", FALSE)
