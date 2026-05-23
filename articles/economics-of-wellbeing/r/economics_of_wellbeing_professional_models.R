# Professional economics of well-being modeling scaffold
#
# This workflow is designed for psychologists, well-being economists,
# public-policy researchers, and interdisciplinary teams using synthetic
# data for methods demonstration.
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
  file.path(raw_dir, "economics_of_wellbeing_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "economics_of_wellbeing_indicator_bank.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  material_security = c("mat1", "mat2", "mat3"),
  subjective_wellbeing = c("swb1", "swb2", "swb3"),
  institutions = c("inst1", "inst2", "inst3"),
  work_quality = c("work1", "work2", "work3"),
  care_security = c("care1", "care2", "care3")
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
    income_security,
    life_satisfaction,
    health_index,
    social_trust,
    institutional_quality,
    environmental_quality,
    inequality_index,
    work_quality,
    care_security,
    time_pressure,
    public_services
  )) %>%
  mutate(
    wellbeing_economy_index =
      rowMeans(
        select(
          .,
          income_security,
          life_satisfaction,
          health_index,
          social_trust,
          institutional_quality,
          environmental_quality,
          work_quality,
          care_security,
          public_services
        ),
        na.rm = TRUE
      ) -
      0.40 * inequality_index -
      0.25 * time_pressure,
    trust_c = as.numeric(scale(social_trust, center = TRUE, scale = FALSE)),
    institutions_c = as.numeric(scale(institutional_quality, center = TRUE, scale = FALSE)),
    inequality_c = as.numeric(scale(inequality_index, center = TRUE, scale = FALSE)),
    env_c = as.numeric(scale(environmental_quality, center = TRUE, scale = FALSE)),
    work_c = as.numeric(scale(work_quality, center = TRUE, scale = FALSE)),
    care_c = as.numeric(scale(care_security, center = TRUE, scale = FALSE)),
    time_pressure_c = as.numeric(scale(time_pressure, center = TRUE, scale = FALSE)),
    services_c = as.numeric(scale(public_services, center = TRUE, scale = FALSE)),
    year_c = as.numeric(scale(year, center = TRUE, scale = FALSE))
  )

supportive_items <- panel_model %>%
  select(
    income_security,
    life_satisfaction,
    health_index,
    social_trust,
    institutional_quality,
    environmental_quality,
    work_quality,
    care_security,
    public_services
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

model_wb <- lmer(
  wellbeing_economy_index ~ year_c +
    trust_c +
    institutions_c +
    env_c +
    work_c +
    care_c +
    services_c -
    inequality_c -
    time_pressure_c +
    trust_c:institutions_c +
    work_c:care_c +
    (1 + year_c | country),
  data = panel_model,
  REML = FALSE
)

fixed_effects <- broom.mixed::tidy(model_wb, effects = "fixed", conf.int = TRUE)
random_effects <- broom.mixed::tidy(model_wb, effects = "ran_pars", conf.int = TRUE)

trust_institution_margins <- emmeans(
  model_wb,
  ~ trust_c | institutions_c,
  at = list(
    trust_c = c(-1, 0, 1),
    institutions_c = c(-1, 0, 1),
    env_c = 0,
    work_c = 0,
    care_c = 0,
    services_c = 0,
    inequality_c = 0,
    time_pressure_c = 0,
    year_c = 0
  )
)

work_care_margins <- emmeans(
  model_wb,
  ~ work_c | care_c,
  at = list(
    work_c = c(-1, 0, 1),
    care_c = c(-1, 0, 1),
    trust_c = 0,
    institutions_c = 0,
    env_c = 0,
    services_c = 0,
    inequality_c = 0,
    time_pressure_c = 0,
    year_c = 0
  )
)

readr::write_csv(fixed_effects, file.path(output_dir, "r_wellbeing_economy_fixed_effects.csv"))
readr::write_csv(random_effects, file.path(output_dir, "r_wellbeing_economy_random_effects.csv"))
readr::write_csv(as.data.frame(trust_institution_margins), file.path(output_dir, "r_trust_institution_estimated_margins.csv"))
readr::write_csv(as.data.frame(work_care_margins), file.path(output_dir, "r_work_care_estimated_margins.csv"))

message("Professional R economics of well-being workflow complete.")
message("Outputs written to: ", output_dir)
