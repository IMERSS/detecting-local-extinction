---
title: Representing habitat
description: Gridding land classification data
categories: [Examples, Placeholders]
tags: [test, docs]
weight: 4
sidebar:
  open: true
---

## Mapping habitat

Habitat can be represented in many ways, ranging from complex species distribution models 
to relatively simple ecosystem mapping or site classification data.

In this tutorial, we use high resolution (1:5,000 scale) site classification mapping 
to map habitat for our target species. This spatial data takes the shape of polygons 
circumscribing different ecosystem types or areas of land use. This versatile approach 
should be accessible to many communities, wherever land classification or terrestrial 
ecosystem mapping data are available. Otherwise, habitat can be mapped based on 
orthoimagery generated using a variety of methods (*e.g.*, satellite, drone).

### Filtering site classification mapping based on habitat types for target species

First, we select the site classifications representing suitable habitat for our targets:
woodlands (WD), cliffs (CL), herbaceous (HB) habitat types. These are extracted as polgyons, 
then converted to grid cells.

### Converting polygons to gridded representation of habitat

Polygons representing habitat for target species is then represented as grid cells. 
For this methodology, a key consideration is to ensure that the grid scale corresponds 
with the precision of features representing search effort (see next section).

