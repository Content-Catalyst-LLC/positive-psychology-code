# Professional positive psychology intervention modeling scaffold
#
# Synthetic-data workflow for research and teaching.
# Not for clinical, diagnostic, therapeutic, screening, employment, or individual assessment use.

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

panel <- readr::read_csv(file.path(raw_dir, "positive_psychology_interventions_panel.csv"), show_col_types = FALSE)
indicator_bank <- readr::read_csv(file.path(raw_dir, "ppi_indicator_bank.csv"), show_col_types = FALSE)
practice_quality <- readr::read_csv(file.path(raw_dir, "ppi_practice_quality_audit.csv"), show_col_types = FALSE)

indicator_sets <- list(
  gratitude = c("gratitude1", "gratitude2"),
  strengths_use = c("strengths1", "strengths2"),
  hope = c("hope1", "hope2"),
  meaning = c("meaning1", "meaning2"),
  social_support = c("support1", "support2"),
  adherence = c("adherence1", "adherence2"),
  fit = c("fit1", "fit2"),
  wellbeing = c("wellbeing1", "wellbeing2"),
  distress = c("distress1", "distress2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  items <- indicator_bank[, cols]
  if (scale_name == "distress") items <- -items
  alpha_result <- tryCatch(psych::alpha(items, warnings = FALSE, check.keys = FALSE), error = function(e) NULL)
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
        adherence_design,
        mechanism_clarity,
        acceptability,
        context_fit,
        privacy_safeguards,
        trauma_sensitive_language,
        implementation_support,
        measurement_quality
      ),
      na.rm = TRUE
    )
  ) %>%
  arrange(desc(computed_quality_mean))
readr::write_csv(practice_quality_summary, file.path(output_dir, "r_practice_quality_audit_summary.csv"))

panel_scored <- panel %>%
  mutate(
    id = as.factor(id),
    week = as.integer(week),
    condition = as.factor(condition),
    ppi_type = as.factor(ppi_type)
  ) %>%
  filter(complete.cases(
    wellbeing_score,
    depressive_symptoms,
    gratitude_score,
    strengths_use,
    hope_score,
    meaning_score,
    social_support,
    adherence_rate,
    intervention_fit,
    stress_load,
    acceptability,
    context_fit
  )) %>%
  mutate(
    week_c = as.numeric(scale(week, center = TRUE, scale = FALSE)),
    wellbeing_z = as.numeric(scale(wellbeing_score)),
    depressive_z = as.numeric(scale(depressive_symptoms)),
    gratitude_z = as.numeric(scale(gratitude_score)),
    strengths_z = as.numeric(scale(strengths_use)),
    hope_z = as.numeric(scale(hope_score)),
    meaning_z = as.numeric(scale(meaning_score)),
    support_z = as.numeric(scale(social_support)),
    adherence_z = as.numeric(scale(adherence_rate)),
    fit_z = as.numeric(scale(intervention_fit)),
    stress_z = as.numeric(scale(stress_load)),
    acceptability_z = as.numeric(scale(acceptability)),
    context_fit_z = as.numeric(scale(context_fit)),
    mechanism_index = rowMeans(select(., gratitude_z, strengths_z, hope_z, meaning_z, support_z), na.rm = TRUE),
    practice_quality_proxy = rowMeans(select(., adherence_z, fit_z, acceptability_z, context_fit_z), na.rm = TRUE),
    net_wellbeing = wellbeing_z + gratitude_z + strengths_z + hope_z + meaning_z + support_z + fit_z - stress_z - depressive_z,
    gratitude_c = as.numeric(scale(gratitude_score, center = TRUE, scale = FALSE)),
    strengths_c = as.numeric(scale(strengths_use, center = TRUE, scale = FALSE)),
    hope_c = as.numeric(scale(hope_score, center = TRUE, scale = FALSE)),
    meaning_c = as.numeric(scale(meaning_score, center = TRUE, scale = FALSE)),
    support_c = as.numeric(scale(social_support, center = TRUE, scale = FALSE)),
    adherence_c = as.numeric(scale(adherence_rate, center = TRUE, scale = FALSE)),
    fit_c = as.numeric(scale(intervention_fit, center = TRUE, scale = FALSE)),
    stress_c = as.numeric(scale(stress_load, center = TRUE, scale = FALSE)),
    context_fit_c = as.numeric(scale(context_fit, center = TRUE, scale = FALSE)),
    mechanism_c = as.numeric(scale(mechanism_index, center = TRUE, scale = FALSE)),
    practice_quality_c = as.numeric(scale(practice_quality_proxy, center = TRUE, scale = FALSE))
  )

mechanism_alpha <- psych::alpha(
  panel_scored %>% select(gratitude_z, strengths_z, hope_z, meaning_z, support_z),
  warnings = FALSE,
  check.keys = FALSE
)

readr::write_csv(
  tibble(
    domain = "ppi_mechanism_items",
    raw_alpha = mechanism_alpha$total$raw_alpha,
    standardized_alpha = mechanism_alpha$total$std.alpha,
    average_r = mechanism_alpha$total$average_r
  ),
  file.path(output_dir, "r_ppi_mechanism_alpha.csv")
)

model_wellbeing <- lmer(
  wellbeing_score ~
    week_c * condition +
    ppi_type +
    gratitude_c +
    strengths_c +
    hope_c +
    meaning_c +
    support_c +
    adherence_c +
    fit_c +
    context_fit_c -
    stress_c +
    condition:fit_c +
    condition:stress_c +
    condition:context_fit_c +
    mechanism_c:condition +
    (1 + week_c | id),
  data = panel_scored,
  REML = FALSE
)

model_depressive_symptoms <- lmer(
  depressive_symptoms ~
    week_c * condition +
    ppi_type -
    gratitude_c -
    strengths_c -
    hope_c -
    meaning_c -
    support_c -
    adherence_c -
    fit_c -
    context_fit_c +
    stress_c +
    condition:fit_c +
    condition:stress_c +
    condition:context_fit_c +
    mechanism_c:condition +
    (1 + week_c | id),
  data = panel_scored,
  REML = FALSE
)

model_net_wellbeing <- lmer(
  net_wellbeing ~
    week_c * condition +
    ppi_type +
    mechanism_c +
    practice_quality_c -
    stress_c +
    condition:stress_c +
    condition:context_fit_c +
    (1 + week_c | id),
  data = panel_scored,
  REML = FALSE
)

wellbeing_margins <- emmeans(
  model_wellbeing,
  ~ week_c | condition,
  at = list(
    week_c = c(-1.5, 0, 1.5),
    gratitude_c = 0,
    strengths_c = 0,
    hope_c = 0,
    meaning_c = 0,
    support_c = 0,
    adherence_c = 0,
    fit_c = 0,
    context_fit_c = 0,
    stress_c = 0,
    mechanism_c = 0
  )
)

practice_summary <- panel_scored %>%
  group_by(condition, ppi_type) %>%
  summarize(
    mean_wellbeing = mean(wellbeing_score, na.rm = TRUE),
    mean_depressive_symptoms = mean(depressive_symptoms, na.rm = TRUE),
    mean_gratitude = mean(gratitude_score, na.rm = TRUE),
    mean_strengths_use = mean(strengths_use, na.rm = TRUE),
    mean_hope = mean(hope_score, na.rm = TRUE),
    mean_meaning = mean(meaning_score, na.rm = TRUE),
    mean_social_support = mean(social_support, na.rm = TRUE),
    mean_adherence = mean(adherence_rate, na.rm = TRUE),
    mean_fit = mean(intervention_fit, na.rm = TRUE),
    mean_context_fit = mean(context_fit, na.rm = TRUE),
    mean_stress = mean(stress_load, na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(broom.mixed::tidy(model_wellbeing, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_ppi_wellbeing_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_depressive_symptoms, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_ppi_depressive_symptoms_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_net_wellbeing, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_ppi_net_wellbeing_fixed_effects.csv"))
readr::write_csv(as.data.frame(wellbeing_margins), file.path(output_dir, "r_ppi_wellbeing_estimated_margins.csv"))
readr::write_csv(practice_summary, file.path(output_dir, "r_ppi_practice_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_ppi_scored_panel.csv"))

message("Professional R positive psychology intervention workflow complete.")
message("Outputs written to: ", output_dir)
