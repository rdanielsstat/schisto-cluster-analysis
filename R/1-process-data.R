# ------------------------------------------------------------------------------
# Project: Schistosomiasis Cluster Randomized Trial Analysis
# Author: Rob Daniels (rdanielsstat@gmail.com)
# Description: Loads, merges, and pre-processes the main study data set. Defines
# factors and derived variables. Confirms key dimensions.
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Study data:
# 2 blood and 1 stool-based measure for 3663 children in 30 villages across
# 3 time-points ("survey visits") and 2 treatment arms
# Study design: cluster randomized trial with repeated cross-sectional surveys
# randomization at cluster (village) level (30 villages total)
# Treatment arms: 15 school-based treatment villages and 15 community-wide
# treatment villages
# Time-points: 2012 (baseline), 2013 and 2014 (post period); intervention
# occurred just after baseline
#-------------------------------------------------------------------------------

source(paste0(here::here(), "/0-config.R"))

# Read in data
mbita_psac <- read.csv(paste0(data_path, "/mbita_schisto.csv"))
mbita_spatial <- read.csv(paste0(data_path, "/mbita_spatial.csv"))

# Merge
mbita_schisto <- mbita_psac %>%
  left_join(mbita_spatial, by = "vid")

# Data set details
str(mbita_schisto)

# Additional processing
mbita_schisto <- mbita_schisto %>%
  mutate(
    pid  = as.character(pid),
    arm  = factor(arm, levels = c("SBT", "CWT")),
    # SBT as reference group
    sex  = factor(sex, levels = c("male", "female")),
    male = ifelse(sex == "male", 1, 0),
    # either sea or sm25 positive:
    sea_or_sm25_pos = ifelse(sea_pos == 1 |
                               sm25_pos == 1, 1, 0),
    agecat = cut(
      agey,
      breaks = c(0, 1, 2, 3, 4, 5, 6),
      labels = c("<1 year", "1 year", "2 years", "3 years", "4 years", 
                 "5 years")
    ),
    # create indicator for baseline/post intervention
    post = ifelse(year %in% c(2013, 2014), 1, 0)
  )

# View data
# View(mbita_schisto)

# Full data set summary
summary(mbita_schisto)

# Confirm new variable creation
with(mbita_schisto, table(sea_pos, sm25_pos))
with(mbita_schisto, table(sea_or_sm25_pos))

# Confirm pre-school age children (PSAC)
length(unique(mbita_schisto$pid))
# It is not distinguished in the data but some children may be the same at
# each time point

# Confirm number of years
length(unique(mbita_schisto$year))

# Confirm number of arms
length(unique(mbita_schisto$arm))

# Confirm number of villages
length(unique(mbita_schisto$vid))

sessionInfo()