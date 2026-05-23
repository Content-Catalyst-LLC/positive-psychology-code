# Professional gratitude and well-being modeling scaffold
#
# This workflow is designed for positive psychology researchers, psychologists,
# gratitude researchers, relationship researchers, well-being scientists, and
# interdisciplinary teams using synthetic data for methods demonstration.
#
# It is not a clinical, diagnostic, therapeutic, crisis-support, workplace-screening,
# employment-selection, public-benefits, school disciplinary, employee-evaluation,
# or individual well-being assessment tool.

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
  file.path(raw_dir, "gratitude_wellbeing_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "gratitude_indicator_bank.csv"),
  show_col_types = FALSE
)

practice_quality <- readr::read_csv(
  file.path(raw_dir, "gratitude_practice_quality_audit.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  gratitude = c("gratitude1", "gratitude2"),
  appreciative_attention = c("attention1", "attention2"),
  perceived_support = c("support1", "support2"),
  resilience = c("resilience1", "resilience2"),
  reflection_depth = c("reflection1", "reflection2"),
  gratitude_expression = c("expression1", "expression2"),
  intervention_fit = c("fit1", "fit2"),
  wellbeing = c("wellbeing1", "wellbeing2"),
  distress = c("distress1", "distress2"),
  relationship_quality = c("relationship1", "relationship2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  items <- indicator_bank[, cols]

  if (scale_name == "distress") {
    items <- -items
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

practice_quality_summary <- practice_quality %>%
  mutate(
    computed_quality_mean = rowMeans(
      select(
        .,
        reflection_design,
        mechanism_clarity,
        acceptability,
        context_fit,
        privacy_safeguards,
        trauma_sensitive_language,
        relational_safety,
        measurement_quality
      ),
      na.rm = TRUE
    ),
    lowest_quality_dimension = pmap_chr(
      select(
        .,
        reflection_design,
        mechanism_clarity,
        acceptability,
        context_fit,
        privacy_safeguards,
        trauma_sensitive_language,
        relational_safety,
        measurement_quality
      ),
      function(...) {
        vals <- c(...)
        names(vals) <- c(
          "reflection_design",
          "mechanism_clarity",
          "acceptability",
          "context_fit",
          "privacy_safeguards",
          "trauma_sensitive_language",
          "relational_safety",
          "measurement_quality"
        )
        names(vals)[which.min(vals)]
      }
    )
  ) %>%
  arrange(desc(computed_quality_mean))

readr::write_csv(practice_quality_summary, file.path(output_dir, "r_practice_quality_audit_summary.csv"))

panel_scored <- panel %>%
  mutate(
    id = as.factor(id),
    wave = as.integer(wave),
    condition = as.factor(condition)
  ) %>%
  filter(complete.cases(
    gratitude_score,
    life_satisfaction,
    perceived_support,
    resilience_score,
    stress_load,
    depressive_symptoms,
    reflection_depth,
    gratitude_expression,
    intervention_fit,
    relationship_quality,
    social_trust
  )) %>%
  mutate(
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE)),
    gratitude_z = as.numeric(scale(gratitude_score)),
    life_satisfaction_z = as.numeric(scale(life_satisfaction)),
    support_z = as.numeric(scale(perceived_support)),
    resilience_z = as.numeric(scale(resilience_score)),
    stress_z = as.numeric(scale(stress_load)),
    depressive_z = as.numeric(scale(depressive_symptoms)),
    reflection_z = as.numeric(scale(reflection_depth)),
    expression_z = as.numeric(scale(gratitude_expression)),
    fit_z = as.numeric(scale(intervention_fit)),
    relationship_z = as.numeric(scale(relationship_quality)),
    trust_z = as.numeric(scale(social_trust)),
    appreciative_orientation =
      rowMeans(
        select(., gratitude_z, support_z, reflection_z, expression_z, relationship_z, trust_z, fit_z),
        na.rm = TRUE
      ) - 0.25 * stress_z,
    relational_support =
      rowMeans(select(., support_z, expression_z, relationship_z, trust_z), na.rm = TRUE),
    net_wellbeing =
      life_satisfaction_z +
      gratitude_z +
      support_z +
      resilience_z +
      reflection_z +
      expression_z +
      relationship_z +
      trust_z -
      depressive_z -
      stress_z,
    gratitude_c = as.numeric(scale(gratitude_score, center = TRUE, scale = FALSE)),
    support_c = as.numeric(scale(perceived_support, center = TRUE, scale = FALSE)),
    resilience_c = as.numeric(scale(resilience_score, center = TRUE, scale = FALSE)),
    stress_c = as.numeric(scale(stress_load, center = TRUE, scale = FALSE)),
    reflection_c = as.numeric(scale(reflection_depth, center = TRUE, scale = FALSE)),
    expression_c = as.numeric(scale(gratitude_expression, center = TRUE, scale = FALSE)),
    fit_c = as.numeric(scale(intervention_fit, center = TRUE, scale = FALSE)),
    relationship_c = as.numeric(scale(relationship_quality, center = TRUE, scale = FALSE)),
    trust_c = as.numeric(scale(social_trust, center = TRUE, scale = FALSE)),
    appreciative_c = as.numeric(scale(appreciative_orientation, center = TRUE, scale = FALSE))
  )

mechanism_items <- panel_scored %>%
  select(gratitude_z, support_z, resilience_z, reflection_z, expression_z, relationship_z, trust_z)

mechanism_alpha <- psych::alpha(mechanism_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    domain = "gratitude_mechanism_items",
    raw_alpha = mechanism_alpha$total$raw_alpha,
    standardized_alpha = mechanism_alpha$total$std.alpha,
    average_r = mechanism_alpha$total$average_r
  ),
  file.path(output_dir, "r_gratitude_mechanism_alpha.csv")
)

model_life_satisfaction <- lmer(
  life_satisfaction ~
    wave_c * condition +
    gratitude_c +
    support_c +
    resilience_c -
    stress_c +
    reflection_c +
    expression_c +
    fit_c +
    relationship_c +
    trust_c +
    gratitude_c:support_c +
    gratitude_c:stress_c +
    expression_c:relationship_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_depressive_symptoms <- lmer(
  depressive_symptoms ~
    wave_c * condition -
    gratitude_c -
    support_c -
    resilience_c +
    stress_c -
    reflection_c -
    expression_c -
    fit_c -
    relationship_c -
    trust_c +
    gratitude_c:stress_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_net_wellbeing <- lmer(
  net_wellbeing ~
    wave_c * condition +
    appreciative_c +
    relational_support -
    stress_c +
    fit_c +
    condition:fit_c +
    condition:stress_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

gratitude_support_margins <- emmeans(
  model_life_satisfaction,
  ~ gratitude_c | support_c,
  at = list(
    gratitude_c = c(-1, 0, 1),
    support_c = c(-1, 0, 1),
    resilience_c = 0,
    stress_c = 0,
    reflection_c = 0,
    expression_c = 0,
    fit_c = 0,
    relationship_c = 0,
    trust_c = 0,
    wave_c = 0
  )
)

gratitude_stress_margins <- emmeans(
  model_life_satisfaction,
  ~ gratitude_c | stress_c,
  at = list(
    gratitude_c = c(-1, 0, 1),
    stress_c = c(-1, 0, 1),
    support_c = 0,
    resilience_c = 0,
    reflection_c = 0,
    expression_c = 0,
    fit_c = 0,
    relationship_c = 0,
    trust_c = 0,
    wave_c = 0
  )
)

condition_fit_margins <- emmeans(
  model_net_wellbeing,
  ~ condition | fit_c,
  at = list(
    fit_c = c(-1, 0, 1),
    wave_c = 0,
    appreciative_c = 0,
    relational_support = 0,
    stress_c = 0
  )
)

gratitude_summary <- panel_scored %>%
  group_by(condition) %>%
  summarize(
    mean_gratitude = mean(gratitude_score, na.rm = TRUE),
    mean_life_satisfaction = mean(life_satisfaction, na.rm = TRUE),
    mean_perceived_support = mean(perceived_support, na.rm = TRUE),
    mean_resilience = mean(resilience_score, na.rm = TRUE),
    mean_stress_load = mean(stress_load, na.rm = TRUE),
    mean_depressive_symptoms = mean(depressive_symptoms, na.rm = TRUE),
    mean_reflection_depth = mean(reflection_depth, na.rm = TRUE),
    mean_gratitude_expression = mean(gratitude_expression, na.rm = TRUE),
    mean_relationship_quality = mean(relationship_quality, na.rm = TRUE),
    mean_social_trust = mean(social_trust, na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(broom.mixed::tidy(model_life_satisfaction, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_gratitude_life_satisfaction_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_depressive_symptoms, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_gratitude_depressive_symptoms_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_net_wellbeing, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_gratitude_net_wellbeing_fixed_effects.csv"))
readr::write_csv(as.data.frame(gratitude_support_margins), file.path(output_dir, "r_gratitude_by_support_estimated_margins.csv"))
readr::write_csv(as.data.frame(gratitude_stress_margins), file.path(output_dir, "r_gratitude_by_stress_estimated_margins.csv"))
readr::write_csv(as.data.frame(condition_fit_margins), file.path(output_dir, "r_gratitude_condition_fit_estimated_margins.csv"))
readr::write_csv(gratitude_summary, file.path(output_dir, "r_gratitude_wellbeing_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_gratitude_scored_panel.csv"))

message("Professional R gratitude and well-being workflow complete.")
message("Outputs written to: ", output_dir)
