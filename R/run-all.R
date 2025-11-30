# ------------------------------------------------------------------------------
# Project: Schistosomiasis Cluster Randomized Trial Analysis
# Author: Rob Daniels (rdanielsstat@gmail.com)
# Description: Master script to run all analysis scripts.
#-------------------------------------------------------------------------------

# base_path <- "INSERT YOUR BASE PATH HERE"  # <-- update this
base_path <- "/Users/rob/Projects/GitHub/schisto-analysis/" # <-- update this

setwd(base_path)

source("0-config.R", echo = TRUE)
source("R/0-project-functions.R", echo = TRUE)
source("R/1-process-data.R", echo = TRUE)
source("R/2-describe-data.R", echo = TRUE)
source("R/3-baseline-table1.R", echo = TRUE)
source("R/4-compare-groups.R", echo = TRUE)
source("R/5-permutation-test.R", echo = TRUE)
