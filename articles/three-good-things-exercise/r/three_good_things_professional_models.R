# Professional Three Good Things intervention modeling scaffold
#
# This workflow is designed for positive psychology researchers, psychologists,
# gratitude researchers, educational researchers, well-being scientists, and
# interdisciplinary teams using synthetic data for methods demonstration.
#
# It is not a clinical, diagnostic, therapeutic, crisis-support, workplace-screening,
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
  file.path(raw_dir, "three_good_things_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "three_good_things_indicator_bank.csv"),
  show_col_types = FALSE
)

practice_quality <- readr::read_csv(
  file.path(raw_dir, "practice_quality_audit.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  positive_event_salience = c("salience1", "salience2"),
  gratitude = c("gratitude1", "gratitude2"),
  perceived_support = c("support1", "support2"),
  reflection_depth = c("reflection1", "reflection2"),
  wellbeing = c("wellbeing1", "wellbeing2"),
  distress = c("distress1", "distress2"),
  fit_acceptability = c("fit1", "fit2")
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
        completion_rate,
        reflection_depth,
        acceptability,
        context_fit,
        privacy_safeguards,
        trauma_sensitive_language,
        implementation_support
      ),
      na.rm = TRUE
    ),
    lowest_quality_dimension = pmap_chr(
      select(
        .,
        completion_rate,
        reflection_depth,
        acceptability,
        context_fit,
        privacy_safeguards,
        trauma_sensitive_language,
        implementation_support
      ),
      function(...) {
        vals <- c(...)
        names(vals) <- c(
          "completion_rate",
          "reflection_depth",
          "acceptability",
          "context_fit",
          "privacy_safeguards",
          "trauma_sensitive_language",
          "implementation_support"
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
    day = as.integer(day),
    condition = as.factor(condition)
  ) %>%
  filter(complete.cases(
    life_satisfaction,
    depressive_symptoms,
    gratitude_score,
    positive_event_salience,
    perceived_support,
    reflection_depth,
    stress_load,
    acceptability,
    context_fit
  )) %>%
  mutate(
    day_c = as.numeric(scale(day, center = TRUE, scale = FALSE)),
    life_satisfaction_z = as.numeric(scale(life_satisfaction)),
    depressive_symptoms_z = as.numeric(scale(depressive_symptoms)),
    gratitude_z = as.numeric(scale(gratitude_score)),
    salience_z = as.numeric(scale(positive_event_salience)),
    support_z = as.numeric(scale(perceived_support)),
    reflection_z = as.numeric(scale(reflection_depth)),
    stress_z = as.numeric(scale(stress_load)),
    acceptability_z = as.numeric(scale(acceptability)),
    context_fit_z = as.numeric(scale(context_fit)),
    appreciative_awareness =
      rowMeans(
        select(., gratitude_z, salience_z, support_z, reflection_z, acceptability_z, context_fit_z),
        na.rm = TRUE
      ) - 0.25 * stress_z,
    net_wellbeing =
      life_satisfaction_z +
      gratitude_z +
      salience_z +
      support_z +
      reflection_z -
      depressive_symptoms_z -
      stress_z,
    gratitude_c = as.numeric(scale(gratitude_score, center = TRUE, scale = FALSE)),
    salience_c = as.numeric(scale(positive_event_salience, center = TRUE, scale = FALSE)),
    support_c = as.numeric(scale(perceived_support, center = TRUE, scale = FALSE)),
    reflection_c = as.numeric(scale(reflection_depth, center = TRUE, scale = FALSE)),
    stress_c = as.numeric(scale(stress_load, center = TRUE, scale = FALSE)),
    acceptability_c = as.numeric(scale(acceptability, center = TRUE, scale = FALSE)),
    context_fit_c = as.numeric(scale(context_fit, center = TRUE, scale = FALSE))
  )

mechanism_items <- panel_scored %>%
  select(gratitude_z, salience_z, support_z, reflection_z, acceptability_z, context_fit_z)

mechanism_alpha <- psych::alpha(mechanism_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    domain = "appreciative_awareness_mechanisms",
    raw_alpha = mechanism_alpha$total$raw_alpha,
    standardized_alpha = mechanism_alpha$total$std.alpha,
    average_r = mechanism_alpha$total$average_r
  ),
  file.path(output_dir, "r_appreciative_awareness_alpha.csv")
)

model_life_satisfaction <- lmer(
  life_satisfaction ~
    day_c * condition +
    gratitude_c +
    salience_c +
    support_c +
    reflection_c +
    acceptability_c +
    context_fit_c -
    stress_c +
    condition:stress_c +
    condition:reflection_c +
    condition:context_fit_c +
    (1 + day_c | id),
  data = panel_scored,
  REML = FALSE
)

model_depressive_symptoms <- lmer(
  depressive_symptoms ~
    day_c * condition -
    gratitude_c -
    salience_c -
    support_c -
    reflection_c -
    acceptability_c -
    context_fit_c +
    stress_c +
    condition:stress_c +
    condition:reflection_c +
    condition:context_fit_c +
    (1 + day_c | id),
  data = panel_scored,
  REML = FALSE
)

model_net_wellbeing <- lmer(
  net_wellbeing ~
    day_c * condition +
    appreciative_awareness +
    context_fit_c -
    stress_c +
    condition:stress_c +
    condition:context_fit_c +
    (1 + day_c | id),
  data = panel_scored,
  REML = FALSE
)

life_satisfaction_margins <- emmeans(
  model_life_satisfaction,
  ~ day_c | condition,
  at = list(
    day_c = c(-3, 0, 3),
    gratitude_c = 0,
    salience_c = 0,
    support_c = 0,
    reflection_c = 0,
    acceptability_c = 0,
    context_fit_c = 0,
    stress_c = 0
  )
)

depressive_symptoms_margins <- emmeans(
  model_depressive_symptoms,
  ~ day_c | condition,
  at = list(
    day_c = c(-3, 0, 3),
    gratitude_c = 0,
    salience_c = 0,
    support_c = 0,
    reflection_c = 0,
    acceptability_c = 0,
    context_fit_c = 0,
    stress_c = 0
  )
)

context_fit_margins <- emmeans(
  model_net_wellbeing,
  ~ condition | context_fit_c,
  at = list(
    context_fit_c = c(-1, 0, 1),
    appreciative_awareness = 0,
    stress_c = 0,
    day_c = 0
  )
)

practice_summary <- panel_scored %>%
  group_by(condition) %>%
  summarize(
    mean_life_satisfaction = mean(life_satisfaction, na.rm = TRUE),
    mean_depressive_symptoms = mean(depressive_symptoms, na.rm = TRUE),
    mean_gratitude = mean(gratitude_score, na.rm = TRUE),
    mean_positive_event_salience = mean(positive_event_salience, na.rm = TRUE),
    mean_perceived_support = mean(perceived_support, na.rm = TRUE),
    mean_reflection_depth = mean(reflection_depth, na.rm = TRUE),
    mean_stress_load = mean(stress_load, na.rm = TRUE),
    mean_acceptability = mean(acceptability, na.rm = TRUE),
    mean_context_fit = mean(context_fit, na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(broom.mixed::tidy(model_life_satisfaction, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_life_satisfaction_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_depressive_symptoms, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_depressive_symptoms_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_net_wellbeing, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_net_wellbeing_fixed_effects.csv"))
readr::write_csv(as.data.frame(life_satisfaction_margins), file.path(output_dir, "r_life_satisfaction_estimated_margins.csv"))
readr::write_csv(as.data.frame(depressive_symptoms_margins), file.path(output_dir, "r_depressive_symptoms_estimated_margins.csv"))
readr::write_csv(as.data.frame(context_fit_margins), file.path(output_dir, "r_context_fit_estimated_margins.csv"))
readr::write_csv(practice_summary, file.path(output_dir, "r_three_good_things_practice_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_three_good_things_scored_panel.csv"))

message("Professional R Three Good Things workflow complete.")
message("Outputs written to: ", output_dir)
