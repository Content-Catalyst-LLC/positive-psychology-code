# Professional positive psychology and sustainability modeling scaffold
#
# This workflow is designed for psychologists, sustainability researchers,
# public-health researchers, social-policy analysts, and interdisciplinary
# teams using synthetic data for methods demonstration.
#
# It is not a clinical, diagnostic, therapeutic, workplace-screening,
# employment-selection, public-benefits, or individual well-being assessment tool.

suppressPackageStartupMessages({
  library(tidyverse)
  library(psych)
  library(lme4)
  library(lmerTest)
  library(broom.mixed)
  library(emmeans)
  library(performance)
})

script_path <- tryCatch(normalizePath(sys.frame(1)$ofile), error = function(e) NA_character_)
base_dir <- if (!is.na(script_path)) dirname(dirname(script_path)) else getwd()
raw_dir <- file.path(base_dir, "data", "raw")
output_dir <- file.path(base_dir, "outputs", "tables")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

panel <- readr::read_csv(
  file.path(raw_dir, "positive_psychology_sustainability_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "sustainable_flourishing_indicator_bank.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  psychological_functioning = c("psych1", "psych2", "psych3", "psych4"),
  relational_support = c("rel1", "rel2"),
  institutional_capacity = c("inst1", "inst2"),
  health_capacity = c("health1", "health2"),
  adaptive_capacity = c("adapt1", "adapt2"),
  cumulative_strain = c("strain1", "strain2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  alpha_result <- tryCatch(
    psych::alpha(indicator_bank[, cols], warnings = FALSE, check.keys = FALSE),
    error = function(e) NULL
  )

  tibble(
    indicator_family = scale_name,
    n_indicators = length(cols),
    raw_alpha = if (is.null(alpha_result)) NA_real_ else alpha_result$total$raw_alpha,
    standardized_alpha = if (is.null(alpha_result)) NA_real_ else alpha_result$total$std.alpha,
    average_r = if (is.null(alpha_result)) NA_real_ else alpha_result$total$average_r
  )
})

readr::write_csv(reliability_rows, file.path(output_dir, "r_indicator_reliability_report.csv"))

panel_scored <- panel %>%
  mutate(
    region = as.factor(region),
    community_type = as.factor(community_type),
    year = as.integer(year)
  ) %>%
  filter(complete.cases(
    life_satisfaction,
    meaning,
    purpose,
    autonomy,
    social_trust,
    belonging,
    institutional_quality,
    public_service_access,
    ecological_stability,
    environmental_exposure,
    health_index,
    mental_health_index,
    adaptive_capacity,
    insecurity_load,
    inequality_index
  )) %>%
  mutate(across(
    c(
      life_satisfaction,
      meaning,
      purpose,
      autonomy,
      social_trust,
      belonging,
      institutional_quality,
      public_service_access,
      ecological_stability,
      health_index,
      mental_health_index,
      adaptive_capacity
    ),
    ~ as.numeric(scale(.x)),
    .names = "{.col}_z"
  )) %>%
  mutate(across(
    c(environmental_exposure, insecurity_load, inequality_index),
    ~ as.numeric(scale(.x)),
    .names = "{.col}_z"
  )) %>%
  mutate(
    psychological_functioning = rowMeans(
      select(., life_satisfaction_z, meaning_z, purpose_z, autonomy_z),
      na.rm = TRUE
    ),
    relational_support = rowMeans(
      select(., social_trust_z, belonging_z),
      na.rm = TRUE
    ),
    institutional_capacity = rowMeans(
      select(., institutional_quality_z, public_service_access_z),
      na.rm = TRUE
    ),
    ecological_condition = ecological_stability_z - environmental_exposure_z,
    health_capacity = rowMeans(
      select(., health_index_z, mental_health_index_z),
      na.rm = TRUE
    ),
    cumulative_strain = rowMeans(
      select(., insecurity_load_z, inequality_index_z),
      na.rm = TRUE
    ),
    sustainable_flourishing =
      psychological_functioning +
      relational_support +
      institutional_capacity +
      ecological_condition +
      health_capacity +
      adaptive_capacity_z -
      cumulative_strain,
    year_c = as.numeric(scale(year, center = TRUE, scale = FALSE)),
    adaptive_c = as.numeric(scale(adaptive_capacity_z, center = TRUE, scale = FALSE)),
    trust_c = as.numeric(scale(social_trust_z, center = TRUE, scale = FALSE)),
    institutions_c = as.numeric(scale(institutional_capacity, center = TRUE, scale = FALSE)),
    ecology_c = as.numeric(scale(ecological_condition, center = TRUE, scale = FALSE)),
    health_c = as.numeric(scale(health_capacity, center = TRUE, scale = FALSE)),
    strain_c = as.numeric(scale(cumulative_strain, center = TRUE, scale = FALSE))
  )

flourishing_items <- panel_scored %>%
  select(
    life_satisfaction_z,
    meaning_z,
    purpose_z,
    autonomy_z,
    social_trust_z,
    belonging_z
  )

flourishing_alpha <- psych::alpha(flourishing_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    raw_alpha = flourishing_alpha$total$raw_alpha,
    standardized_alpha = flourishing_alpha$total$std.alpha,
    average_r = flourishing_alpha$total$average_r
  ),
  file.path(output_dir, "r_flourishing_domain_alpha.csv")
)

model_sf <- lmer(
  sustainable_flourishing ~
    year_c +
    adaptive_c +
    trust_c +
    institutions_c +
    ecology_c +
    health_c -
    strain_c +
    trust_c:institutions_c +
    ecology_c:strain_c +
    adaptive_c:strain_c +
    (1 + year_c | region),
  data = panel_scored,
  REML = FALSE
)

fixed_effects <- broom.mixed::tidy(model_sf, effects = "fixed", conf.int = TRUE)
random_effects <- broom.mixed::tidy(model_sf, effects = "ran_pars", conf.int = TRUE)

trust_institution_margins <- emmeans(
  model_sf,
  ~ trust_c | institutions_c,
  at = list(
    trust_c = c(-1, 0, 1),
    institutions_c = c(-1, 0, 1),
    adaptive_c = 0,
    ecology_c = 0,
    health_c = 0,
    strain_c = 0,
    year_c = 0
  )
)

ecology_strain_margins <- emmeans(
  model_sf,
  ~ ecology_c | strain_c,
  at = list(
    ecology_c = c(-1, 0, 1),
    strain_c = c(-1, 0, 1),
    adaptive_c = 0,
    trust_c = 0,
    institutions_c = 0,
    health_c = 0,
    year_c = 0
  )
)

adaptive_strain_margins <- emmeans(
  model_sf,
  ~ adaptive_c | strain_c,
  at = list(
    adaptive_c = c(-1, 0, 1),
    strain_c = c(-1, 0, 1),
    trust_c = 0,
    institutions_c = 0,
    ecology_c = 0,
    health_c = 0,
    year_c = 0
  )
)

regional_summary <- panel_scored %>%
  group_by(region) %>%
  summarize(
    mean_sustainable_flourishing = mean(sustainable_flourishing, na.rm = TRUE),
    mean_psychological_functioning = mean(psychological_functioning, na.rm = TRUE),
    mean_relational_support = mean(relational_support, na.rm = TRUE),
    mean_institutional_capacity = mean(institutional_capacity, na.rm = TRUE),
    mean_ecological_condition = mean(ecological_condition, na.rm = TRUE),
    mean_health_capacity = mean(health_capacity, na.rm = TRUE),
    mean_cumulative_strain = mean(cumulative_strain, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_sustainable_flourishing))

diagnostics <- performance::check_model(model_sf, check = c("normality", "homogeneity"))

readr::write_csv(fixed_effects, file.path(output_dir, "r_sustainable_flourishing_fixed_effects.csv"))
readr::write_csv(random_effects, file.path(output_dir, "r_sustainable_flourishing_random_effects.csv"))
readr::write_csv(as.data.frame(trust_institution_margins), file.path(output_dir, "r_trust_institution_estimated_margins.csv"))
readr::write_csv(as.data.frame(ecology_strain_margins), file.path(output_dir, "r_ecology_strain_estimated_margins.csv"))
readr::write_csv(as.data.frame(adaptive_strain_margins), file.path(output_dir, "r_adaptive_strain_estimated_margins.csv"))
readr::write_csv(regional_summary, file.path(output_dir, "r_sustainable_flourishing_regional_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_sustainable_flourishing_scored_panel.csv"))

message("Professional R positive psychology and sustainability workflow complete.")
message("Outputs written to: ", output_dir)
