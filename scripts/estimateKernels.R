library(stringr)
library(dplyr)
library(HDInterval)
library(brms)
library(rstan)

# Script to apply Bayesian non-linear regression to determine kernel width parameter
# gamma given data on successful species detection, producing results in Supplementary Materials
# section 3.1.2

source("Scripts/utils.R")

setwd(rprojroot::find_rstudio_root_file())

recordfiles <- c("A_formosa_detections_distances_to_first_records.csv",
             "C_attenuata_detections_distances_to_first_records.csv",
             "L_virginicum_detections_distances_to_first_records.csv",
             "P_montana_detections_distances_to_first_records.csv",
             "P_unalascensis_detections_distances_to_first_records.csv",
             "T_dichotomum_detections_distances_to_first_records.csv")

# Define the formula relating occupancy to distance via decay rate parameter
formula <- bf(occupancy ~ q * exp(-decay * distance),
              q + decay ~ 1, 
              nl = TRUE)

# Experimental formula to additionally regress search effort weighting - results are currently unstable
formula2 <- bf(occupancy ~ ((alpha * search) / (q + alpha * search)) * exp(-decay * distance),
               q + decay + alpha ~ 1, 
               nl = TRUE)

# Define priors for the parameters
priors <- c(prior(normal(0, 1), nlpar = "q", lb = 0),
            prior(normal(0, 1), nlpar = "decay", lb = 0)
#           prior(normal(1, 10), nlpar = "alpha", lb = 0)
            )

estimate_kernel <- function (recordfile) {
  
  # Load observed data
  records <- read.csv(str_glue("Analysis_inputs/{recordfile}"))
  
  # Ensure data are formatted correctly
  records$distance <- as.numeric(records$distance)
  records$occupancy <- as.numeric(records$occupancy)
  records$search <- as.numeric(records$search_eff)
  
  brmfit <- brm(
    formula = formula,
    data = records,
    family = bernoulli("identity"),
    prior = priors,
    iter = 2000,  # Number of iterations
    warmup = 1000,  # Warmup period for sampling
    chains = 4,  # Number of chains
    cores = 4,  # Number of cores for parallel computation
    seed = 123  # For reproducibility
  )
  
  wg("Fitted decay model for {recordfile}")
  
  print(brmfit)
  
  summary <- summary(brmfit$fit, pars=c("b_decay_Intercept"))$summary
  
  wg("Central estimated rate is {round(summary[,'mean'], 2)}, 95% HPD interval between {round(summary[,'2.5%'], 2)}, {round(summary[,'97.5%'], 2)}]")

  list_of_draws <- extract(brmfit$fit)
  decaydraw <- list_of_draws$b_decay
  
  # Approximate density as per https://stackoverflow.com/questions/28077500/find-the-probability-density-of-a-new-data-point-using-density-function-in-r
  decaydensity <- density(decaydraw)

  mode <- decaydensity$x[which(decaydensity$y == max(decaydensity$y))]
  wg("Modal posterior density at {round(mode, 2)}")
  
  decay_at <- function (x) {
    approx(decaydensity$x, decaydensity$y, xout=x)$y
  }
      
  round_decay_rates <- c(0, 0.01, 0.05, 0.1, 0.5, 1, 1.5, 2, 3, 5, 10, 20)
  
  rounddensity <- sapply(round_decay_rates, decay_at)
  
  maxroundlike = round_decay_rates[which.max(rounddensity)]
  
  wg("Maximum likelihood rounded decay rate: {maxroundlike}")
  
  m = strsplit(recordfile, '_')
  target <- paste(m[[1]][1], m[[1]][2], sep='_')
  
  plot(decaydensity$x, decaydensity$y, type="l", xlab = "Kernel value in km", ylab = "Kernel likelihood", main = str_glue("Posterior density for search effort distance kernel for {target}"))
  
  wg("")
  
}

for (recordfile in recordfiles) {
  estimate_kernel(recordfile)
}
