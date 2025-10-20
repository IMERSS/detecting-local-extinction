github_repo <- "https://github.com/IMERSS/biodiversity-change-protocol"

site_rel <- function (path) {
  paste0(github_repo, "/tree/main", path)
}

trim_effortId <- function (df) {
  df %>%
    mutate(effortId = if_else(
      nchar(effortId) > 10,
      paste0(substr(effortId, 1, 10), "..."),
      effortId
    ))
}

plot_site_beta <- function (rec, thisTarget) {
  
  x <- seq(0, 1, length.out = 100)
  
  # Swap around alpha and beta for display
  y <- dbeta(x, shape1 = as.numeric(rec$beta), shape2 = as.numeric(rec$alpha))
  
  ggplot() + 
    geom_line(aes(x = x, y = y, color = "Posterior Density"), linewidth = 1, linetype = "solid") +
    scale_color_manual(values = c("Posterior Density" = "#4fabeb"), 
                       name = "") +
    labs(title = thisTarget,
         x = "Extirpation probability",
         y = "Density") +
    theme_minimal(base_family = "Arial") +
    theme(
      legend.position = "none", 
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
