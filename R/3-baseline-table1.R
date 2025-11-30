# ------------------------------------------------------------------------------
# Project: Schistosomiasis Cluster Randomized Trial Analysis
# Author: Rob Daniels (rdanielsstat@gmail.com)
# Description: Creates Table 1 for baseline individual- and cluster-level
# characteristics.
#-------------------------------------------------------------------------------

source(paste0(here::here(), "/0-config.R"))
source(paste0(here::here(), "/R/1-process-data.R"))

# Table 1

# Filter baseline year
baseline <- mbita_schisto %>% filter(year == 2012)

# Individual-level characteristics
# PSAC counts
psac_values <- baseline %>%
  count(arm) %>%
  mutate(pct = round(100 * n / nrow(baseline), 1),
         label = paste0(n, " (", pct, ")")) %>%
  select(arm, label) %>%
  pivot_wider(names_from = arm, values_from = label)

# Sex
sex_values <- baseline %>%
  count(arm, sex) %>%
  group_by(arm) %>%
  mutate(pct = round(100 * n / sum(n), 1),
         label = paste0(n, " (", pct, ")")) %>%
  ungroup() %>%
  select(sex, arm, label) %>%
  pivot_wider(names_from = arm, values_from = label)

# Age category
agecat_values <- baseline %>%
  count(arm, agecat) %>%
  group_by(arm) %>%
  mutate(pct = round(100 * n / sum(n), 1),
         label = paste0(n, " (", pct, ")")) %>%
  ungroup() %>%
  select(agecat, arm, label) %>%
  pivot_wider(names_from = arm, values_from = label)

# Age continuous
agey_values <- baseline %>%
  group_by(arm) %>%
  summarize(
    mean = mean(agey, na.rm = TRUE),
    sd   = sd(agey, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(label = sprintf("%.1f ± %.1f", mean, sd)) %>%
  select(arm, label) %>%
  pivot_wider(names_from = arm, values_from = label)

# Binary positivity variables
sea_pos_values         <- make_binary_values(baseline, sea_pos)
sm25_pos_values        <- make_binary_values(baseline, sm25_pos)
sea_or_sm25_pos_values <- make_binary_values(baseline, sea_or_sm25_pos)

# kk_pos non-missing counts
kk_nonmissing_values <- baseline %>%
  group_by(arm) %>%
  summarize(n_nonmiss = sum(!is.na(kk_pos)), .groups = "drop") %>%
  mutate(label = paste0("n = ", as.character(n_nonmiss))) %>%
  select(arm, label) %>%
  pivot_wider(names_from = arm, values_from = label)

kk_pos_values          <- make_binary_values(baseline, kk_pos)


# Cluster-level

# Cluster PSAC
cluster_psac_values <- baseline %>%
  group_by(vid, arm) %>%
  summarise(n_psac = n_distinct(pid), .groups = "drop") %>%
  group_by(arm) %>%
  summarise(
    psac_mean = mean(n_psac),
    psac_sd   = sd(n_psac),
    .groups = "drop"
  ) %>%
  mutate(label = sprintf("%.1f ± %.1f", psac_mean, psac_sd)) %>%
  select(arm, label) %>%
  pivot_wider(names_from = arm, values_from = label)

# Cluster male
cluster_male_values <- baseline %>%
  group_by(vid, arm) %>%
  summarise(
    n_male  = sum(sex == "male"),
    n_psac = n_distinct(pid),
    pct_male = 100 * n_male / n_psac,
    .groups = "drop"
  ) %>%
  group_by(arm) %>%
  summarise(
    mean_pct = mean(pct_male),
    sd_pct   = sd(pct_male),
    .groups = "drop"
  ) %>%
  mutate(label = sprintf("%.1f ± %.1f", mean_pct, sd_pct)) %>%
  select(arm, label) %>%
  pivot_wider(names_from = arm, values_from = label)


# Cluster age
cluster_agey_values <- baseline %>%
  group_by(vid, arm) %>%
  summarise(cluster_mean = mean(agey, na.rm = TRUE),
            .groups = "drop") %>%
  group_by(arm) %>%
  summarise(
    mean_of_means = mean(cluster_mean),
    sd_of_means   = sd(cluster_mean),
    .groups = "drop"
  ) %>%
  mutate(label = sprintf("%.1f ± %.1f", mean_of_means, sd_of_means)) %>%
  select(arm, label) %>%
  pivot_wider(names_from = arm, values_from = label)

# Cluster positivity variables
cluster_sea_pos_values <- make_cluster_binary_values(baseline, sea_pos)
cluster_sm25_pos_values <- make_cluster_binary_values(baseline, sm25_pos)
cluster_sea_or_sm25_pos_values <-
  make_cluster_binary_values(baseline, sea_or_sm25_pos)
cluster_kk_pos_values <- make_cluster_binary_values(baseline, kk_pos)

# Build table directly
table1 <- tribble(
  ~ Characteristic,
  ~ SBT,
  ~ CWT,
  "Individual-level",
  "",
  "",
  "PSAC, No. (%)",
  psac_values$SBT,
  psac_values$CWT,
  "Sex, No. (%)",
  "",
  "",
  "  Female",
  sex_values$SBT[sex_values$sex == "female"],
  sex_values$CWT[sex_values$sex == "female"],
  "  Male",
  sex_values$SBT[sex_values$sex == "male"],
  sex_values$CWT[sex_values$sex == "male"],
  "Age group, No. (%)",
  "",
  "",
  "  <1 year",
  agecat_values$SBT[agecat_values$agecat == "<1 year"],
  agecat_values$CWT[agecat_values$agecat == "<1 year"],
  "  1 year",
  agecat_values$SBT[agecat_values$agecat == "1 year"],
  agecat_values$CWT[agecat_values$agecat == "1 year"],
  "  2 years",
  agecat_values$SBT[agecat_values$agecat == "2 years"],
  agecat_values$CWT[agecat_values$agecat == "2 years"],
  "  3 years",
  agecat_values$SBT[agecat_values$agecat == "3 years"],
  agecat_values$CWT[agecat_values$agecat == "3 years"],
  "  4 years",
  agecat_values$SBT[agecat_values$agecat == "4 years"],
  agecat_values$CWT[agecat_values$agecat == "4 years"],
  "  5 years",
  agecat_values$SBT[agecat_values$agecat == "5 years"],
  agecat_values$CWT[agecat_values$agecat == "5 years"],
  "Age, mean ± SD, y",
  agey_values$SBT,
  agey_values$CWT,
  "Blood-based measures, No. (%)",
  "",
  "",
  "  SEA positive",
  sea_pos_values$SBT,
  sea_pos_values$CWT,
  "  Sm25 positive",
  sm25_pos_values$SBT,
  sm25_pos_values$CWT,
  "  SEA or Sm25 positive",
  sea_or_sm25_pos_values$SBT,
  sea_or_sm25_pos_values$CWT,
  "Stool-based measure, No. (%)",
  kk_nonmissing_values$SBT,
  kk_nonmissing_values$CWT,
  "  KK positive",
  kk_pos_values$SBT,
  kk_pos_values$CWT,
  "Cluster-level",
  "",
  "",
  "PSAC per village, mean ± SD",
  cluster_psac_values$SBT,
  cluster_psac_values$CWT,
  "Percent male per village, mean ± SD",
  cluster_male_values$SBT,
  cluster_male_values$CWT,
  "Mean village age, mean ± SD",
  cluster_agey_values$SBT,
  cluster_agey_values$CWT,
  "Blood-based measures, % per village, mean ± SD",
  "",
  "",
  "  SEA positive",
  cluster_sea_pos_values$SBT,
  cluster_sea_pos_values$CWT,
  "  Sm25 positive",
  cluster_sm25_pos_values$SBT,
  cluster_sm25_pos_values$CWT,
  "  SEA or Sm25 positive",
  cluster_sea_or_sm25_pos_values$SBT,
  cluster_sea_or_sm25_pos_values$CWT,
  "Stool-based measure, % per village, mean ± SD",
  "",
  "",
  "  KK positive",
  cluster_kk_pos_values$SBT,
  cluster_kk_pos_values$CWT,
)

# Deal with special formatting for HTML display
table1_html <- table1 %>%
  mutate(
    Characteristic = gsub("<", "&lt;", Characteristic),
    Characteristic =
      case_when(
        Characteristic %in% c("Individual-level", "Cluster-level") ~
          Characteristic,
        TRUE ~ gsub("^  ", "&nbsp;&nbsp;&nbsp;&nbsp;", Characteristic)
      )
  )

# Display with kableExtra
tbl1_final <- table1_html %>%
  kable(format = "html",
        escape = FALSE,
        align = c("l", "c", "c"),
        caption = paste0("Table 1. Individual- and cluster-level baseline ",
                         "characteristics and infection prevalence by ","
                         treatment arm.")
  ) %>%
  kable_styling(
    full_width = FALSE,
    position = "center",
    bootstrap_options = c("striped", "hover", "condensed")
  ) %>%
  row_spec(which(
    table1$Characteristic %in% c("Individual-level", "Cluster-level")
  ),
  bold = TRUE,
  extra_css = "border-bottom: 2px solid black;")

# Save as HTML file
save_kable(tbl1_final, file = paste0(here::here(), "/tables/table1.html"))

# Balance at baseline
# Cluster size:
# - Both arms have very similar average cluster sizes (35.9 vs 38.8 children
#   per cluster, with similar spread)
# Demographics:
# - Mean age of children is identical (3.5 with narrow SDs)
# - Proportion male is also almost the same (47.6% vs 46.3%)
# - These suggest excellent demographic balance
# Infection measures:
# - SEA prevalence is somewhat lower in the CWT arm (41.4%) than in the SBT
#   arm (51.1%), though the large standard deviations (29.3 vs 25.3) mean
#   there is substantial cluster-to-cluster variation and overlap
# - Sm25 prevalence (13.5% vs 14.4%) is nearly identical
# - KK prevalence is slightly lower in the CWT arm (24%) than in the
#   SBT arm (29%), with wide variability across clusters
# Overall, the groups are well-balanced at baseline in terms of demographics
# and cluster sizes. There are some modest differences in infection prevalence,
# but given the large SDs, these differences may not be statistically meaningful

# Reflection on design
# - This was a cluster randomized trial with 30 villages randomized 1:1 into two
#   arms
# - With only 15 clusters per arm, chance imbalances are more likely than in an
#   individually randomized trial with thousands of participants
# - The fact that demographic characteristics (age, sex, cluster size) are
#   balanced suggests that randomization worked well overall
# - The somewhat uneven baseline prevalence of SEA and Kato-Katz could be due
#   to natural variation between communities or limited number of clusters

# Conclusion
# The arms appear well balanced on demographic characteristics and cluster size.
# Some modest differences in baseline infection prevalence are present, which
# may not be unexpected given the relatively small number of clusters per arm or
# natural variation in infection rates among villages.

sessionInfo()
