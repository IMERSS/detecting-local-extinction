---
title: Example I
description: 'Plagiobothrys tenellus'
math: true
date: 2025-10-14
weight: 3
---
<link href="{{< blogdown/postref >}}index_files/pagedtable/css/pagedtable.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/pagedtable/js/pagedtable.js"></script>





Here we consider the sighting rate of one of our targets, *Plagiobothrys tenellus*, as an example. We will use this sighting rate
to test the null hypothesis that extinction has not occurred.

First, we assume 1958, the date of the first botanical collection on Galiano Island, as the earliest date that observations of this species might have been made, and 2019—the date that our study began—as the time frame bracketing our analysis.


<div class="para">$T_0$ = 1958</div>
<div>$T$ = 2019</div>

How many times has this species been observed historically on Galiano Island?


``` r
records <- read.csv("Analysis_Inputs/Galiano_Island_vascular_plant_records_2024-10-09.csv")

# Filter for Plagiobothrys tenellus records
Ptenellus <- records %>% filter(scientificName == 'Plagiobothrys tenellus')

# Omit list records, retaining only vouchered specimens
Ptenellus <- Ptenellus %>% filter(basisOfRecord != 'MaterialCitation')
n_Ptenellus <- nrow(Ptenellus)

cat("Plagiobothrys tenellus has been observed", 
    n_Ptenellus, "times historically.")
```

```
## Plagiobothrys tenellus has been observed 3 times historically.
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["scientificName"],"name":[1],"type":["chr"],"align":["left"]},{"label":["scientificNameAuthorship"],"name":[2],"type":["chr"],"align":["left"]},{"label":["taxonID"],"name":[3],"type":["int"],"align":["right"]},{"label":["kingdom"],"name":[4],"type":["chr"],"align":["left"]},{"label":["phylum"],"name":[5],"type":["chr"],"align":["left"]},{"label":["class"],"name":[6],"type":["chr"],"align":["left"]},{"label":["order"],"name":[7],"type":["chr"],"align":["left"]},{"label":["suborder"],"name":[8],"type":["chr"],"align":["left"]},{"label":["infraorder"],"name":[9],"type":["lgl"],"align":["right"]},{"label":["superfamily"],"name":[10],"type":["lgl"],"align":["right"]},{"label":["family"],"name":[11],"type":["chr"],"align":["left"]},{"label":["genus"],"name":[12],"type":["chr"],"align":["left"]},{"label":["subgenus"],"name":[13],"type":["lgl"],"align":["right"]},{"label":["specificEpithet"],"name":[14],"type":["chr"],"align":["left"]},{"label":["infraspecificEpithet"],"name":[15],"type":["chr"],"align":["left"]},{"label":["taxonRank"],"name":[16],"type":["chr"],"align":["left"]},{"label":["institutionCode"],"name":[17],"type":["chr"],"align":["left"]},{"label":["collectionCode"],"name":[18],"type":["lgl"],"align":["right"]},{"label":["catalogNumber"],"name":[19],"type":["chr"],"align":["left"]},{"label":["datasetName"],"name":[20],"type":["chr"],"align":["left"]},{"label":["occurrenceID"],"name":[21],"type":["int"],"align":["right"]},{"label":["recordedBy"],"name":[22],"type":["chr"],"align":["left"]},{"label":["recordNumber"],"name":[23],"type":["chr"],"align":["left"]},{"label":["fieldNumber"],"name":[24],"type":["chr"],"align":["left"]},{"label":["eventDate"],"name":[25],"type":["chr"],"align":["left"]},{"label":["year"],"name":[26],"type":["int"],"align":["right"]},{"label":["month"],"name":[27],"type":["int"],"align":["right"]},{"label":["day"],"name":[28],"type":["int"],"align":["right"]},{"label":["basisOfRecord"],"name":[29],"type":["chr"],"align":["left"]},{"label":["locality"],"name":[30],"type":["chr"],"align":["left"]},{"label":["locationRemarks"],"name":[31],"type":["chr"],"align":["left"]},{"label":["island"],"name":[32],"type":["chr"],"align":["left"]},{"label":["stateProvince"],"name":[33],"type":["chr"],"align":["left"]},{"label":["country"],"name":[34],"type":["chr"],"align":["left"]},{"label":["countryCode"],"name":[35],"type":["chr"],"align":["left"]},{"label":["decimalLatitude"],"name":[36],"type":["dbl"],"align":["right"]},{"label":["decimalLongitude"],"name":[37],"type":["dbl"],"align":["right"]},{"label":["coordinateUncertaintyInMeters"],"name":[38],"type":["int"],"align":["right"]},{"label":["georeferencedBy"],"name":[39],"type":["chr"],"align":["left"]},{"label":["georeferenceVerificationStatus"],"name":[40],"type":["chr"],"align":["left"]},{"label":["georeferenceProtocol"],"name":[41],"type":["chr"],"align":["left"]},{"label":["georeferenceRemarks"],"name":[42],"type":["chr"],"align":["left"]},{"label":["habitat"],"name":[43],"type":["chr"],"align":["left"]},{"label":["verbatimDepth"],"name":[44],"type":["lgl"],"align":["right"]},{"label":["verbatimElevation"],"name":[45],"type":["chr"],"align":["left"]},{"label":["occurrenceStatus"],"name":[46],"type":["chr"],"align":["left"]},{"label":["samplingProtocol"],"name":[47],"type":["chr"],"align":["left"]},{"label":["occurrenceRemarks"],"name":[48],"type":["chr"],"align":["left"]},{"label":["individualCount"],"name":[49],"type":["lgl"],"align":["right"]},{"label":["sex"],"name":[50],"type":["lgl"],"align":["right"]},{"label":["establishmentMeans"],"name":[51],"type":["chr"],"align":["left"]},{"label":["provincialStatus"],"name":[52],"type":["chr"],"align":["left"]},{"label":["nationalStatus"],"name":[53],"type":["chr"],"align":["left"]},{"label":["identifiedBy"],"name":[54],"type":["chr"],"align":["left"]},{"label":["identificationQualifier"],"name":[55],"type":["lgl"],"align":["right"]},{"label":["identificationRemarks"],"name":[56],"type":["chr"],"align":["left"]},{"label":["previousIdentifications"],"name":[57],"type":["lgl"],"align":["right"]},{"label":["bibliographicCitation"],"name":[58],"type":["chr"],"align":["left"]},{"label":["associatedReferences"],"name":[59],"type":["chr"],"align":["left"]}],"data":[{"1":"Plagiobothrys tenellus","2":"(C.A. Mey. ex Ledeb.) A. Gray","3":"58066","4":"Plantae","5":"Tracheophyta","6":"Magnoliopsida","7":"Boraginales","8":"","9":"NA","10":"NA","11":"Boraginaceae","12":"Plagiobothrys","13":"NA","14":"tenellus","15":"","16":"species","17":"V","18":"NA","19":"V107519","20":"","21":"NA","22":"Harvey Janszen","23":"","24":"","25":"1980-04-11","26":"1980","27":"4","28":"11","29":"PreservedSpecimen","30":"Gulf Islands; Galiano Island; Mount Sutil","31":"","32":"Galiano Island","33":"British Columbia","34":"Canada","35":"CA","36":"48.87017","37":"-123.3800","38":"50","39":"","40":"verified by data custodian","41":"Coordinates generalized based on mapped locality information","42":"corrected; coordinates generalized based on locality and habitat information","43":"open bluffs","44":"NA","45":"","46":"present","47":"","48":"","49":"NA","50":"NA","51":"native","52":"S1? (2019)","53":"1-T (2011)","54":"Curtis Bjork","55":"NA","56":"","57":"NA","58":"","59":""},{"1":"Plagiobothrys tenellus","2":"(C.A. Mey. ex Ledeb.) A. Gray","3":"58066","4":"Plantae","5":"Tracheophyta","6":"Magnoliopsida","7":"Boraginales","8":"","9":"NA","10":"NA","11":"Boraginaceae","12":"Plagiobothrys","13":"NA","14":"tenellus","15":"","16":"species","17":"V","18":"NA","19":"V119988","20":"","21":"NA","22":"Harvey Janszen","23":"","24":"","25":"1982-05-10","26":"1982","27":"5","28":"10","29":"PreservedSpecimen","30":"Gulf Islands; Galiano Island; Bodega Hill","31":"","32":"Galiano Island","33":"British Columbia","34":"Canada","35":"CA","36":"48.95735","37":"-123.5300","38":"50","39":"","40":"verified by data custodian","41":"Coordinates generalized based on mapped locality information","42":"corrected; coordinates generalized based on locality information; coordinates may be improved based on other detections of this species at Bodega Ridge","43":"open bluff","44":"NA","45":"","46":"present","47":"","48":"","49":"NA","50":"NA","51":"native","52":"S1? (2019)","53":"1-T (2011)","54":"Curtis Bjork","55":"NA","56":"","57":"NA","58":"","59":""},{"1":"Plagiobothrys tenellus","2":"(C.A. Mey. ex Ledeb.) A. Gray","3":"58066","4":"Plantae","5":"Tracheophyta","6":"Magnoliopsida","7":"Boraginales","8":"","9":"NA","10":"NA","11":"Boraginaceae","12":"Plagiobothrys","13":"NA","14":"tenellus","15":"","16":"species","17":"UBC","18":"NA","19":"V233784","20":"","21":"NA","22":"Frank Lomer","23":"98-2","24":"","25":"1998-04-10","26":"1998","27":"4","28":"10","29":"PreservedSpecimen","30":"Galiano Island, Bodega Ridge, trail west of Cottage Way","31":"","32":"Galiano Island","33":"British Columbia","34":"Canada","35":"CA","36":"48.95667","37":"-123.5292","38":"NA","39":"David Rowswell","40":"","41":"Verbatim from Collector/Sheet","42":"","43":"Dry, open southwest-facing slope","44":"NA","45":"188 m","46":"present","47":"","48":"population = 400-500; erect annual with white flowers","49":"NA","50":"NA","51":"native","52":"S1? (2019)","53":"1-T (2011)","54":"Frank Lomer","55":"NA","56":"","57":"NA","58":"","59":""}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

<div class="para">$n$ = 3</div>

When was the most recent sighting?


``` r
records <- read.csv("Analysis_Inputs/Galiano_Island_vascular_plant_records_2024-10-09.csv")

# Identify the most recent sighting
recent_sighting <- max(Ptenellus$eventDate)

cat("Plagiobothrys tenellus was last observed in", 
    recent_sighting, ".")
```

```
## Plagiobothrys tenellus was last observed in 1998-04-10 .
```

<p>\(t_n = 1998\)<p>

<p>Below, the interactive calculator ascribes these to values to Solow's extinction equation. The resulting Bayes factor, \(B(t)\), favours the null hypothesis that extinction has not occurred. We also report our prior probability of presence, \(PP(t)\), and \(EP(t) = 1 - PP(t)\), our prior probability of extinction—which feed into subsequent analyses.</p>


<div class="solow-container">
<link rel="stylesheet" href="../../../css/solow.css">

<div class="input-group">
    <label for="solow-t0">T₀ (Beginning of record-keeping):</label>
    <input type="number" id="solow-t0" value="1958">
</div>

<div class="input-group">
    <label for="solow-tn">tₙ (Most recent sighting):</label>
    <input type="number" id="solow-tn" value="1998">
</div>

<div class="input-group">
    <label for="solow-T">T (Current time/study endpoint):</label>
    <input type="number" id="solow-T" value="2019">
</div>

<div class="input-group">
    <label for="solow-n">n (Number of observations):</label>
    <input type="number" id="solow-n" value="3" min="1">
</div>

<div class="results" id="solow-results">
    <div class="result-item">
        <span class="result-label">Bayes factor in favour of presence B(t):</span>
        <span class="result-value" id="solow-bt">--</span>
    </div>
    <div class="result-item">
        <span class="result-label">Prior probability of presence PP(t):</span>
        <span class="result-value" id="solow-pp">--</span>
    </div>
    <div class="result-item">
        <span class="result-label">Prior probability of absence EP(t):</span>
        <span class="result-value" id="solow-ep">--</span>
    </div>
</div>

</div>

<script src="../../../js/solow.js"></script>
