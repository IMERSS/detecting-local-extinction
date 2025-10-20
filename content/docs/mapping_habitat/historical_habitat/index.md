---
title: Defining historical habitat patches
description: Situating target species in the context of historical habitat patches
categories: [Examples]
tags: [test, docs]
weight: 2
---





## Mapping target species

XXXXXXX

## Defining area of habitat patches based on occurrence records

Each historical occurrence record can be associated with a patch of habitat
to which the occurrence can be generalised. 

Our analysis pipeline provides an algorithic means of determining this habitat
based on intersecting the coordinate uncertainty circle associated with the
historical occurrence record with the site classification mapping used to 
represent habitat.

However, this algorithmic system often produces inappropriate results when
contextual knowledge of the historical habitat is taken into account, and our
pipeline provides two main routes for overriding this automatic determination
based on supplying entries in the [historical_habitat.csv](https://drive.google.com/file/d/1DVTOppn58YA-c8Om7hVQo_ehiay73Xp7/view?usp=drive_link)
file.

Firstly, a selection of manually chosen grid cells can be provided by correlating
the historical population id with chosen grid cells ids in the ``cell_id`` column.
These grid cells ids are computed using the overall project grid frame as managed
by the utilties in [geomUtil.R](https://github.com/IMERSS/biodiversity-change-protocol/tree/main/scripts/geomUtil.R).

Secondly, a coarse polygon may be delineated around the historical habitat and 
stored in a GeoJSON file whose name is referenced in the ``filter_region`` column
in [historical_habitat.csv](https://drive.google.com/file/d/1DVTOppn58YA-c8Om7hVQo_ehiay73Xp7/view?usp=drive_link).
This coarse polygon will then be intersected with valid habitat as determined in the 
project's site classification mapping (for our analysis in 
[land class apr04.shp](https://drive.google.com/file/d/1DNMJottpGxnsVxR8qn8G4mcaAjHZ9eTw/view?usp=drive_link))

An example of this kind of override can be seen in the historical habitat analysis for
[Crassula connata](../example).


