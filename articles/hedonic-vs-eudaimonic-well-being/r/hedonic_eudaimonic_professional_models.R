# Professional hedonic and eudaimonic well-being modeling scaffold
#
# This workflow is designed for psychologists, well-being researchers,
# public-policy analysts, and interdisciplinary teams using synthetic data
# for methods demonstration.
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
  file.path(raw_dir, "hedonic_eudaimonic_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "hedonic_eudaimonic_indicator_bank.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  hedonic = c("hed1", "hed2", "hed3"),
  eudaimonic = c("eud1", "eud2", "eud3", "eud4", "eud5", "eud6"),
  relational = c("rel1", "rel2"),
  contextual_support = c("context1", "context2"),
  strain = c("strain1", "strain2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  items <- indicator_bank[, cols]

  if (scale_name == "hedonic" && "hed3" %in% names(items)) {
    items <- items %>% mutate(hed3 = -hed3)
  }

  alpha_result <- tryCatch(
    psych::alpha(items, warnings = FALSE, check.keys = FALSE),
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
    id = as.factor(id),
    group = as.factor(group),
    wave = as.integer(wave)
  ) %>%
  filter(complete.cases(
    life_satisfaction,
    positive_affect,
    negative_affect,
    autonomy,
    personal_growth,
    purpose_life,
    positive_relations,
    environmental_mastery,
    self_acceptance,
    flourishing_outcome,
    stress_load,
    contextual_support
  )) %>%
  mutate(
    life_satisfaction_z = as.numeric(scale(life_satisfaction)),
    positive_affect_z = as.numeric(scale(positive_affect)),
    negative_affect_z = as.numeric(scale(negative_affect)),
    autonomy_z = as.numeric(scale(autonomy)),
    personal_growth_z = as.numeric(scale(personal_growth)),
    purpose_life_z = as.numeric(scale(purpose_life)),
    positive_relations_z = as.numeric(scale(positive_relations)),
    environmental_mastery_z = as.numeric(scale(environmental_mastery)),
    self_acceptance_z = as.numeric(scale(self_acceptance)),
    stress_load_z = as.numeric(scale(stress_load)),
    contextual_support_z = as.numeric(scale(contextual_support)),
    hedonic_index =
      life_satisfaction_z +
      positive_affect_z -
      negative_affect_z,
    eudaimonic_index = rowMeans(
      select(
        .,
        autonomy_z,
        personal_growth_z,
        purpose_life_z,
        positive_relations_z,
        environmental_mastery_z,
        self_acceptance_z
      ),
      na.rm = TRUE
    ),
    integrated_flourishing_index =
      0.40 * hedonic_index +
      0.45 * eudaimonic_index +
      0.20 * contextual_support_z -
      0.20 * stress_load_z,
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE)),
    hedonic_c = as.numeric(scale(hedonic_index, center = TRUE, scale = FALSE)),
    eudaimonic_c = as.numeric(scale(eudaimonic_index, center = TRUE, scale = FALSE)),
    support_c = as.numeric(scale(contextual_support_z, center = TRUE, scale = FALSE)),
    stress_c = as.numeric(scale(stress_load_z, center = TRUE, scale = FALSE))
  )

hedonic_items <- panel_scored %>%
  transmute(
    life_satisfaction_z,
    positive_affect_z,
    negative_affect_reversed = -negative_affect_z
  )

eudaimonic_items <- panel_scored %>%
  select(
    autonomy_z,
    personal_growth_z,
    purpose_life_z,
    positive_relations_z,
    environmental_mastery_z,
    self_acceptance_z
  )

hedonic_alpha <- psych::alpha(hedonic_items, warnings = FALSE, check.keys = FALSE)
eudaimonic_alpha <- psych::alpha(eudaimonic_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    domain = c("hedonic", "eudaimonic"),
    raw_alpha = c(hedonic_alpha$total$raw_alpha, eudaimonic_alpha$total$raw_alpha),
    standardized_alpha = c(hedonic_alpha$total$std.alpha, eudaimonic_alpha$total$std.alpha),
    average_r = c(hedonic_alpha$total$average_r, eudaimonic_alpha$total$average_r)
  ),
  file.path(output_dir, "r_domain_reliability_report.csv")
)

model_wb <- lmer(
  flourishing_outcome ~
    wave_c +
    hedonic_c +
    eudaimonic_c +
    support_c -
    stress_c +
    hedonic_c:eudaimonic_c +
    eudaimonic_c:support_c +
    hedonic_c:stress_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

fixed_effects <- broom.mixed::tidy(model_wb, effects = "fixed", conf.int = TRUE)
random_effects <- broom.mixed::tidy(model_wb, effects = "ran_pars", conf.int = TRUE)

hedonic_eudaimonic_margins <- emmeans(
  model_wb,
  ~ hedonic_c | eudaimonic_c,
  at = list(
    hedonic_c = c(-1, 0, 1),
    eudaimonic_c = c(-1, 0, 1),
    support_c = 0,
    stress_c = 0,
    wave_c = 0
  )
)

eudaimonic_support_margins <- emmeans(
  model_wb,
  ~ eudaimonic_c | support_c,
  at = list(
    eudaimonic_c = c(-1, 0, 1),
    support_c = c(-1, 0, 1),
    hedonic_c = 0,
    stress_c = 0,
    wave_c = 0
  )
)

stress_hedonic_margins <- emmeans(
  model_wb,
  ~ hedonic_c | stress_c,
  at = list(
    hedonic_c = c(-1, 0, 1),
    stress_c = c(-1, 0, 1),
    eudaimonic_c = 0,
    support_c = 0,
    wave_c = 0
  )
)

domain_summary <- panel_scored %>%
  group_by(group) %>%
  summarize(
    mean_hedonic_index = mean(hedonic_index, na.rm = TRUE),
    mean_eudaimonic_index = mean(eudaimonic_index, na.rm = TRUE),
    mean_integrated_flourishing = mean(integrated_flourishing_index, na.rm = TRUE),
    mean_contextual_support = mean(contextual_support_z, na.rm = TRUE),
    mean_stress_load = mean(stress_load_z, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_integrated_flourishing))

readr::write_csv(fixed_effects, file.path(output_dir, "r_hedonic_eudaimonic_fixed_effects.csv"))
readr::write_csv(random_effects, file.path(output_dir, "r_hedonic_eudaimonic_random_effects.csv"))
readr::write_csv(as.data.frame(hedonic_eudaimonic_margins), file.path(output_dir, "r_hedonic_by_eudaimonic_estimated_margins.csv"))
readr::write_csv(as.data.frame(eudaimonic_support_margins), file.path(output_dir, "r_eudaimonic_by_support_estimated_margins.csv"))
readr::write_csv(as.data.frame(stress_hedonic_margins), file.path(output_dir, "r_hedonic_by_stress_estimated_margins.csv"))
readr::write_csv(domain_summary, file.path(output_dir, "r_hedonic_eudaimonic_group_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_hedonic_eudaimonic_scored_panel.csv"))

message("Professional R hedonic/eudaimonic workflow complete.")
message("Outputs written to: ", output_dir)
