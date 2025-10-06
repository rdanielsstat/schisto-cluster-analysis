# ------------------------------------------------------------------------------
# Project: Schistosomiasis Cluster Randomized Trial Analysis
#          (NCIRE position assessment, October 2025)
# Author: Rob Daniels (rdanielsstat@gmail.com)
# Description: Perform a permutation test for the difference between treatment
# arms post-treatment.
#-------------------------------------------------------------------------------

source(paste0(here::here(), "/0-config.R"))
source(paste0(here::here(), "/R/1-process-data.R"))
source(paste0(here::here(), "/R/4-compare-groups.R"))

# Bonus challenge

# Calculate observed difference for test statistic
# Unit of analysis is the cluster, calculate the mean for each arm
obs_diff <-
  with(cluster_post, mean(prev[arm == "CWT"]) - mean(prev[arm == "SBT"]))

# Set-up values to run test
set.seed(1001)  # for reproducibility
n_perm <- 50000  # number of permutations
perm_diff <- numeric(n_perm) # vector to hold all permuted statistics

# Vector of cluster-level prevalence
prev <- cluster_post$prev

# Original treatment arms
arm_orig <- cluster_post$arm

for (i in 1:n_perm) {
  # shuffle cluster labels, keeping cluster prevalences fixed
  arm_perm <- sample(arm_orig)
  
  # compute difference in means for permuted arms
  perm_diff[i] <- mean(prev[arm_perm == "CWT"]) - mean(prev[arm_perm == "SBT"])
}

# Calculate p-value as proportion more extreme than test statistic
p_perm <- mean(abs(perm_diff) >= abs(obs_diff))
p_perm

# Plot histogram
png(paste0(here::here(), "/figures/permutation-test.png"), 
    width = 800, height = 400)

hist(
  perm_diff,
  breaks = 50,
  main = "Permutation distribution of mean difference",
  xlab = "Difference in mean prevalence (CWT − SBT)",
  col = "lightgray",
  border = "white"
)

# Shade extreme values (two-sided)
extreme <- abs(perm_diff) >= abs(obs_diff)
hist(
  perm_diff[extreme],
  breaks = 50,
  col = "red",
  border = "white",
  add = TRUE
)

# Add observed statistic line
abline(v = obs_diff,
       col = "darkred",
       lwd = 2)

# Add caption with p-value
mtext(
  paste0("Permutation p-value (two-sided) = ", round(p_perm, 3)),
  side = 3,
  line = 0.5,
  cex = 0.9
)

dev.off()

# Assessment question: How does your inference compare with your results from
# the previous section?

# Answer: The design-based permutation test confirms the findings from the
# linear model and GEE analyses.

sessionInfo()