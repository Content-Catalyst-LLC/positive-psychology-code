# Professional well-being and sustainable development modeling scaffold
#
# This workflow is designed for psychologists, sustainable-development researchers,
# and interdisciplinary well-being teams using synthetic data for methods demonstration.
#
# It is not a clinical, diagnostic, therapeutic, workplace-screening,
# employment-selection, or individual well-being assessment tool.

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
  file.path(raw_dir, "wellbeing_sustainable_development_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "sustainable_wellbeing_indicator_bank.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  subjective_wellbeing = c("swb1", "swb2", "swb3"),
  capabilities = c("cap1", "cap2", "cap3"),
  institutions = c("inst1", "inst2", "inst3"),
  ecology = c("eco1", "eco2", "eco3"),
  resilience = c("res1", "res2", "res3")
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
    country = as.factor(country),
    region = as.factor(region),
    year = as.integer(year)
  ) %>%
  filter(complete.cases(
    life_expectancy,
    education_index,
    income_index,
    life_satisfaction,
    institutional_quality,
    ecological_stability,
    social_trust,
    inequality_index,
    resilience_capacity,
    basic_services
  )) %>%
  mutate(
    flourishing_development_index =
      rowMeans(
        select(
          .,
          life_expectancy,
          education_index,
          income_index,
          life_satisfaction,
          institutional_quality,
          ecological_stability,
          social_trust,
          resilience_capacity,
          basic_services
        ),
        na.rm = TRUE
      ) -
      0.50 * inequality_index,
    institutions_c = as.numeric(scale(institutional_quality, center = TRUE, scale = FALSE)),
    ecology_c = as.numeric(scale(ecological_stability, center = TRUE, scale = FALSE)),
    trust_c = as.numeric(scale(social_trust, center = TRUE, scale = FALSE)),
    resilience_c = as.numeric(scale(resilience_capacity, center = TRUE, scale = FALSE)),
    inequality_c = as.numeric(scale(inequality_index, center = TRUE, scale = FALSE)),
    year_c = as.numeric(scale(year, center = TRUE, scale = FALSE))
  )

supportive_items <- panel_model %>%
  select(
    life_expectancy,
    education_index,
    income_index,
    life_satisfaction,
    institutional_quality,
    ecological_stability,
    social_trust,
    resilience_capacity,
    basic_services
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

model_dev <- lmer(
  flourishing_development_index ~ year_c +
    institutions_c +
    ecology_c +
    trust_c +
    resilience_c -
    inequality_c +
    institutions_c:ecology_c +
    trust_c:resilience_c +
    (1 + year_c | country),
  data = panel_model,
  REML = FALSE
)

fixed_effects <- broom.mixed::tidy(model_dev, effects = "fixed", conf.int = TRUE)
random_effects <- broom.mixed::tidy(model_dev, effects = "ran_pars", conf.int = TRUE)

estimated_margins <- emmeans(
  model_dev,
  ~ institutions_c | ecology_c,
  at = list(
    institutions_c = c(-1, 0, 1),
    ecology_c = c(-1, 0, 1),
    trust_c = 0,
    resilience_c = 0,
    inequality_c = 0,
    year_c = 0
  )
)

readr::write_csv(fixed_effects, file.path(output_dir, "r_flourishing_development_fixed_effects.csv"))
readr::write_csv(random_effects, file.path(output_dir, "r_flourishing_development_random_effects.csv"))
readr::write_csv(as.data.frame(estimated_margins), file.path(output_dir, "r_flourishing_development_estimated_margins.csv"))

message("Professional R well-being and sustainable development workflow complete.")
message("Outputs written to: ", output_dir)
