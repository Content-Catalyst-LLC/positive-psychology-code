# Professional critiques of positive psychology modeling scaffold
#
# This workflow is designed for psychologists, well-being researchers,
# critical psychology scholars, and interdisciplinary teams using synthetic
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
  file.path(raw_dir, "positive_psychology_critiques_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "critique_indicator_bank.csv"),
  show_col_types = FALSE
)

distortion <- readr::read_csv(
  file.path(raw_dir, "construct_distortion_tracking.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  meaning = c("meaning1", "meaning2", "meaning3"),
  relationships = c("rel1", "rel2", "rel3"),
  agency = c("agency1", "agency2", "agency3"),
  structure = c("structure1", "structure2", "structure3"),
  cultural_fit = c("culture1", "culture2", "culture3"),
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
    id = as.factor(id),
    group = as.factor(group),
    wave = as.integer(wave)
  ) %>%
  filter(complete.cases(
    meaning,
    relationships,
    optimism,
    resilience,
    income_security,
    institutional_trust,
    inequality_exposure,
    stress_load,
    cultural_fit,
    environmental_quality
  )) %>%
  mutate(
    flourishing_index = rowMeans(
      select(., meaning, relationships, optimism, resilience),
      na.rm = TRUE
    ),
    critique_sensitive_flourishing =
      0.13 * meaning +
      0.13 * relationships +
      0.10 * optimism +
      0.11 * resilience +
      0.11 * income_security +
      0.11 * institutional_trust +
      0.09 * cultural_fit +
      0.09 * environmental_quality -
      0.08 * inequality_exposure -
      0.08 * stress_load,
    meaning_c = as.numeric(scale(meaning, center = TRUE, scale = FALSE)),
    relationships_c = as.numeric(scale(relationships, center = TRUE, scale = FALSE)),
    optimism_c = as.numeric(scale(optimism, center = TRUE, scale = FALSE)),
    resilience_c = as.numeric(scale(resilience, center = TRUE, scale = FALSE)),
    security_c = as.numeric(scale(income_security, center = TRUE, scale = FALSE)),
    trust_c = as.numeric(scale(institutional_trust, center = TRUE, scale = FALSE)),
    inequality_c = as.numeric(scale(inequality_exposure, center = TRUE, scale = FALSE)),
    stress_c = as.numeric(scale(stress_load, center = TRUE, scale = FALSE)),
    cultural_c = as.numeric(scale(cultural_fit, center = TRUE, scale = FALSE)),
    environment_c = as.numeric(scale(environmental_quality, center = TRUE, scale = FALSE)),
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE))
  )

psych_items <- panel_model %>%
  select(meaning, relationships, optimism, resilience)

psych_alpha <- psych::alpha(psych_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    raw_alpha = psych_alpha$total$raw_alpha,
    standardized_alpha = psych_alpha$total$std.alpha,
    average_r = psych_alpha$total$average_r
  ),
  file.path(output_dir, "r_psychological_domain_alpha.csv")
)

model_psych <- lmer(
  flourishing_index ~ wave_c +
    optimism_c +
    resilience_c +
    relationships_c +
    (1 + wave_c | id),
  data = panel_model,
  REML = FALSE
)

model_structural <- lmer(
  flourishing_index ~ wave_c +
    optimism_c +
    resilience_c +
    relationships_c +
    security_c +
    trust_c -
    inequality_c -
    stress_c +
    cultural_c +
    environment_c +
    trust_c:security_c +
    resilience_c:stress_c +
    (1 + wave_c | id),
  data = panel_model,
  REML = FALSE
)

model_critique_sensitive <- lmer(
  critique_sensitive_flourishing ~ wave_c +
    meaning_c +
    relationships_c +
    optimism_c +
    resilience_c +
    security_c +
    trust_c -
    inequality_c -
    stress_c +
    cultural_c +
    environment_c +
    trust_c:security_c +
    resilience_c:stress_c +
    cultural_c:trust_c +
    (1 + wave_c | id),
  data = panel_model,
  REML = FALSE
)

model_comparison <- tibble(
  model = c("psychological_only", "psychological_plus_structural", "critique_sensitive"),
  AIC = c(AIC(model_psych), AIC(model_structural), AIC(model_critique_sensitive)),
  BIC = c(BIC(model_psych), BIC(model_structural), BIC(model_critique_sensitive)),
  logLik = c(
    as.numeric(logLik(model_psych)),
    as.numeric(logLik(model_structural)),
    as.numeric(logLik(model_critique_sensitive))
  )
)

stress_resilience_margins <- emmeans(
  model_structural,
  ~ resilience_c | stress_c,
  at = list(
    resilience_c = c(-1, 0, 1),
    stress_c = c(-1, 0, 1),
    optimism_c = 0,
    relationships_c = 0,
    security_c = 0,
    trust_c = 0,
    inequality_c = 0,
    cultural_c = 0,
    environment_c = 0,
    wave_c = 0
  )
)

trust_security_margins <- emmeans(
  model_structural,
  ~ trust_c | security_c,
  at = list(
    trust_c = c(-1, 0, 1),
    security_c = c(-1, 0, 1),
    optimism_c = 0,
    relationships_c = 0,
    resilience_c = 0,
    inequality_c = 0,
    stress_c = 0,
    cultural_c = 0,
    environment_c = 0,
    wave_c = 0
  )
)

distortion_model <- lm(
  distortion_risk ~ applied_uptake + retained_nuance +
    institutional_accountability + commercial_pressure + privacy_safeguards,
  data = distortion
)

readr::write_csv(
  model_comparison,
  file.path(output_dir, "r_positive_psychology_critiques_model_comparison.csv")
)

readr::write_csv(
  broom.mixed::tidy(model_structural, effects = "fixed", conf.int = TRUE),
  file.path(output_dir, "r_positive_psychology_critiques_structural_fixed_effects.csv")
)

readr::write_csv(
  broom.mixed::tidy(model_critique_sensitive, effects = "fixed", conf.int = TRUE),
  file.path(output_dir, "r_positive_psychology_critiques_critique_sensitive_fixed_effects.csv")
)

readr::write_csv(
  as.data.frame(stress_resilience_margins),
  file.path(output_dir, "r_resilience_stress_estimated_margins.csv")
)

readr::write_csv(
  as.data.frame(trust_security_margins),
  file.path(output_dir, "r_trust_security_estimated_margins.csv")
)

readr::write_csv(
  broom::tidy(distortion_model, conf.int = TRUE),
  file.path(output_dir, "r_construct_distortion_model_results.csv")
)

message("Professional R critiques of positive psychology workflow complete.")
message("Outputs written to: ", output_dir)
