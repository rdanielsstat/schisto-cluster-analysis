# ------------------------------------------------------------------------------
# Project: Schistosomiasis Cluster Randomized Trial Analysis
#          (NCIRE position assessment, October 2025)
# Author: Rob Daniels (rdanielsstat@gmail.com)
# Description: Produces descriptive summaries of study data.
# - Counts of pre-school age children (PSAC) per year, arm, summarized across
#   villages
# - Summaries of missing data for blood- and stool-based measures
# - Counts of measures at baseline and follow-up visits
# - Continuous variable summaries (blood- and stool-based, age)
# - Basic distribution plots (histograms)
# - Prevalence estimates by year and arm using positivity indicators
#-------------------------------------------------------------------------------

source(paste0(here::here(), "/0-config.R"))
source(paste0(here::here(), "/R/1-process-data.R"))

# Pre-school age children (PSAC) counts per year, arm; with summary statistics
# across villages (clusters)
mbita_schisto %>%
  group_by(year, arm, vid) %>%
  summarize(n_psac = n_distinct(pid), .groups = "drop") %>%
  group_by(year, arm) %>%
  summarize(
    n_villages  = n(),
    total_psac  = sum(n_psac),
    mean_psac   = mean(n_psac),
    sd_psac     = sd(n_psac),
    min_psac    = min(n_psac),
    q1_psac     = quantile(n_psac, 0.25),
    median_psac = median(n_psac),
    q3_psac     = quantile(n_psac, 0.75),
    max_psac    = max(n_psac),
    .groups = "drop"
  )
# On average 36-48 PSAC per village at each time point; 9 minimum for at
# least one time-point; 75 maximum for at least two time-points

# Percent missing values for blood- and stool-based measures per year and arm,
# summarized across vids (SEA, Sm25, Sm-EPG, etc.)
make_na_summary(mbita_schisto, sea)
make_na_summary(mbita_schisto, sm25)
make_na_summary(mbita_schisto, sm_epg)
make_na_summary(mbita_schisto, sea_pos)
make_na_summary(mbita_schisto, sm25_pos)
make_na_summary(mbita_schisto, kk_pos)
# No missing values for blood-based measures; relatively low number of missing
# for the stool-based measure, 2014 CWT treatment arm had 13.5% (98 / 725)
# missing total with one village having 29% missing

# Counts of measurements and missing values per year
make_meas_summary(mbita_schisto, sea)
make_meas_summary(mbita_schisto, sm25)
make_meas_summary(mbita_schisto, sm_epg)
# 13% missing values in 2014 for stool-based measure

# Assessment question: How many children were measured at baseline (2012) and
# in subsequent survey visits based on blood- and stool-based measures of
# infection? How complete were the measurements?

# Answer: 1120, 1187, and 1356 at baseline, 2013, and 2014 respectively for
# blood-based measurements (no missing)
# 1072, 1172, and 1182 at baseline, 2013, and 2014 respectively for stool-based
# measurements; 4.3% missing at baseline, 1.3% missing in 2013, and 12.8%
# missing in 2014

# Prevalence by age category for all PSAC
mbita_schisto %>%
  group_by(agecat) %>%
  summarize(n_sea_or_sm25 = sum(!is.na(sea_or_sm25_pos)),
            n_sea_or_sm25_pos = sum(sea_or_sm25_pos),
            n_kk = sum(!is.na(kk_pos)),
            n_kk_pos = sum(kk_pos, na.rm = TRUE),
            .groups = "drop") %>%
  mutate(sea_or_sm25_prev = 
           sprintf("%1.1f", n_sea_or_sm25_pos / n_sea_or_sm25 * 100),
         kk_prev =  sprintf("%1.1f", n_kk_pos / n_kk * 100),
         group = as.character(agecat)) %>%
  select(group, n_sea_or_sm25, n_sea_or_sm25_pos, sea_or_sm25_prev,
         n_kk, n_kk_pos, kk_prev)

# Quantitative measurement summary statistics at year, arm level
make_cont_summary(mbita_schisto, sea)
make_cont_summary(mbita_schisto, sm25)
make_cont_summary(mbita_schisto, sm_epg)

# Plot histograms of blood- and stool-based measures
# Pooled across all PSAC
hist(mbita_schisto$sea, main = "SEA distribution", xlab = "SEA")
hist(mbita_schisto$sm25, main = "Sm25 distribution", xlab = "Sm25")
hist(mbita_schisto$sm_epg, main = "Sm EPG distribution", xlab = "SmEPG")
# Many 0s for all 3 measures, highly skewed right for all 3; looks easiest to
# distinguish signal for SEA

# Histograms per year, arm
plot_hist_by_year_arm(mbita_schisto, sea)
plot_hist_by_year_arm(mbita_schisto, sea, bins = 20)

plot_hist_by_year_arm(mbita_schisto, sm25)
plot_hist_by_year_arm(mbita_schisto, sm25, bins = 10)

plot_hist_by_year_arm(mbita_schisto, sm_epg)
plot_hist_by_year_arm(mbita_schisto, sm_epg, bins = 10)
# Many 0s for all 3 measures, highly skewed right for all 3


# Assessment question: For quantitative variables, is there anything you see
# about their distribution that might be important to consider in any
# downstream analysis?

# Answer: All three variables are highly skewed, which could affect assumptions
# of normality in downstream analyses. Transformations such as log or square
# root may be necessary, and appropriate statistical methods that account for
# skewed distributions should be considered when modeling or testing
# differences.


# Age (yrs) at year and arm level
make_cont_summary(mbita_schisto, agey)


# Calculate pooled prevalence per year, arm using positivity indicators
make_prev_summary(mbita_schisto, sea_pos)
make_prev_summary(mbita_schisto, sm25_pos)
make_prev_summary(mbita_schisto, sea_or_sm25_pos)
make_prev_summary(mbita_schisto, kk_pos)
# Moderate difference between treatment groups for SEA


# Proportion male
make_prev_summary(mbita_schisto, male)
# Well-balanced across treatment groups

sessionInfo()