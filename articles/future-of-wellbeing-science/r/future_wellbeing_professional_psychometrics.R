# Professional psychometrics and longitudinal modeling scaffold
#
# This workflow is designed for psychologists and interdisciplinary well-being
# researchers using synthetic data for research-methods demonstration.
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

optional_lavaan <- requireNamespace("lavaan", quietly = TRUE)

script_path <- tryCatch(normalizePath(sys.frame(1)$ofile), error = function(e) NA_character_)
base_dir <- if (!is.na(script_path)) dirname(dirname(script_path)) else getwd()
raw_dir <- file.path(base_dir, "data", "raw")
output_dir <- file.path(base_dir, "outputs", "tables")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

panel <- readr::read_csv(file.path(raw_dir, "future_wellbeing_panel.csv"), show_col_types = FALSE)
items <- readr::read_csv(file.path(raw_dir, "future_wellbeing_item_bank.csv"), show_col_types = FALSE)

scale_sets <- list(
  life_satisfaction = c("ls1", "ls2", "ls3"),
  meaning = c("meaning1", "meaning2", "meaning3"),
  social_trust = c("trust1", "trust2", "trust3"),
  health = c("health1", "health2", "health3"),
  stress_load = c("stress1", "stress2", "stress3")
)

reliability_rows <- purrr::imap_dfr(scale_sets, function(cols, scale_name) {
  alpha_result <- psych::alpha(items[, cols], warnings = FALSE, check.keys = FALSE)

  tibble(
    scale = scale_name,
    n_items = length(cols),
    raw_alpha = alpha_result$total$raw_alpha,
    standardized_alpha = alpha_result$total$std.alpha,
    average_r = alpha_result$total$average_r
  )
})

readr::write_csv(reliability_rows, file.path(output_dir, "r_reliability_report.csv"))

# Exploratory factor analysis for synthetic item bank.
efa_items <- items %>%
  select(all_of(unlist(scale_sets))) %>%
  mutate(across(everything(), as.numeric))

parallel <- psych::fa.parallel(
  efa_items,
  fa = "fa",
  n.iter = 20,
  plot = FALSE,
  error.bars = FALSE
)

efa_result <- psych::fa(
  efa_items,
  nfactors = 5,
  rotate = "oblimin",
  fm = "ml"
)

efa_loadings <- as.data.frame(unclass(efa_result$loadings)) %>%
  rownames_to_column("item")

readr::write_csv(efa_loadings, file.path(output_dir, "r_efa_loadings.csv"))

# Optional CFA if lavaan is installed.
if (optional_lavaan) {
  cfa_model <- '
    life_satisfaction =~ ls1 + ls2 + ls3
    meaning =~ meaning1 + meaning2 + meaning3
    social_trust =~ trust1 + trust2 + trust3
    health =~ health1 + health2 + health3
    stress_load =~ stress1 + stress2 + stress3
  '

  cfa_fit <- lavaan::cfa(cfa_model, data = items, estimator = "MLR", missing = "fiml")

  cfa_fit_measures <- lavaan::fitMeasures(
    cfa_fit,
    c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr", "aic", "bic")
  ) %>%
    enframe(name = "fit_index", value = "value")

  cfa_loadings <- lavaan::standardizedSolution(cfa_fit) %>%
    filter(op == "=~") %>%
    select(lhs, rhs, est.std, se, pvalue)

  readr::write_csv(cfa_fit_measures, file.path(output_dir, "r_cfa_fit_measures.csv"))
  readr::write_csv(cfa_loadings, file.path(output_dir, "r_cfa_standardized_loadings.csv"))
} else {
  message("lavaan is not installed; skipping optional CFA.")
}

# Longitudinal mixed model for multidimensional flourishing.
panel_model <- panel %>%
  mutate(
    id = as.factor(id),
    group = as.factor(group),
    wave = as.integer(wave)
  ) %>%
  filter(complete.cases(
    life_satisfaction, meaning, social_trust, institutional_quality,
    environmental_quality, health_index, resilience_score, stress_load,
    material_security, civic_voice
  )) %>%
  mutate(
    flourishing_index = rowMeans(
      select(
        .,
        life_satisfaction,
        meaning,
        social_trust,
        institutional_quality,
        environmental_quality,
        health_index,
        material_security,
        civic_voice
      ),
      na.rm = TRUE
    ) -
      0.40 * stress_load,
    resilience_c = as.numeric(scale(resilience_score, center = TRUE, scale = FALSE)),
    stress_c = as.numeric(scale(stress_load, center = TRUE, scale = FALSE)),
    institutional_c = as.numeric(scale(institutional_quality, center = TRUE, scale = FALSE)),
    environmental_c = as.numeric(scale(environmental_quality, center = TRUE, scale = FALSE)),
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE))
  )

model_future <- lmer(
  flourishing_index ~ wave_c + resilience_c - stress_c +
    institutional_c + environmental_c +
    resilience_c:stress_c +
    (1 + wave_c | id),
  data = panel_model,
  REML = FALSE
)

fixed_effects <- broom.mixed::tidy(model_future, effects = "fixed", conf.int = TRUE)
random_effects <- broom.mixed::tidy(model_future, effects = "ran_pars", conf.int = TRUE)

estimated_margins <- emmeans(
  model_future,
  ~ resilience_c | stress_c,
  at = list(
    resilience_c = c(-1, 0, 1),
    stress_c = c(-1, 0, 1),
    institutional_c = 0,
    environmental_c = 0,
    wave_c = 0
  )
)

readr::write_csv(fixed_effects, file.path(output_dir, "r_longitudinal_fixed_effects.csv"))
readr::write_csv(random_effects, file.path(output_dir, "r_longitudinal_random_effects.csv"))
readr::write_csv(as.data.frame(estimated_margins), file.path(output_dir, "r_estimated_margins.csv"))

message("Professional R psychometrics and longitudinal workflow complete.")
message("Outputs written to: ", output_dir)
