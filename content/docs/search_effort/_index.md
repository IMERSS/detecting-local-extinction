---
title: Search effort
description: Incorporating search effort
categories: [Examples, Placeholders]
tags: [test, docs]
weight: 5
---

Search effort is represented as a per-observer search time per gridded cell
represented in ksec. Search effort is applied only to valid potential
or historical habitat for the target taxon. Where the habitat model indicates
that only part of a grid cell is valid habitat, the imputed search effort
is scaled up proportionally.

```R
# From Analyse.R, 
# Assemble the cells which truly lie within the habitat together with their proportion of overlap
analyse_target <- function (thisTarget, detected = FALSE) {
  ....
  effortCells_intersect <- st_intersection((accepted_grouped_sf %>% 
     filter(search_effort > 0)), allHabitat) %>% 
     mutate(area = st_area(.) %>% 
     as.numeric(), area_prop = area / oneArea) %>%
     select(cell_id, area, area_prop) %>% 
     st_drop_geometry()

}
```
