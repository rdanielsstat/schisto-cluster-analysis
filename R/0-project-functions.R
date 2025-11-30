# ------------------------------------------------------------------------------
# Project: Schistosomiasis Cluster Randomized Trial Analysis
# Author: Rob Daniels (rdanielsstat@gmail.com)
# Description: Defines project functions.
#-------------------------------------------------------------------------------

# Aggregates missing values per year, arm, and cluster (vid), then summarizes
# across clusters
make_na_summary <- function(data, var) {
  var <- enquo(var)
  
  data %>%
    group_by(year, arm, vid) %>%
    summarize(
      n_psac           = n_distinct(pid),
      measurements_var = sum(!is.na(!!var)),
      na_var           = sum(is.na(!!var)),
      pct_na_var       = 100 * na_var / n_psac,
      .groups = "drop"
    ) %>%
    group_by(year, arm) %>%
    summarize(
      n_villages     = n(),
      n_psac         = sum(n_psac),
      n_measurements = sum(measurements_var),
      na_total       = sum(na_var),
      mean_pct_na    = round(mean(pct_na_var), 1),
      sd_pct_na      = round(sd(pct_na_var), 1),
      min_pct_na     = round(min(pct_na_var), 1),
      q1_pct_na      = round(quantile(pct_na_var, 0.25), 1),
      median_pct_na  = round(median(pct_na_var), 1),
      q3_pct_na      = round(quantile(pct_na_var, 0.75), 1),
      max_pct_na     = round(max(pct_na_var), 1),
      .groups = "drop"
    ) %>%
    mutate(variable = quo_name(var), .before = 1)
}

# Summarizes counts of measurements and missing values per year
make_meas_summary <- function(data, var) {
  var <- enquo(var)
  
  data %>%
    group_by(year) %>%
    summarize(
      n_psac         = n_distinct(pid),
      n_measurements = sum(!is.na(!!var)),
      na_var         = sum(is.na(!!var)),
      pct_na_var     = round(100 * na_var / n_psac, 1),
      .groups = "drop"
    ) %>%
    mutate(
      n_psac         = format(n_psac, big.mark = ","),
      n_measurements = format(n_measurements, big.mark = ","),
      variable = quo_name(var),
      .before = 1
    )
}

# Summarizes continuous blood- and stool-based measurements per year and arm,
# pooled across PSAC
make_cont_summary <- function(data, var) {
  var <- enquo(var)
  
  data %>%
    group_by(year, arm) %>%
    summarize(
      n_psac     = n_distinct(pid),
      n_measures = sum(!is.na(!!var)),
      mean       = round(mean(!!var, na.rm = TRUE), 1),
      sd         = round(sd(!!var, na.rm = TRUE), 1),
      min        = round(min(!!var, na.rm = TRUE), 1),
      q1         = round(quantile(!!var, 0.25, na.rm = TRUE), 1),
      median     = round(median(!!var, na.rm = TRUE), 1),
      q3         = round(quantile(!!var, 0.75, na.rm = TRUE), 1),
      max        = round(max(!!var, na.rm = TRUE), 1),
      .groups = "drop"
    ) %>%
    mutate(variable = quo_name(var), .before = 1)
}

# Plot histogram of a continuous variable by arm and year
plot_hist_by_year_arm <- function(data, var, bins = 30) {
  var <- enquo(var)
  var_name <- quo_name(var)
  
  data <- data %>% filter(is.finite(!!var))
  
  ggplot(data, aes(x = !!var)) +
    geom_histogram(bins = bins,
                   color = "white",
                   fill = "steelblue") +
    facet_grid(arm ~ year) +
    theme_minimal() +
    labs(
      x = var_name,
      y = "Count",
      title = paste("Distribution of", var_name, "by Year and Arm")
    )
}

# Calculates pooled prevalence per year and arm
make_prev_summary <- function(data, var) {
  var <- enquo(var)
  
  data %>%
    group_by(year, arm) %>%
    summarize(
      n_psac = n_distinct(pid),
      n_measures = sum(!is.na(!!var)),
      n_positive = sum(!!var, na.rm = TRUE),
      prevalence = round(n_positive / n_measures, 3),
      .groups = "drop"
    ) %>%
    mutate(variable = quo_name(var), .before = 1)
}

# Table 1 helper function: column values for individual-level binary variables
make_binary_values <- function(data, var) {
  var <- enquo(var)
  var_name <- quo_name(var)
  
  data %>%
    group_by(arm) %>%
    summarize(
      n_pos   = sum(!!var == 1, na.rm = TRUE),
      n_total = sum(!is.na(!!var)),
      pct     = round(100 * n_pos / n_total, 1),
      .groups = "drop"
    ) %>%
    mutate(label = paste0(n_pos, " (", pct, ")")) %>%
    select(arm, label) %>%
    pivot_wider(names_from = arm, values_from = label)
}

# Table 1 helper function: column values for cluster-level binary variables
make_cluster_binary_values <- function(data, var) {
  var <- enquo(var)
  
  data %>%
    group_by(arm, vid) %>%
    summarize(
      n_positive = sum(!!var == 1, na.rm = TRUE),
      n_measured = sum(!is.na(!!var)),
      cluster_pct = 100 * n_positive / n_measured,
      .groups = "drop"
    ) %>%
    group_by(arm) %>%
    summarize(
      mean_pct = mean(cluster_pct),
      sd_pct   = sd(cluster_pct),
      .groups = "drop"
    ) %>%
    mutate(label = sprintf("%.1f ± %.1f", mean_pct, sd_pct)) %>%
    select(arm, label) %>%
    pivot_wider(names_from = arm, values_from = label)
}

# sessionInfo()