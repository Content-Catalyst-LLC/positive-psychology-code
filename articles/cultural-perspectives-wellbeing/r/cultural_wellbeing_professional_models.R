# Professional cross-cultural well-being modeling scaffold
#
# This workflow is designed for psychologists and interdisciplinary well-being
# researchers using synthetic data for research-methods demonstration.
#
# It is not a clinical, diagnostic, therapeutic, workplace-screening,
# employment-selection, cultural ranking, or individual well-being assessment tool.

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

panel <- readr::read_csv(file.path(raw_dir, "cultural_wellbeing_panel.csv"), show_col_types = FALSE)
items <- readr::read_csv(file.path(raw_dir, "cultural_wellbeing_item_bank.csv"), show_col_types = FALSE)

scale_sets <- list(
  general_wellbeing = c("wb1", "wb2", "wb3"),
  relational_harmony = c("rel1", "rel2", "rel3"),
  institutional_trust = c("inst1", "inst2", "inst3"),
  cultural_continuity = c("cult1", "cult2", "cult3"),
  place_attachment = c("place1", "place2", "place3")
)

reliability_rows <- purrr::imap_dfr(scale_sets, function(cols, scale_name) {
  pooled_alpha <- psych::alpha(items[, cols], warnings = FALSE, check.keys = FALSE)

  pooled <- tibble(
    group = "pooled",
    scale = scale_name,
    n_items = length(cols),
    raw_alpha = pooled_alpha$total$raw_alpha,
    standardized_alpha = pooled_alpha$total$std.alpha,
    average_r = pooled_alpha$total$average_r
  )

  group_rows <- items %>%
    group_by(country_group) %>%
    group_modify(~ {
      alpha_result <- psych::alpha(.x[, cols], warnings = FALSE, check.keys = FALSE)
      tibble(
        group = unique(.x$country_group),
        scale = scale_name,
        n_items = length(cols),
        raw_alpha = alpha_result$total$raw_alpha,
        standardized_alpha = alpha_result$total$std.alpha,
        average_r = alpha_result$total$average_r
      )
    }) %>%
    ungroup() %>%
    rename(group = country_group)

  bind_rows(pooled, group_rows)
})

readr::write_csv(reliability_rows, file.path(output_dir, "r_reliability_by_group.csv"))

efa_items <- items %>%
  select(all_of(unlist(scale_sets))) %>%
  mutate(across(everything(), as.numeric))

efa_result <- psych::fa(
  efa_items,
  nfactors = 5,
  rotate = "oblimin",
  fm = "ml"
)

efa_loadings <- as.data.frame(unclass(efa_result$loadings)) %>%
  rownames_to_column("item")

readr::write_csv(efa_loadings, file.path(output_dir, "r_efa_loadings.csv"))

# Optional CFA and measurement invariance scaffold if lavaan is installed.
if (optional_lavaan) {
  cfa_model <- '
    general_wellbeing =~ wb1 + wb2 + wb3
    relational_harmony =~ rel1 + rel2 + rel3
    institutional_trust =~ inst1 + inst2 + inst3
    cultural_continuity =~ cult1 + cult2 + cult3
    place_attachment =~ place1 + place2 + place3
  '

  configural_fit <- lavaan::cfa(
    cfa_model,
    data = items,
    group = "country_group",
    estimator = "MLR",
    missing = "fiml"
  )

  metric_fit <- lavaan::cfa(
    cfa_model,
    data = items,
    group = "country_group",
    group.equal = c("loadings"),
    estimator = "MLR",
    missing = "fiml"
  )

  scalar_fit <- lavaan::cfa(
    cfa_model,
    data = items,
    group = "country_group",
    group.equal = c("loadings", "intercepts"),
    estimator = "MLR",
    missing = "fiml"
  )

  invariance_summary <- bind_rows(
    tibble(model = "configural", t(lavaan::fitMeasures(configural_fit, c("cfi", "tli", "rmsea", "srmr", "aic", "bic")))),
    tibble(model = "metric", t(lavaan::fitMeasures(metric_fit, c("cfi", "tli", "rmsea", "srmr", "aic", "bic")))),
    tibble(model = "scalar", t(lavaan::fitMeasures(scalar_fit, c("cfi", "tli", "rmsea", "srmr", "aic", "bic"))))
  )

  readr::write_csv(invariance_summary, file.path(output_dir, "r_measurement_invariance_summary.csv"))
} else {
  message("lavaan is not installed; skipping optional CFA and measurement invariance checks.")
}

panel_model <- panel %>%
  mutate(
    person_id = as.factor(person_id),
    country_group = as.factor(country_group),
    wave = as.integer(wave)
  ) %>%
  filter(complete.cases(
    life_satisfaction, social_support, income_security, relational_harmony,
    institutional_trust, cultural_orientation, autonomy_value, harmony_value,
    civic_voice, cultural_continuity, place_attachment
  )) %>%
  mutate(
    wellbeing_index = rowMeans(
      select(
        .,
        life_satisfaction,
        social_support,
        relational_harmony,
        institutional_trust,
        income_security,
        civic_voice,
        cultural_continuity,
        place_attachment
      ),
      na.rm = TRUE
    ),
    income_c = as.numeric(scale(income_security, center = TRUE, scale = FALSE)),
    culture_c = as.numeric(scale(cultural_orientation, center = TRUE, scale = FALSE)),
    autonomy_c = as.numeric(scale(autonomy_value, center = TRUE, scale = FALSE)),
    harmony_c = as.numeric(scale(harmony_value, center = TRUE, scale = FALSE)),
    continuity_c = as.numeric(scale(cultural_continuity, center = TRUE, scale = FALSE)),
    place_c = as.numeric(scale(place_attachment, center = TRUE, scale = FALSE)),
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE))
  )

model_culture <- lmer(
  wellbeing_index ~ wave_c +
    income_c * culture_c +
    autonomy_c + harmony_c + continuity_c + place_c +
    (1 + wave_c | country_group/person_id),
  data = panel_model,
  REML = FALSE
)

fixed_effects <- broom.mixed::tidy(model_culture, effects = "fixed", conf.int = TRUE)
random_effects <- broom.mixed::tidy(model_culture, effects = "ran_pars", conf.int = TRUE)

estimated_margins <- emmeans(
  model_culture,
  ~ income_c | culture_c,
  at = list(
    income_c = c(-1, 0, 1),
    culture_c = c(-1, 0, 1),
    autonomy_c = 0,
    harmony_c = 0,
    continuity_c = 0,
    place_c = 0,
    wave_c = 0
  )
)

readr::write_csv(fixed_effects, file.path(output_dir, "r_multilevel_fixed_effects.csv"))
readr::write_csv(random_effects, file.path(output_dir, "r_multilevel_random_effects.csv"))
readr::write_csv(as.data.frame(estimated_margins), file.path(output_dir, "r_estimated_margins.csv"))

message("Professional R cultural well-being workflow complete.")
message("Outputs written to: ", output_dir)
