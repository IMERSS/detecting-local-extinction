library(ggplot2)
library(ggpubr)
library(extrafont)

# This script generates the paper's Table 5 showing priors and posteriors for the 4 undetected taxa of interest

loadfonts() # Use 'loadfonts(device = "win")' on Windows machine

toPlot <- list(list(name = "Plagiobothrys tenellus", community = 66),
            list(name = "Meconella oregana", community = 55),
            list(name = "Primula pauciflora", community = 77),
            list(name = "Crassula connata", community = 44))

onePlot <- function (thisTarget, community) {
  
  x <- seq(0, 1, length.out = 100)

  solowPriorRec <- allPriorStats[allPriorStats$Population == community, ]
  expRec <- allPriorStats %>% filter(Population == 0 & target == thisTarget)
  posteriorRec <- allStats[allStats$Population == community, ]
  #potRec <- allStats %>% filter(Population == 0 & target == thisTarget)
  allRec <- allStats %>% filter(Population == "all" & target == thisTarget)

  # Swap around alpha and beta for display
  solow_prior_y <- dbeta(x, shape1 = as.numeric(solowPriorRec$beta), shape2 = as.numeric(solowPriorRec$alpha))
  exp_prior_y <- dbeta(x, shape1 = as.numeric(expRec$beta), shape2 = as.numeric(expRec$alpha))
  all_posterior_y <- dbeta(x, shape1 = as.numeric(allRec$beta), shape2 = as.numeric(allRec$alpha))
  posterior_y <- dbeta(x, shape1 = as.numeric(posteriorRec$beta), shape2 = as.numeric(posteriorRec$alpha))
  
  ggplot() + 
    geom_line(aes(x = x, y = solow_prior_y, color = "Solow Prior"), size = 1, linetype = "22") +
    geom_line(aes(x = x, y = exp_prior_y, color = "Solow and Distance Prior"), size = 1, linetype = "22") +
    geom_line(aes(x = x, y = all_posterior_y, color = "All Habitat Posterior"), size = 1, linetype = "solid") +
    geom_line(aes(x = x, y = posterior_y, color = "Historical Habitat Posterior"), size = 1, linetype = "solid") +
    scale_color_manual(values = c("Solow Prior" = "#4fabeb", 
                                  "Solow and Distance Prior" = "#5DEB4F", 
                                  "All Habitat Posterior" = "#FF8C00", 
                                  "Historical Habitat Posterior" = "#5a7d9a"), 
                       name = "Densities") +
    labs(title = thisTarget,
         x = "Extirpation probability",
         y = "Density") +
    theme_minimal(base_family = "Arial") +
    theme(
      legend.position = "right", 
      text = element_text(size = 12), # Reduced overall font size
      legend.key.width = unit(2, "line"),
      plot.title = element_text(size = 14), 
      axis.title = element_text(size = 12), # Decreased x and y labels
      axis.title.x = element_text(margin = margin(t = 10)), # Add space between x-axis label and ticks
      axis.title.y = element_text(margin = margin(r = 10)), # Add space between y-axis label and ticks
      legend.title = element_text(size = 12),
      legend.text = element_text(size = 10)
    )
}

p1 <- onePlot(toPlot[[1]]$name, toPlot[[1]]$community)
p2 <- onePlot(toPlot[[2]]$name, toPlot[[2]]$community)
p3 <- onePlot(toPlot[[3]]$name, toPlot[[3]]$community)
p4 <- onePlot(toPlot[[4]]$name, toPlot[[4]]$community)

allp <- ggpubr::ggarrange(p1, p2, p3, p4, ncol = 2, nrow = 2, common.legend = TRUE, legend = "bottom")

print (allp)

ggsave("Analysis_outputs/Figures/Figure_5_beta_targets.png", dpi = 1000, units = "in", bg="white",
       height = 6, width = 9)
