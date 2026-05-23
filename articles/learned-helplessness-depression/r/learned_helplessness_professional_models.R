# Professional learned helplessness, control, and recovery modeling scaffold
#
# This workflow is designed for psychologists, positive psychology researchers,
# attribution researchers, resilience researchers, educational psychologists,
# counseling researchers, health psychologists, organizational psychologists,
# public-health researchers, and interdisciplinary teams using synthetic data
# for methods demonstration.
#
# It is not a clinical, diagnostic, therapeutic, crisis-support, workplace-screening,
# employment-selection, student-ranking, employee-evaluation, benefits-eligibility,
# or individual psychological assessment tool.

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
  file.path(raw_dir, "learned_helplessness_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "learned_helplessness_indicator_bank.csv"),
  show_col_types = FALSE
)

context_audit <- readr::read_csv(
  file.path(raw_dir, "learned_helplessness_context_audit.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  perceived_control = c("control1", "control2"),
  uncontrollable_events = c("uncontrollable1", "uncontrollable2"),
  stability = c("stability1", "stability2"),
  globality = c("globality1", "globality2"),
  internality = c("internality1", "internality2"),
  motivation = c("motivation1", "motivation2"),
  depressive_symptoms = c("depressive1", "depressive2"),
  agency = c("agency1", "agency2"),
  support = c("support1", "support2"),
  mastery = c("mastery1", "mastery2"),
  recovery = c("recovery1", "recovery2"),
  feedback = c("feedback1", "feedback2"),
  fairness = c("fairness1", "fairness2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  items <- indicator_bank[, cols]

  if (scale_name %in% c(
    "uncontrollable_events",
    "stability",
    "globality",
    "internality",
    "depressive_symptoms"
  )) {
    items_for_alpha <- -items
  } else {
    items_for_alpha <- items
  }

  alpha_result <- tryCatch(
    psych::alpha(items_for_alpha, warnings = FALSE, check.keys = FALSE),
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

context_summary <- context_audit %>%
  mutate(
    computed_context_quality = rowMeans(
      select(
        .,
        control_opportunities,
        revision_pathways,
        feedback_specificity,
        institutional_fairness,
        psychological_safety,
        support_availability,
        mastery_scaffolding,
        recovery_opportunities,
        anti_blame_review,
        privacy_safeguards,
        clinical_escalation_protocol,
        measurement_quality
      ),
      na.rm = TRUE
    ),
    lowest_support_dimension = pmap_chr(
      select(
        .,
        control_opportunities,
        revision_pathways,
        feedback_specificity,
        institutional_fairness,
        psychological_safety,
        support_availability,
        mastery_scaffolding,
        recovery_opportunities,
        anti_blame_review,
        privacy_safeguards,
        clinical_escalation_protocol,
        measurement_quality
      ),
      function(...) {
        vals <- c(...)
        names(vals) <- c(
          "control_opportunities",
          "revision_pathways",
          "feedback_specificity",
          "institutional_fairness",
          "psychological_safety",
          "support_availability",
          "mastery_scaffolding",
          "recovery_opportunities",
          "anti_blame_review",
          "privacy_safeguards",
          "clinical_escalation_protocol",
          "measurement_quality"
        )
        names(vals)[which.min(vals)]
      }
    )
  ) %>%
  arrange(desc(computed_context_quality))

readr::write_csv(context_summary, file.path(output_dir, "r_learned_helplessness_context_audit_summary.csv"))

panel_scored <- panel %>%
  mutate(
    id = as.factor(id),
    wave = as.integer(wave),
    domain = as.factor(domain)
  ) %>%
  filter(complete.cases(
    perceived_control,
    uncontrollable_events,
    stability_score,
    globality_score,
    internality_score,
    motivation_score,
    depressive_symptoms,
    agency_score,
    support_score,
    mastery_experience,
    recovery_opportunity,
    feedback_quality,
    institutional_fairness
  )) %>%
  mutate(
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE)),
    control_c = as.numeric(scale(perceived_control, center = TRUE, scale = FALSE)),
    uncontrollable_c = as.numeric(scale(uncontrollable_events, center = TRUE, scale = FALSE)),
    stability_c = as.numeric(scale(stability_score, center = TRUE, scale = FALSE)),
    globality_c = as.numeric(scale(globality_score, center = TRUE, scale = FALSE)),
    internality_c = as.numeric(scale(internality_score, center = TRUE, scale = FALSE)),
    motivation_c = as.numeric(scale(motivation_score, center = TRUE, scale = FALSE)),
    depressive_c = as.numeric(scale(depressive_symptoms, center = TRUE, scale = FALSE)),
    agency_c = as.numeric(scale(agency_score, center = TRUE, scale = FALSE)),
    support_c = as.numeric(scale(support_score, center = TRUE, scale = FALSE)),
    mastery_c = as.numeric(scale(mastery_experience, center = TRUE, scale = FALSE)),
    recovery_c = as.numeric(scale(recovery_opportunity, center = TRUE, scale = FALSE)),
    feedback_c = as.numeric(scale(feedback_quality, center = TRUE, scale = FALSE)),
    fairness_c = as.numeric(scale(institutional_fairness, center = TRUE, scale = FALSE)),
    helplessness_index = rowMeans(
      select(., stability_c, globality_c, internality_c),
      na.rm = TRUE
    ),
    control_gap = control_c - uncontrollable_c,
    agency_recovery_index =
      agency_c +
      support_c +
      mastery_c +
      recovery_c +
      feedback_c +
      fairness_c -
      uncontrollable_c -
      helplessness_index,
    motivation_protection_index =
      motivation_c +
      control_c +
      agency_c +
      support_c +
      mastery_c +
      feedback_c +
      fairness_c -
      uncontrollable_c -
      helplessness_index -
      depressive_c
  )

attribution_items <- panel_scored %>%
  select(stability_c, globality_c, internality_c) %>%
  mutate(across(everything(), ~ -.x))

recovery_items <- panel_scored %>%
  select(agency_c, support_c, mastery_c, recovery_c, feedback_c, fairness_c)

attribution_alpha <- psych::alpha(attribution_items, warnings = FALSE, check.keys = FALSE)
recovery_alpha <- psych::alpha(recovery_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    domain = c("agency_preserving_attribution_items", "agency_recovery_items"),
    raw_alpha = c(attribution_alpha$total$raw_alpha, recovery_alpha$total$raw_alpha),
    standardized_alpha = c(attribution_alpha$total$std.alpha, recovery_alpha$total$std.alpha),
    average_r = c(attribution_alpha$total$average_r, recovery_alpha$total$average_r)
  ),
  file.path(output_dir, "r_learned_helplessness_domain_alpha.csv")
)

model_motivation <- lmer(
  motivation_score ~
    wave_c +
    control_c +
    uncontrollable_c +
    helplessness_index +
    agency_c +
    support_c +
    mastery_c +
    recovery_c +
    feedback_c +
    fairness_c +
    control_c:helplessness_index +
    support_c:uncontrollable_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_depression <- lmer(
  depressive_symptoms ~
    wave_c +
    control_c +
    uncontrollable_c +
    helplessness_index +
    agency_c +
    support_c +
    mastery_c +
    recovery_c +
    fairness_c +
    helplessness_index:uncontrollable_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_agency_recovery <- lmer(
  agency_recovery_index ~
    wave_c +
    control_c +
    uncontrollable_c +
    helplessness_index +
    support_c +
    mastery_c +
    recovery_c +
    feedback_c +
    fairness_c +
    domain +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_motivation_protection <- lmer(
  motivation_protection_index ~
    wave_c +
    control_gap +
    agency_recovery_index +
    support_c +
    mastery_c +
    recovery_c +
    fairness_c +
    domain +
    agency_recovery_index:control_gap +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

motivation_margins <- emmeans(
  model_motivation,
  ~ control_c | helplessness_index,
  at = list(
    control_c = c(-1, 0, 1),
    helplessness_index = c(-1, 0, 1),
    uncontrollable_c = 0,
    agency_c = 0,
    support_c = 0,
    mastery_c = 0,
    recovery_c = 0,
    feedback_c = 0,
    fairness_c = 0,
    wave_c = 0
  )
)

support_buffer_margins <- emmeans(
  model_depression,
  ~ helplessness_index | support_c,
  at = list(
    helplessness_index = c(-1, 0, 1),
    support_c = c(-1, 0, 1),
    control_c = 0,
    uncontrollable_c = 0,
    agency_c = 0,
    mastery_c = 0,
    recovery_c = 0,
    fairness_c = 0,
    wave_c = 0
  )
)

domain_summary <- panel_scored %>%
  group_by(domain) %>%
  summarize(
    mean_perceived_control = mean(perceived_control, na.rm = TRUE),
    mean_uncontrollable_events = mean(uncontrollable_events, na.rm = TRUE),
    mean_stability = mean(stability_score, na.rm = TRUE),
    mean_globality = mean(globality_score, na.rm = TRUE),
    mean_internality = mean(internality_score, na.rm = TRUE),
    mean_helplessness_index = mean(helplessness_index, na.rm = TRUE),
    mean_motivation = mean(motivation_score, na.rm = TRUE),
    mean_depressive_symptoms = mean(depressive_symptoms, na.rm = TRUE),
    mean_agency = mean(agency_score, na.rm = TRUE),
    mean_support = mean(support_score, na.rm = TRUE),
    mean_mastery = mean(mastery_experience, na.rm = TRUE),
    mean_recovery_opportunity = mean(recovery_opportunity, na.rm = TRUE),
    mean_feedback_quality = mean(feedback_quality, na.rm = TRUE),
    mean_institutional_fairness = mean(institutional_fairness, na.rm = TRUE),
    mean_agency_recovery_index = mean(agency_recovery_index, na.rm = TRUE),
    mean_motivation_protection_index = mean(motivation_protection_index, na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(broom.mixed::tidy(model_motivation, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_learned_helplessness_motivation_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_depression, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_learned_helplessness_depression_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_agency_recovery, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_learned_helplessness_agency_recovery_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_motivation_protection, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_motivation_protection_fixed_effects.csv"))
readr::write_csv(as.data.frame(motivation_margins), file.path(output_dir, "r_control_by_helplessness_motivation_margins.csv"))
readr::write_csv(as.data.frame(support_buffer_margins), file.path(output_dir, "r_helplessness_by_support_depression_margins.csv"))
readr::write_csv(domain_summary, file.path(output_dir, "r_learned_helplessness_domain_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_learned_helplessness_scored_panel.csv"))

message("Professional R learned helplessness workflow complete.")
message("Outputs written to: ", output_dir)
