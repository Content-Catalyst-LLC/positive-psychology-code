# Professional explanatory style and optimism modeling scaffold
#
# This workflow is designed for psychologists, positive psychology researchers,
# attribution researchers, resilience researchers, educational psychologists,
# counseling researchers, health psychologists, organizational psychologists,
# and interdisciplinary teams using synthetic data for methods demonstration.
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
  file.path(raw_dir, "explanatory_style_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "explanatory_style_indicator_bank.csv"),
  show_col_types = FALSE
)

context_audit <- readr::read_csv(
  file.path(raw_dir, "explanatory_style_context_audit.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  negative_stability = c("neg_stability1", "neg_stability2"),
  negative_globality = c("neg_globality1", "neg_globality2"),
  negative_personalization = c("neg_personalization1", "neg_personalization2"),
  positive_stability = c("pos_stability1", "pos_stability2"),
  positive_globality = c("pos_globality1", "pos_globality2"),
  positive_effort = c("pos_effort1", "pos_effort2"),
  agency = c("agency1", "agency2"),
  support = c("support1", "support2"),
  persistence = c("persistence1", "persistence2"),
  hope = c("hope1", "hope2"),
  wellbeing = c("wellbeing1", "wellbeing2"),
  distress = c("distress1", "distress2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  items <- indicator_bank[, cols]

  if (scale_name %in% c(
    "negative_stability",
    "negative_globality",
    "negative_personalization",
    "distress"
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
        feedback_specificity,
        revision_pathways,
        fairness_of_evaluation,
        agency_support,
        controllability_support,
        psychological_safety,
        support_availability,
        anti_blame_review,
        privacy_safeguards,
        cultural_adaptation,
        measurement_quality
      ),
      na.rm = TRUE
    ),
    lowest_support_dimension = pmap_chr(
      select(
        .,
        feedback_specificity,
        revision_pathways,
        fairness_of_evaluation,
        agency_support,
        controllability_support,
        psychological_safety,
        support_availability,
        anti_blame_review,
        privacy_safeguards,
        cultural_adaptation,
        measurement_quality
      ),
      function(...) {
        vals <- c(...)
        names(vals) <- c(
          "feedback_specificity",
          "revision_pathways",
          "fairness_of_evaluation",
          "agency_support",
          "controllability_support",
          "psychological_safety",
          "support_availability",
          "anti_blame_review",
          "privacy_safeguards",
          "cultural_adaptation",
          "measurement_quality"
        )
        names(vals)[which.min(vals)]
      }
    )
  ) %>%
  arrange(desc(computed_context_quality))

readr::write_csv(context_summary, file.path(output_dir, "r_explanatory_style_context_audit_summary.csv"))

panel_scored <- panel %>%
  mutate(
    id = as.factor(id),
    wave = as.integer(wave),
    domain = as.factor(domain)
  ) %>%
  filter(complete.cases(
    neg_stability,
    neg_globality,
    neg_personalization,
    pos_stability,
    pos_globality,
    pos_internal_effort,
    setback_intensity,
    controllability_score,
    agency_score,
    support_score,
    persistence_score,
    hope_score,
    wellbeing_score,
    distress_score
  )) %>%
  mutate(
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE)),
    neg_stability_c = as.numeric(scale(neg_stability, center = TRUE, scale = FALSE)),
    neg_globality_c = as.numeric(scale(neg_globality, center = TRUE, scale = FALSE)),
    neg_personalization_c = as.numeric(scale(neg_personalization, center = TRUE, scale = FALSE)),
    pos_stability_c = as.numeric(scale(pos_stability, center = TRUE, scale = FALSE)),
    pos_globality_c = as.numeric(scale(pos_globality, center = TRUE, scale = FALSE)),
    pos_effort_c = as.numeric(scale(pos_internal_effort, center = TRUE, scale = FALSE)),
    setback_c = as.numeric(scale(setback_intensity, center = TRUE, scale = FALSE)),
    controllability_c = as.numeric(scale(controllability_score, center = TRUE, scale = FALSE)),
    agency_c = as.numeric(scale(agency_score, center = TRUE, scale = FALSE)),
    support_c = as.numeric(scale(support_score, center = TRUE, scale = FALSE)),
    distress_c = as.numeric(scale(distress_score, center = TRUE, scale = FALSE)),
    explanatory_burden =
      rowMeans(
        select(., neg_stability_c, neg_globality_c, neg_personalization_c),
        na.rm = TRUE
      ),
    positive_event_integration =
      rowMeans(
        select(., pos_stability_c, pos_globality_c, pos_effort_c),
        na.rm = TRUE
      ),
    context_adjusted_agency =
      agency_score +
      support_score +
      controllability_score -
      setback_intensity -
      explanatory_burden,
    resilient_persistence_index =
      persistence_score +
      hope_score +
      agency_score +
      support_score +
      positive_event_integration -
      setback_intensity -
      explanatory_burden -
      distress_score
  )

negative_attribution_items <- panel_scored %>%
  select(neg_stability_c, neg_globality_c, neg_personalization_c) %>%
  mutate(across(everything(), ~ -.x))

positive_attribution_items <- panel_scored %>%
  select(pos_stability_c, pos_globality_c, pos_effort_c)

negative_alpha <- psych::alpha(negative_attribution_items, warnings = FALSE, check.keys = FALSE)
positive_alpha <- psych::alpha(positive_attribution_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    domain = c("negative_event_attribution_items", "positive_event_attribution_items"),
    raw_alpha = c(negative_alpha$total$raw_alpha, positive_alpha$total$raw_alpha),
    standardized_alpha = c(negative_alpha$total$std.alpha, positive_alpha$total$std.alpha),
    average_r = c(negative_alpha$total$average_r, positive_alpha$total$average_r)
  ),
  file.path(output_dir, "r_explanatory_style_domain_alpha.csv")
)

model_persistence <- lmer(
  persistence_score ~
    wave_c +
    explanatory_burden +
    setback_c +
    agency_c +
    support_c +
    controllability_c +
    positive_event_integration +
    neg_stability_c:neg_globality_c +
    explanatory_burden:support_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_wellbeing <- lmer(
  wellbeing_score ~
    wave_c +
    explanatory_burden +
    setback_c +
    agency_c +
    support_c +
    positive_event_integration +
    distress_c +
    explanatory_burden:support_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_hope <- lmer(
  hope_score ~
    wave_c +
    explanatory_burden +
    agency_c +
    support_c +
    controllability_c +
    positive_event_integration +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_distress <- lmer(
  distress_score ~
    wave_c +
    explanatory_burden +
    setback_c +
    agency_c +
    support_c +
    controllability_c +
    neg_personalization_c:setback_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_context_adjusted <- lmer(
  context_adjusted_agency ~
    wave_c +
    explanatory_burden +
    positive_event_integration +
    setback_c +
    support_c +
    controllability_c +
    domain +
    explanatory_burden:support_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

persistence_margins <- emmeans(
  model_persistence,
  ~ neg_stability_c | neg_globality_c,
  at = list(
    neg_stability_c = c(-1, 0, 1),
    neg_globality_c = c(-1, 0, 1),
    neg_personalization_c = 0,
    explanatory_burden = 0,
    setback_c = 0,
    agency_c = 0,
    support_c = 0,
    controllability_c = 0,
    positive_event_integration = 0,
    wave_c = 0
  )
)

support_buffer_margins <- emmeans(
  model_persistence,
  ~ explanatory_burden | support_c,
  at = list(
    explanatory_burden = c(-1, 0, 1),
    support_c = c(-1, 0, 1),
    setback_c = 0,
    agency_c = 0,
    controllability_c = 0,
    positive_event_integration = 0,
    neg_stability_c = 0,
    neg_globality_c = 0,
    wave_c = 0
  )
)

domain_summary <- panel_scored %>%
  group_by(domain) %>%
  summarize(
    mean_neg_stability = mean(neg_stability, na.rm = TRUE),
    mean_neg_globality = mean(neg_globality, na.rm = TRUE),
    mean_neg_personalization = mean(neg_personalization, na.rm = TRUE),
    mean_explanatory_burden = mean(explanatory_burden, na.rm = TRUE),
    mean_positive_event_integration = mean(positive_event_integration, na.rm = TRUE),
    mean_setback_intensity = mean(setback_intensity, na.rm = TRUE),
    mean_controllability = mean(controllability_score, na.rm = TRUE),
    mean_agency = mean(agency_score, na.rm = TRUE),
    mean_support = mean(support_score, na.rm = TRUE),
    mean_persistence = mean(persistence_score, na.rm = TRUE),
    mean_hope = mean(hope_score, na.rm = TRUE),
    mean_wellbeing = mean(wellbeing_score, na.rm = TRUE),
    mean_distress = mean(distress_score, na.rm = TRUE),
    mean_context_adjusted_agency = mean(context_adjusted_agency, na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(broom.mixed::tidy(model_persistence, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_explanatory_style_persistence_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_wellbeing, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_explanatory_style_wellbeing_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_hope, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_explanatory_style_hope_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_distress, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_explanatory_style_distress_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_context_adjusted, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_context_adjusted_agency_fixed_effects.csv"))
readr::write_csv(as.data.frame(persistence_margins), file.path(output_dir, "r_stability_by_globality_margins.csv"))
readr::write_csv(as.data.frame(support_buffer_margins), file.path(output_dir, "r_explanatory_burden_by_support_margins.csv"))
readr::write_csv(domain_summary, file.path(output_dir, "r_explanatory_style_domain_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_explanatory_style_scored_panel.csv"))

message("Professional R explanatory style workflow complete.")
message("Outputs written to: ", output_dir)
