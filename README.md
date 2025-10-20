# Detecting Local Extinction

This repository contains code and data supporting the paper
_Detecting extirpation: a localised approach to a global problem_ and
its supplementary materials, accepted for publication by [Plants, People, Planet](https://nph.onlinelibrary.wiley.com/journal/25722611).

Documentation for the algorithms can be browsed in the [GitHub Pages site](https://imerss.github.io/detecting-local-extinction) for this repository.

## Introduction 

### Prerequisites

To run the analyses you will need a reasonably recent version of the [R](https://www.r-project.org/) programming system - 
versions 4.3 and later have been tested.

If running these analyses from the Dryad repository, this dataset is self-contained; you will be able to run the
synthesis and analysis pipeline immediately.

If running these analyses from a GitHub checkout, some bulky analysis inputs need to be sourced from the project's
Google Drive [Analysis](https://drive.google.com/drive/folders/1wlFzWg0EWqgSLMO_eEoVgfUv8A1AXMMa) folder - please contact
the paper's authors for access.

### Main entry points
The main entry points to the data synthesis and analysis pipelines are the two scripts 
[scripts/synthesizeSearchEffort.R](scripts/synthesizeSearchEffort.R) and [scripts/Analyse.R](scripts/Analyse.R).

These rely on common configuration held in the script [scripts/config.R](scripts/config.R) which sets up core parameters
such as the grid scale, grid bounds and taxa of interest.

## Synthesizing analysis inputs

Running [scripts/synthesizeSearchEffort.R](scripts/synthesizeSearchEffort.R) makes use of the following raw materials:

* Central Search Effort table at [Analysis_inputs/Search_Effort/Search_Effort_Summary.csv](Analysis_inputs/Search_Effort/Search_Effort_Summary.csv)
indexing all search effort events, each of which may be associated with a full GPS Trace, or else
a trace to be imputed from iNaturalist observations matched on time range and observers
* iNaturalist observations to be synthesized into search effort traces through linear interpolation held at
[Analysis_inputs/Search_Effort/iNaturalist_Observations/iNat-obs-2024-11-04.csv](Analysis_inputs/Search_Effort/iNaturalist_Observations/iNat-obs-2024-11-04.csv)
* GPS traces held at [Analysis_inputs/Search_Effort/GPS_Data/GPS_Tracks](Analysis_inputs/Search_Effort/GPS_Data/GPS_Tracks)
and indexed in [Analysis_inputs/Search_Effort/GPS_Data/GPS_Data_table.csv](Analysis_inputs/Search_Effort/GPS_Data/GPS_Data_table.csv)

Supplementary input files:

* Patch file censoring iNaturalist observations with dubious coordinates
[Analysis_inputs/Search_Effort/iNaturalist_Observations/iNat_obs_patch.csv](Analysis_inputs/Search_Effort/iNaturalist_Observations/iNat_obs_patch.csv)
* Table normalising iNaturalist handles and observer names [Analysis_inputs/Search_Effort/iNaturalist_Observations/Observer_Names.csv](Analysis_inputs/Search_Effort/iNaturalist_Observations/Observer_Names.csv)

Principal outputs:
* Pooled complete search effort density accrued across all traces in [Analysis_inputs/Search_Effort/Search_Effort_Density/all.shp](Analysis_inputs/Search_Effort/Search_Effort_Density/all.shp)

* For each search event for which a trace is to be synthesized from iNaturalist observations,
** A filtered list of those observations in [Analysis_inputs/Search_Effort/iNaturalist_Observations/iNat_surveys](Analysis_inputs/Search_Effort/iNaturalist_Observations/iNat_surveys)
** The synthesized traces as KML in Analysis_inputs/Search_Effort/Synthesized_Search_Effort_Traces/{traceId}.kml

* For each taxon of interest configured in config.R, a summary of relevant search effort per grid cell in
* [Analysis_inputs/Search_Effort/Target_Summaries](Analysis_inputs/Search_Effort/Target_Summaries)

Supplementary outputs:
* Various diagnostics in [Analysis_inputs/Search_Effort/iNaturalist_Observations](Analysis_inputs/Search_Effort/iNaturalist_Observations) for georeferencing of iNaturalist traces

## Running the analysis

Running the main analysis routine  [scripts/Analyse.R](scripts/Analyse.R) produces the table of extirpation probabilities
[Analysis_outputs/extirpation_statistics.csv](Analysis_outputs/extirpation_statistics.csv).

It makes use of the following raw materials:

* Target taxon specific summaries in [Analysis_inputs/Search_Effort/Target_Summaries](Analysis_inputs/Search_Effort/Target_Summaries)
* Historical plant records in [Analysis_inputs/Occurrences/target_plant_records_2024.csv]([Analysis_inputs/Occurrences/target_plant_records_2024.csv])
* Habitat assignments in [Analysis_inputs/Habitat_model](Analysis_inputs/Habitat_model) 
* Prior sighting rate probabilities derived via Solow in [Analysis_inputs/direct_solow_dat.csv](Analysis_inputs/direct_solow_dat.csv)
* Exponential distance kernel values in [Analysis_inputs/Search_Effort/exp_weight.csv](Analysis_inputs/Search_Effort/exp_weight.csv)

Principal output:

* Table of inferred extinction probabilities and confidence ranges in [Analysis_outputs/extirpation_statistics.csv](Analysis_outputs/extirpation_statistics.csv).
This contains an entry for every taxon configured in [scripts/config.R](scripts/config.R) focalTargets and every distinct
observation site of these taxa in [Analysis_inputs/Occurrences/target_plant_records_2024.csv]([Analysis_inputs/Occurrences/target_plant_records_2024.csv])

Additional output:
 
* [Analysis_outputs/search_effort_phenology.csv](Analysis_outputs/search_effort_phenology.csv) which contains phenological data sourcing Table 1
in the main paper

Other functions dump various other figures, tables and statistics referred to in the paper and supplementary materials,
as described in the [Analysis_outputs/provenance.txt](Analysis_outputs/provenance.txt) file accompanying the outputs.

Figures 1 and 2 of the article were finalized in QGIS and Photoshop using the spatial outputs available in this repository.
