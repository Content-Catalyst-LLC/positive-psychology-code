# Professional meaning and purpose modeling scaffold
#
# This workflow is designed for psychologists, positive psychology researchers,
# meaning-in-life researchers, counseling researchers, developmental researchers,
# educational psychologists, work and organizational psychologists, and
# interdisciplinary teams using synthetic data for methods demonstration.
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
  file.path(raw_dir, "meaning_purpose_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "meaning_indicator_bank.csv"),
  show_col_types = FALSE
)

context_audit <- readr::read_csv(
  file.path(raw_dir, "meaning_institutional_context_audit.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  meaning_presence = c("presence1", "presence2"),
  meaning_search = c("search1", "search2"),
  purpose = c("purpose1", "purpose2"),
  coherence = c("coherence1", "coherence2"),
  significance = c("significance1", "significance2"),
  belonging = c("belonging1", "belonging2"),
  value_alignment = c("values1", "values2"),
  institutional_support = c("institution1", "institution2"),
  wellbeing = c("wellbeing1", "wellbeing2"),
  goal_persistence = c("persistence1", "persistence2"),
  stress = c("stress1", "stress2"),
  alienation = c("alienation1", "alienation2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  items <- indicator_bank[, cols]

  if (scale_name %in% c("stress", "alienation")) {
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
        coherence_support,
        purpose_support,
        significance_support,
        belonging_support,
        value_alignment_support,
        agency_support,
        privacy_safeguards,
        cultural_adaptation,
        anti_exploitation_review,
        measurement_quality
      ),
      na.rm = TRUE
    ),
    lowest_support_dimension = pmap_chr(
      select(
        .,
        coherence_support,
        purpose_support,
        significance_support,
        belonging_support,
        value_alignment_support,
        agency_support,
        privacy_safeguards,
        cultural_adaptation,
        anti_exploitation_review,
        measurement_quality
      ),
      function(...) {
        vals <- c(...)
        names(vals) <- c(
          "coherence_support",
          "purpose_support",
          "significance_support",
          "belonging_support",
          "value_alignment_support",
          "agency_support",
          "privacy_safeguards",
          "cultural_adaptation",
          "anti_exploitation_review",
          "measurement_quality"
        )
        names(vals)[which.min(vals)]
      }
    )
  ) %>%
  arrange(desc(computed_context_quality))

readr::write_csv(context_summary, file.path(output_dir, "r_institutional_context_audit_summary.csv"))

panel_scored <- panel %>%
  mutate(
    id = as.factor(id),
    wave = as.integer(wave),
    domain = as.factor(domain)
  ) %>%
  filter(complete.cases(
    meaning_presence,
    meaning_search,
    purpose_score,
    coherence_score,
    significance_score,
    belonging_score,
    value_alignment,
    institutional_support,
    wellbeing_score,
    goal_persistence,
    stress_load,
    alienation_score,
    identity_integration,
    context_quality
  )) %>%
  mutate(
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE)),
    presence_z = as.numeric(scale(meaning_presence)),
    search_z = as.numeric(scale(meaning_search)),
    purpose_z = as.numeric(scale(purpose_score)),
    coherence_z = as.numeric(scale(coherence_score)),
    significance_z = as.numeric(scale(significance_score)),
    belonging_z = as.numeric(scale(belonging_score)),
    values_z = as.numeric(scale(value_alignment)),
    institution_z = as.numeric(scale(institutional_support)),
    wellbeing_z = as.numeric(scale(wellbeing_score)),
    persistence_z = as.numeric(scale(goal_persistence)),
    stress_z = as.numeric(scale(stress_load)),
    alienation_z = as.numeric(scale(alienation_score)),
    identity_z = as.numeric(scale(identity_integration)),
    context_z = as.numeric(scale(context_quality)),
    meaning_system_index = rowMeans(
      select(
        .,
        meaning_presence,
        purpose_score,
        coherence_score,
        significance_score,
        belonging_score,
        value_alignment,
        identity_integration
      ),
      na.rm = TRUE
    ),
    context_adjusted_meaning =
      meaning_system_index +
      institutional_support +
      context_quality -
      stress_load -
      alienation_score,
    directed_life_index =
      purpose_score +
      goal_persistence +
      value_alignment +
      institutional_support -
      stress_load,
    search_context_index =
      meaning_search +
      stress_load +
      alienation_score -
      meaning_presence -
      coherence_score,
    presence_c = as.numeric(scale(meaning_presence, center = TRUE, scale = FALSE)),
    search_c = as.numeric(scale(meaning_search, center = TRUE, scale = FALSE)),
    purpose_c = as.numeric(scale(purpose_score, center = TRUE, scale = FALSE)),
    coherence_c = as.numeric(scale(coherence_score, center = TRUE, scale = FALSE)),
    significance_c = as.numeric(scale(significance_score, center = TRUE, scale = FALSE)),
    belonging_c = as.numeric(scale(belonging_score, center = TRUE, scale = FALSE)),
    values_c = as.numeric(scale(value_alignment, center = TRUE, scale = FALSE)),
    institution_c = as.numeric(scale(institutional_support, center = TRUE, scale = FALSE)),
    stress_c = as.numeric(scale(stress_load, center = TRUE, scale = FALSE)),
    alienation_c = as.numeric(scale(alienation_score, center = TRUE, scale = FALSE)),
    identity_c = as.numeric(scale(identity_integration, center = TRUE, scale = FALSE)),
    context_c = as.numeric(scale(context_quality, center = TRUE, scale = FALSE)),
    meaning_system_c = as.numeric(scale(meaning_system_index, center = TRUE, scale = FALSE)),
    context_adjusted_c = as.numeric(scale(context_adjusted_meaning, center = TRUE, scale = FALSE)),
    directed_life_c = as.numeric(scale(directed_life_index, center = TRUE, scale = FALSE))
  )

meaning_system_items <- panel_scored %>%
  select(
    presence_z,
    purpose_z,
    coherence_z,
    significance_z,
    belonging_z,
    values_z,
    identity_z
  )

context_items <- panel_scored %>%
  select(institution_z, context_z, values_z, belonging_z, coherence_z)

meaning_system_alpha <- psych::alpha(meaning_system_items, warnings = FALSE, check.keys = FALSE)
context_alpha <- psych::alpha(context_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    domain = c("meaning_system_items", "context_support_items"),
    raw_alpha = c(meaning_system_alpha$total$raw_alpha, context_alpha$total$raw_alpha),
    standardized_alpha = c(meaning_system_alpha$total$std.alpha, context_alpha$total$std.alpha),
    average_r = c(meaning_system_alpha$total$average_r, context_alpha$total$average_r)
  ),
  file.path(output_dir, "r_meaning_domain_alpha.csv")
)

model_wellbeing <- lmer(
  wellbeing_score ~
    wave_c +
    presence_c +
    search_c +
    purpose_c +
    coherence_c +
    significance_c +
    belonging_c +
    values_c +
    institution_c +
    context_c +
    stress_c +
    alienation_c +
    presence_c:purpose_c +
    institution_c:alienation_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_persistence <- lmer(
  goal_persistence ~
    wave_c +
    presence_c +
    purpose_c +
    coherence_c +
    values_c +
    institution_c +
    context_c +
    stress_c +
    alienation_c +
    purpose_c:institution_c +
    directed_life_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_search <- lmer(
  meaning_search ~
    wave_c +
    stress_c +
    alienation_c +
    presence_c +
    coherence_c +
    institution_c +
    context_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_context_adjusted <- lmer(
  context_adjusted_meaning ~
    wave_c +
    meaning_system_c +
    institution_c +
    context_c +
    alienation_c +
    stress_c +
    domain +
    meaning_system_c:institution_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

wellbeing_margins <- emmeans(
  model_wellbeing,
  ~ presence_c | purpose_c,
  at = list(
    presence_c = c(-1, 0, 1),
    purpose_c = c(-1, 0, 1),
    search_c = 0,
    coherence_c = 0,
    significance_c = 0,
    belonging_c = 0,
    values_c = 0,
    institution_c = 0,
    context_c = 0,
    stress_c = 0,
    alienation_c = 0,
    wave_c = 0
  )
)

institution_alienation_margins <- emmeans(
  model_wellbeing,
  ~ institution_c | alienation_c,
  at = list(
    institution_c = c(-1, 0, 1),
    alienation_c = c(-1, 0, 1),
    presence_c = 0,
    search_c = 0,
    purpose_c = 0,
    coherence_c = 0,
    significance_c = 0,
    belonging_c = 0,
    values_c = 0,
    context_c = 0,
    stress_c = 0,
    wave_c = 0
  )
)

purpose_institution_margins <- emmeans(
  model_persistence,
  ~ purpose_c | institution_c,
  at = list(
    purpose_c = c(-1, 0, 1),
    institution_c = c(-1, 0, 1),
    presence_c = 0,
    coherence_c = 0,
    values_c = 0,
    context_c = 0,
    stress_c = 0,
    alienation_c = 0,
    directed_life_c = 0,
    wave_c = 0
  )
)

domain_summary <- panel_scored %>%
  group_by(domain) %>%
  summarize(
    mean_presence = mean(meaning_presence, na.rm = TRUE),
    mean_search = mean(meaning_search, na.rm = TRUE),
    mean_purpose = mean(purpose_score, na.rm = TRUE),
    mean_coherence = mean(coherence_score, na.rm = TRUE),
    mean_significance = mean(significance_score, na.rm = TRUE),
    mean_belonging = mean(belonging_score, na.rm = TRUE),
    mean_value_alignment = mean(value_alignment, na.rm = TRUE),
    mean_institutional_support = mean(institutional_support, na.rm = TRUE),
    mean_wellbeing = mean(wellbeing_score, na.rm = TRUE),
    mean_goal_persistence = mean(goal_persistence, na.rm = TRUE),
    mean_stress = mean(stress_load, na.rm = TRUE),
    mean_alienation = mean(alienation_score, na.rm = TRUE),
    mean_context_adjusted_meaning = mean(context_adjusted_meaning, na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(broom.mixed::tidy(model_wellbeing, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_meaning_wellbeing_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_persistence, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_meaning_persistence_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_search, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_meaning_search_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_context_adjusted, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_context_adjusted_meaning_fixed_effects.csv"))
readr::write_csv(as.data.frame(wellbeing_margins), file.path(output_dir, "r_meaning_presence_by_purpose_margins.csv"))
readr::write_csv(as.data.frame(institution_alienation_margins), file.path(output_dir, "r_meaning_institution_by_alienation_margins.csv"))
readr::write_csv(as.data.frame(purpose_institution_margins), file.path(output_dir, "r_meaning_purpose_by_institution_margins.csv"))
readr::write_csv(domain_summary, file.path(output_dir, "r_meaning_domain_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_meaning_scored_panel.csv"))

message("Professional R meaning and purpose workflow complete.")
message("Outputs written to: ", output_dir)
