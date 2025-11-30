# ------------------------------------------------------------------------------
# Project: Schistosomiasis Cluster Randomized Trial Analysis
# Author: Rob Daniels (rdanielsstat@gmail.com)
# Description: Tests for difference between treatment arms post-treatment.
# Linear model and GEE model as sensitivity check.
#-------------------------------------------------------------------------------

source(paste0(here::here(), "/0-config.R"))
source(paste0(here::here(), "/R/1-process-data.R"))

# Calculate pooled sero-prevalence for 2013 and 2014 combined at the cluster,
# arm level
cluster_post <- mbita_schisto %>%
  filter(post == 1) %>%
  group_by(vid, arm) %>%
  summarize(
    n_pos = sum(sea_or_sm25_pos == 1),
    n_measured = sum(!is.na(sea_or_sm25_pos)),
    prev = if_else(n_measured > 0, n_pos / n_measured, NA_real_),
    .groups = "drop"
  )

# Observed mean pooled prevalence for each treatment group
cluster_post %>%
  group_by(arm) %>%
  summarize(
    n_clusters = n(),
    mean_prev = mean(prev, na.rm = TRUE),
    sd_prev   = sd(prev, na.rm = TRUE),
    median_prev = median(prev, na.rm = TRUE),
    iqr_prev = IQR(prev, na.rm = TRUE)
  )
# 0.092 difference between CWT and SBT (CWT group is lower)


png(paste0(here::here(), "/figures/cluster-prev-hist.png"), 
           width = 800, height = 400)
hist(cluster_post$prev, main = "Sero-prevalence distribution", 
     xlab = "Sero-prevalence")
dev.off()

# Fit a very simple linear model to test for differences in mean prevalence
lm_fit_cluster <- lm(prev ~ arm, data = cluster_post)
summary(lm_fit_cluster)

# Visualize residuals
# Save to figures folder
png(paste0(here::here(), "/figures/lm-diagnostic-plots.png"), 
    width = 800, height = 400)
par(mfrow = c(1, 2))
plot(lm_fit_cluster, which = 1)
plot(lm_fit_cluster, which = 2)
dev.off()

# Extract lm results
# Effect estimate with confidence interval and p-value:
lm_coef_est <- coef(lm_fit_cluster)["armCWT"]
lm_coef_est

# 95% confidence interval
lm_conf_int <- confint(lm_fit_cluster)["armCWT", ]
lm_conf_int

# p-value
lm_pval <- summary(lm_fit_cluster)$coefficients["armCWT", "Pr(>|t|)"]
lm_pval

# Print lm results nicely
cat(
  "Linear model (CWT vs SBT):\n",
  "Estimate:",
  round(lm_coef_est, 3),
  "\n",
  "95% CI: [",
  round(lm_conf_int[1], 3),
  ",",
  round(lm_conf_int[2], 3),
  "]\n",
  "p-value:",
  signif(lm_pval, 5),
  "\n"
)

# Sensitivity analysis with individual-level GEE model
post <- mbita_schisto %>%
  filter(post == 1)

# GEE with identity link: estimates prevalence difference directly
gee_cluster <- geepack::geeglm(
  sea_or_sm25_pos ~ arm,
  id = vid,
  data = post,
  family = binomial(link = "identity"),
  corstr = "exchangeable"
)

gee_cluster_summary <- summary(gee_cluster)
gee_cluster_summary

# Check fitted probabilities range
fitted_vals <- fitted(gee_cluster)
range(fitted_vals, na.rm = TRUE)
sum(fitted_vals < 0 | fitted_vals > 1, na.rm = TRUE)

# Extract and print results
gee_coef_est <- coef(gee_cluster_summary)["armCWT", "Estimate"]
gee_se <- coef(gee_cluster_summary)["armCWT", "Std.err"]
gee_pval <- coef(gee_cluster_summary)["armCWT", "Pr(>|W|)"]

# 95% CI using normal approximation
gee_lower <- gee_coef_est - 1.96 * gee_se
gee_upper <- gee_coef_est + 1.96 * gee_se

# Print GEE results nicely
cat(
  "GEE (CWT vs SBT):\n",
  "Estimate:",
  round(gee_coef_est, 3),
  "\n",
  "95% CI: [",
  round(gee_lower, 3),
  ",",
  round(gee_upper, 3),
  "]\n",
  "p-value:",
  signif(gee_pval, 3),
  "\n"
)

# Cluster sizes are small, standard errors may be biased downward for GEE
# results

# There is no statistically significant difference between groups

# Observed values
observed_tbl <- cluster_post %>%
  group_by(arm) %>%
  summarize(
    n_clusters = n(),
    mean_prev = mean(prev, na.rm = TRUE),
    sd_prev   = sd(prev, na.rm = TRUE),
    median_prev = median(prev, na.rm = TRUE),
    iqr_prev = IQR(prev, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    Analysis = paste0(arm, " (n = ", n_clusters, " clusters)"),
    Result = paste0(
      "Mean ",
      round(mean_prev, 3),
      " (SD ",
      round(sd_prev, 3),
      "); ",
      "Median ",
      round(median_prev, 3),
      " (IQR ",
      round(iqr_prev, 3),
      ")"
    ),
    `p-value` = ""
  ) %>%
  select(Analysis, Result, `p-value`)

# Model results table
model_tbl <- tribble(
  ~ Analysis,
  ~ Result,
  ~ `p-value`,
  "Linear model (cluster-level)",
  paste0(
    round(lm_coef_est, 3),
    " (95% CI ",
    round(lm_conf_int[1], 3),
    ", ",
    round(lm_conf_int[2], 3),
    ")"
  ),
  as.character(signif(lm_pval, 4)),
  "GEE (individual-level)",
  paste0(
    round(gee_coef_est, 3),
    " (95% CI ",
    round(gee_lower, 3),
    ", ",
    round(gee_upper, 3),
    ")"
  ),
  as.character(signif(gee_pval, 4))
)

# Combine observed and model results
table2 <- bind_rows(
  tibble(
    Analysis = "Observed cluster-level prevalence",
    Result = "",
    `p-value` = ""
  ),
  observed_tbl,
  tibble(
    Analysis = "Statistical comparisons",
    Result = "",
    `p-value` = ""
  ),
  model_tbl
)

# Create HTML table
tbl_html <- kable(
  table2,
  format = "html",
  escape = FALSE,
  caption = paste0(
    "Table 2. Observed and estimated differences in ",
    "sero-prevalence between CWT and SBT arms, ",
    "post-intervention period (2013–2014)."
  )
) %>%
  kable_styling(
    full_width = FALSE,
    bootstrap_options = c("striped", "hover", "condensed")
  ) %>%
  row_spec(c(1, nrow(observed_tbl) + 2), bold = TRUE)

tbl_html

save_kable(tbl_html, file = paste0(here::here(), "/tables/table2.html"))

# Interpretation:
# The observed mean post-intervention seroprevalence was slightly lower in the
# CWT arm (0.405) compared with the SBT arm (0.497). The primary linear model
# analysis estimated a difference of –0.092 (95% CI –0.268 to 0.083, p = 0.29),
# indicating no statistically significant difference between arms. Sensitivity
# analyses using a GEE model gave similar conclusions.

sessionInfo()