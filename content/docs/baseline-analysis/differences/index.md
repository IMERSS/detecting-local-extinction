---
title: Comparing data
description: The difference that makes the difference
categories: [Examples, Placeholders]
tags: [test, docs]
weight: 3
---





## Identifying potential changes

Differences between historical and contemporary biodiversity data could potentially indicate change in a system:

* Historically reported species that have not been seen in the last 20--40 years are generally considered 'historical populations' whose persistence is considered questionable ([Nature Serve 2025](https://help.natureserve.org/biotics/Content/Record_Management/Element_Files/Element_Tracking/ETRACK_Definitions_of_Heritage_Conservation_Status_Ranks.htm?utm_source=chatgpt.com))
* Conversely, species that suddenly appear in a biodiversity record may signal a recent dispersal, colonization or invasion event

Here, we focus specifically on "species at large", *i.e.*, historically reported species that have gone undetected in recent decades.

### Summarize historical baseline data

### Historical records

How many species were historically reported for Galiano Island, prior to the beginning of the Biodiversity Galiano project?


``` r
library(dplyr)
library(lubridate)

summary <- read.csv("Analysis_Inputs/Galiano_Tracheophyta_summary_reviewed_2024-10-07.csv")

reported <- summary %>% filter(reportingStatus == 'reported')
confirmed <- summary %>% filter(reportingStatus == 'confirmed')
historical.reports <- bind_rows(reported, confirmed)

n_hist <- nrow(historical.reports)
cat("There were", n_hist, 
    "species historically known to Galiano Island, prior to the beginning of the Biodiversity Galiano project.")
```

```
## There were 607 species historically known to Galiano Island, prior to the beginning of the Biodiversity Galiano project.
```


``` r
confirmed <- confirmed %>%
  mutate(year.confirmed = as.numeric(substr(firstObservediNat, 1, 4)))

confirmed.prior.2020 <- confirmed %>% filter(year.confirmed < 2020)
n_confirmed <- nrow(confirmed.prior.2020)

cat(n_confirmed, "of these historical records had been confirmed by 2020.")
```

```
## 432 of these historical records had been confirmed by 2020.
```


``` r
at.large.2020 <- anti_join(historical.reports, confirmed.prior.2020)
n_at_large <- nrow(at.large.2020)

cat("This left", n_at_large, "species still at large by 2020.")
```

```
## This left 175 species still at large by 2020.
```


``` r
at.large.2020 <- at.large.2020 %>%
  filter(as.Date(eventDate) < as.Date("2000-01-01"))
n_unseen20 <- nrow(at.large.2020)

cat("Of these,", n_unseen20, 
    "species had not been reported for more than twenty years prior to 2020.")
```

```
## Of these, 74 species had not been reported for more than twenty years prior to 2020.
```

Populations or species that have gone undetected for many years may be considered at risk of extirpation. However, there are other important criteria that communities may consider before such an assessment is made.
