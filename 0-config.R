# ------------------------------------------------------------------------------
# Project: Schistosomiasis Cluster Randomized Trial Analysis
# Author: Rob Daniels (rdanielsstat@gmail.com)
# Description: Configuration file. Loads required R packages, assigns paths, and
# sources shared project functions.
#-------------------------------------------------------------------------------

# load required packages
library(here)
library(dplyr)
library(tidyr)
library(rlang)
library(ggplot2)
library(broom)
library(geepack)
library(sandwich)
library(knitr)
library(knitr)
library(kableExtra)
library(tibble)

# define data path
data_path = paste0(here::here(), "/data/final")

# load project functions
source(paste0(here::here(), "/R/0-project-functions.R"))

# sessionInfo()