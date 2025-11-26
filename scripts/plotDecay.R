library(dplyr)
library(ggplot2)

decayrecords <- read.csv("Analysis_inputs/A_formosa_detections_distances_to_first_records.csv")
decaydensity <- read.csv("Analysis_outputs/Intermediate/A_formosa_decay_density.csv")

# For A. formosa:
# Central estimated rate is 0.52, 95% HPD interval between 0.07, 1.39]
# Modal posterior density at 0.32
# Maximum likelihood rounded decay rate: 0.5

# Generate smooth curve over the range of observed distances
decay_curve <- data.frame(
  distance = seq(min(decayrecords$distance),
                 max(decayrecords$distance),
                 length.out = 500)
) %>% mutate(occupancy_prob = exp(-0.5 * distance))


fitplot <- ggplot() +
  geom_line(
    data = decay_curve,
    aes(x = distance, y = occupancy_prob,
        color = "Fitted occupancy probability via kernel value"),
    size = 1.2
  ) +
  geom_point(
    data = decayrecords,
    aes(x = distance, y = occupancy,
        color = "Detection or Non-detection"),
    size = 2
  ) +
  scale_color_manual(
    name = "",
    values = c(
      "Detection or Non-detection" = "black",
      "Fitted occupancy probability via kernel value" = "blue"
    )
  ) +
  labs(
    title = "Occupancy Probability by Distance",
    x = "Distance",
    y = "Occupancy Probability"
  ) +
  theme_minimal()


fitplot

densityplot <- ggplot(decaydensity, aes(x, y)) +
  geom_line() +
  labs(
    x = "Kernel value in km^-1",
    y = "Kernel posterior density",
    title = "Posterior density for search effort distance kernel for Aquilegia formosa"
  ) +
  theme_minimal()

densityplot
