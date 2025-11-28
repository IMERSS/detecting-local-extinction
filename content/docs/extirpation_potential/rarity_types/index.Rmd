---
title: Rarity types
description: Insights from metapopulation theory
math: true
weight: 2
---

We assigned distance decay functions to target plants a priori based on our natural
history knowledge of target plants, and their pattern of occurrence within the region.
To do this, we considered occupancy as a fourth dimension of rarity, following Crisfield et
al. (2024) in their adaptation of Rabinowitz rarity types (Kruckeburg & Rabinowitz, 1985). 

In the Rabinowitz typology, species rarity is evaluated based on geographic range (large/small),
habitat specificity (wide/narrow) and population size (dominant/non-dominant); occupancy is
added by Crisfield et al. (2024) as a species’ frequency of occurrence in habitat patches within
its range. We considered ‘geographic range’ regionally, as limited to within the Gulf and San
Juan islands, ‘habitat specificity’ as limited to woodland and coastal meadow habitats,
‘population size’ as abundance within habitat patches, and occupancy as the species' overall
frequency of occurrence across habitat patches in the region.

Ratings, and their corresponding kernels, were assigned based on our experience
observing target plants in the field and by reviewing their known regional distribution using
herbarium and iNaturalist records. We assigned steep kernels to low occupancy species and
shallow kernels to higher occupancy species, considering the other dimensions of rarity as well
in this approach. The kernels assigned to undetected species were then compared with those
inferred for detected species using our second approach.

| Species                   | Rarity / Habitat Notes |
|---------------------------|-------------------------|
| *Crassula connata*        | Very low occupancy. Typically found in localised patches within a habitat patch; absent from most islands; widely dispersed across the larger islands of Vancouver and San Juan. |
| *Meconella oregana*       | Very low occupancy. Absent from most islands; moderately distributed on the southern tip of Vancouver Island but only known from single localities on other islands where it is highly local within a patch when found. |
| *Perideridia montana*     | Low occupancy. Widely distributed on the southern tip of Vancouver Island, but idiosyncratic distribution on smaller islands; often locally abundant and widely distributed within habitat patches when found; sometimes restricted to a narrower microhabitat (swales) in drier sites. |
| *Trifolium dichotomum*    | Low occupancy. Found on a few islands where records are highly clustered; locally abundant to common in patches where found, not widely distributed within patches when found. |
| *Aquilegia formosa*       | Low occupancy. Mostly found on larger islands where populations are spatially clustered, though widely distributed; preference as deer forage may mask distribution. |
| *Castilleja attenuata*    | Low occupancy. Sparsely distributed on smaller islands but widely distributed on the southern tip of Vancouver Island. |
| *Plagiobothrys tenellus*  | Low occupancy. Sparsely distributed on larger islands; often locally abundant and widely distributed within habitat patches when found. |
| *Platanthera unalascensis*| Moderate occupancy. Sparsely distributed on larger islands but widely distributed on the southern tip of Vancouver Island. |
| *Lepidium virginicum*     | Moderate occupancy. Fairly broadly distributed across islands and habitat patches within islands, though infrequently occurring. |
| *Primula pauciflora*      | Moderate occupancy. Found on a few widely scattered islands; localities highly clustered within islands, where it is often locally common and widely distributed within patches when found. |

{{% imgproc Crassula_connata Fill "2400x600" %}}
Crassula connata (Image credit: Daniel
Hetzel)
{{% /imgproc %}}

For example, *Crassula connata* is known
only from the Gulf and San Juan Islands in the region, where it is disjunct from its more
geographically widespread range in California. Second, it has narrow habitat specificity within
coastal meadow and woodland communities, occurring in compacted vernal pools in coastal
rock outcrops and slopes. These microhabitats are typically localized to relatively small patches
that are infrequently occurring in coastal meadow habitats. Third, given the species’ small size,
they are often clustered in dense patches a few meters in diameter, so typically have extremely
limited distribution within a larger coastal meadow patch. Thus, even while many hundreds of
plants may be present, the species is typically non-dominant within the larger coastal meadow
flora. Finally, it has a highly infrequent pattern of occupancy in the region. Given its infrequent,
random distribution and the infrequent occurrence of its habitat—both within meadow
habitats and across islands—we gave it a very low occupancy probability and assigned it a very
steep kernel as our prior.
