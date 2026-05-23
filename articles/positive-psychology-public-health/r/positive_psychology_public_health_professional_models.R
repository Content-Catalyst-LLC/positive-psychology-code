# Professional positive psychology and public health modeling scaffold
#
# This workflow is designed for psychologists, public-health researchers,
# social-determinants analysts, and interdisciplinary teams using synthetic
# data for methods demonstration.
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
})

script_path <- tryCatch(normalizePath(sys.frame(1)$ofile), error = function(e) NA_character_)
base_dir <- if (!is.na(script_path)) dirname(dirname(script_path)) else getwd()
raw_dir <- file.path(base_dir, "data", "raw")
output_dir <- file.path(base_dir, "outputs", "tables")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

panel <- readr::read_csv(
  file.path(raw_dir, "positive_psychology_public_health_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "public_health_indicator_bank.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  subjective_wellbeing = c("swb1", "swb2", "swb3"),
  health_functioning = c("health1", "health2", "health3"),
  social_trust = c("trust1", "trust2", "trust3"),
  housing_stability = c("housing1", "housing2", "housing3"),
  care_access = c("care1", "care2", "care3"),
  stress_load = c("stress1", "stress2", "stress3")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  alpha_result <- psych::alpha(indicator_bank[, cols], warnings = FALSE, check.keys = FALSE)

  tibble(
    indicator_family = scale_name,
    n_indicators = length(cols),
    raw_alpha = alpha_result$total$raw_alpha,
    standardized_alpha = alpha_result$total$std.alpha,
    average_r = alpha_result$total$average_r
  )
})

readr::write_csv(reliability_rows, file.path(output_dir, "r_indicator_reliability_report.csv"))

panel_model <- panel %>%
  mutate(
    region = as.factor(region),
    community_type = as.factor(community_type),
    year = as.integer(year)
  ) %>%
  filter(complete.cases(
    life_satisfaction,
    health_index,
    social_trust,
    income_security,
    institutional_quality,
    housing_stability,
    education_access,
    care_access,
    environmental_quality,
    stress_load,
    community_resilience
  )) %>%
  mutate(
    public_wellbeing_index =
      rowMeans(
        select(
          .,
          life_satisfaction,
          health_index,
          social_trust,
          income_security,
          institutional_quality,
          housing_stability,
          education_access,
          care_access,
          environmental_quality,
          community_resilience
        ),
        na.rm = TRUE
      ) -
      0.50 * stress_load,
    trust_c = as.numeric(scale(social_trust, center = TRUE, scale = FALSE)),
    institutions_c = as.numeric(scale(institutional_quality, center = TRUE, scale = FALSE)),
    security_c = as.numeric(scale(income_security, center = TRUE, scale = FALSE)),
    housing_c = as.numeric(scale(housing_stability, center = TRUE, scale = FALSE)),
    care_c = as.numeric(scale(care_access, center = TRUE, scale = FALSE)),
    education_c = as.numeric(scale(education_access, center = TRUE, scale = FALSE)),
    environment_c = as.numeric(scale(environmental_quality, center = TRUE, scale = FALSE)),
    resilience_c = as.numeric(scale(community_resilience, center = TRUE, scale = FALSE)),
    stress_c = as.numeric(scale(stress_load, center = TRUE, scale = FALSE)),
    year_c = as.numeric(scale(year, center = TRUE, scale = FALSE))
  )

supportive_items <- panel_model %>%
  select(
    life_satisfaction,
    health_index,
    social_trust,
    income_security,
    institutional_quality,
    housing_stability,
    education_access,
    care_access,
    environmental_quality,
    community_resilience
  )

supportive_alpha <- psych::alpha(supportive_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    raw_alpha = supportive_alpha$total$raw_alpha,
    standardized_alpha = supportive_alpha$total$std.alpha,
    average_r = supportive_alpha$total$average_r
  ),
  file.path(output_dir, "r_supportive_domain_alpha.csv")
)

model_publichealth <- lmer(
  public_wellbeing_index ~ year_c +
    trust_c +
    institutions_c +
    security_c +
    housing_c +
    care_c +
    education_c +
    environment_c +
    resilience_c -
    stress_c +
    trust_c:institutions_c +
    housing_c:care_c +
    resilience_c:stress_c +
    (1 + year_c | region),
  data = panel_model,
  REML = FALSE
)

fixed_effects <- broom.mixed::tidy(model_publichealth, effects = "fixed", conf.int = TRUE)
random_effects <- broom.mixed::tidy(model_publichealth, effects = "ran_pars", conf.int = TRUE)

trust_institution_margins <- emmeans(
  model_publichealth,
  ~ trust_c | institutions_c,
  at = list(
    trust_c = c(-1, 0, 1),
    institutions_c = c(-1, 0, 1),
    security_c = 0,
    housing_c = 0,
    care_c = 0,
    education_c = 0,
    environment_c = 0,
    resilience_c = 0,
    stress_c = 0,
    year_c = 0
  )
)

housing_care_margins <- emmeans(
  model_publichealth,
  ~ housing_c | care_c,
  at = list(
    housing_c = c(-1, 0, 1),
    care_c = c(-1, 0, 1),
    trust_c = 0,
    institutions_c = 0,
    security_c = 0,
    education_c = 0,
    environment_c = 0,
    resilience_c = 0,
    stress_c = 0,
    year_c = 0
  )
)

resilience_stress_margins <- emmeans(
  model_publichealth,
  ~ resilience_c | stress_c,
  at = list(
    resilience_c = c(-1, 0, 1),
    stress_c = c(-1, 0, 1),
    trust_c = 0,
    institutions_c = 0,
    security_c = 0,
    housing_c = 0,
    care_c = 0,
    education_c = 0,
    environment_c = 0,
    year_c = 0
  )
)

readr::write_csv(fixed_effects, file.path(output_dir, "r_public_health_wellbeing_fixed_effects.csv"))
readr::write_csv(random_effects, file.path(output_dir, "r_public_health_wellbeing_random_effects.csv"))
readr::write_csv(as.data.frame(trust_institution_margins), file.path(output_dir, "r_trust_institution_estimated_margins.csv"))
readr::write_csv(as.data.frame(housing_care_margins), file.path(output_dir, "r_housing_care_estimated_margins.csv"))
readr::write_csv(as.data.frame(resilience_stress_margins), file.path(output_dir, "r_resilience_stress_estimated_margins.csv"))

message("Professional R positive psychology and public health workflow complete.")
message("Outputs written to: ", output_dir)
