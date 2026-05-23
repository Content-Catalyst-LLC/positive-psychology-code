# Professional post-traumatic growth modeling scaffold
#
# This workflow is designed for psychologists, trauma researchers, positive
# psychology researchers, counseling researchers, clinical researchers,
# resilience researchers, meaning-making researchers, and interdisciplinary
# teams using synthetic data for methods demonstration.
#
# It is not a clinical, diagnostic, therapeutic, crisis-support, crisis-triage,
# workplace-screening, employment-selection, student-ranking, employee-evaluation,
# benefits-eligibility, legal, insurance, or individual psychological assessment tool.

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
  file.path(raw_dir, "post_traumatic_growth_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "ptg_indicator_bank.csv"),
  show_col_types = FALSE
)

context_audit <- readr::read_csv(
  file.path(raw_dir, "ptg_context_support_audit.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  appreciation = c("appreciation1", "appreciation2"),
  relationships = c("relationships1", "relationships2"),
  personal_strength = c("strength1", "strength2"),
  new_possibilities = c("new_possibilities1", "new_possibilities2"),
  existential_change = c("existential1", "existential2"),
  meaning = c("meaning1", "meaning2"),
  support = c("support1", "support2"),
  agency = c("agency1", "agency2"),
  distress = c("distress1", "distress2"),
  wellbeing = c("wellbeing1", "wellbeing2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  items <- indicator_bank[, cols]

  if (scale_name == "distress") {
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
        safety_stabilization,
        meaning_support,
        narrative_support,
        social_support_quality,
        agency_restoration,
        privacy_safeguards,
        trauma_informed_language,
        structural_barrier_review,
        measurement_quality
      ),
      na.rm = TRUE
    ),
    lowest_support_dimension = pmap_chr(
      select(
        .,
        safety_stabilization,
        meaning_support,
        narrative_support,
        social_support_quality,
        agency_restoration,
        privacy_safeguards,
        trauma_informed_language,
        structural_barrier_review,
        measurement_quality
      ),
      function(...) {
        vals <- c(...)
        names(vals) <- c(
          "safety_stabilization",
          "meaning_support",
          "narrative_support",
          "social_support_quality",
          "agency_restoration",
          "privacy_safeguards",
          "trauma_informed_language",
          "structural_barrier_review",
          "measurement_quality"
        )
        names(vals)[which.min(vals)]
      }
    )
  ) %>%
  arrange(desc(computed_context_quality))

readr::write_csv(context_summary, file.path(output_dir, "r_context_support_audit_summary.csv"))

panel_scored <- panel %>%
  mutate(
    id = as.factor(id),
    wave = as.integer(wave),
    trauma_context = as.factor(trauma_context)
  ) %>%
  filter(complete.cases(
    assumptive_disruption,
    intrusive_rumination,
    deliberate_rumination,
    meaning_making,
    social_support,
    restored_agency,
    narrative_integration,
    context_support,
    ongoing_stress,
    ptg_appreciation,
    ptg_relationships,
    ptg_strength,
    ptg_new_possibilities,
    ptg_existential_change,
    ptg_score,
    distress_score,
    wellbeing_score,
    perceived_growth,
    corroborated_growth
  )) %>%
  mutate(
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE)),
    disruption_z = as.numeric(scale(assumptive_disruption)),
    intrusive_z = as.numeric(scale(intrusive_rumination)),
    deliberate_z = as.numeric(scale(deliberate_rumination)),
    meaning_z = as.numeric(scale(meaning_making)),
    support_z = as.numeric(scale(social_support)),
    agency_z = as.numeric(scale(restored_agency)),
    narrative_z = as.numeric(scale(narrative_integration)),
    context_z = as.numeric(scale(context_support)),
    stress_z = as.numeric(scale(ongoing_stress)),
    ptg_z = as.numeric(scale(ptg_score)),
    distress_z = as.numeric(scale(distress_score)),
    wellbeing_z = as.numeric(scale(wellbeing_score)),
    perceived_z = as.numeric(scale(perceived_growth)),
    corroborated_z = as.numeric(scale(corroborated_growth)),
    ptg_domain_mean = rowMeans(
      select(
        .,
        ptg_appreciation,
        ptg_relationships,
        ptg_strength,
        ptg_new_possibilities,
        ptg_existential_change
      ),
      na.rm = TRUE
    ),
    integration_index = rowMeans(
      select(., meaning_making, restored_agency, narrative_integration, social_support, context_support),
      na.rm = TRUE
    ),
    reflective_processing_balance = deliberate_rumination - intrusive_rumination,
    growth_distress_balance =
      ptg_score +
      wellbeing_score +
      integration_index -
      distress_score -
      ongoing_stress,
    growth_alignment =
      perceived_growth +
      corroborated_growth -
      abs(perceived_growth - corroborated_growth),
    disruption_c = as.numeric(scale(assumptive_disruption, center = TRUE, scale = FALSE)),
    intrusive_c = as.numeric(scale(intrusive_rumination, center = TRUE, scale = FALSE)),
    deliberate_c = as.numeric(scale(deliberate_rumination, center = TRUE, scale = FALSE)),
    meaning_c = as.numeric(scale(meaning_making, center = TRUE, scale = FALSE)),
    support_c = as.numeric(scale(social_support, center = TRUE, scale = FALSE)),
    agency_c = as.numeric(scale(restored_agency, center = TRUE, scale = FALSE)),
    narrative_c = as.numeric(scale(narrative_integration, center = TRUE, scale = FALSE)),
    context_c = as.numeric(scale(context_support, center = TRUE, scale = FALSE)),
    stress_c = as.numeric(scale(ongoing_stress, center = TRUE, scale = FALSE)),
    distress_c = as.numeric(scale(distress_score, center = TRUE, scale = FALSE)),
    integration_c = as.numeric(scale(integration_index, center = TRUE, scale = FALSE)),
    reflection_balance_c = as.numeric(scale(reflective_processing_balance, center = TRUE, scale = FALSE)),
    growth_alignment_c = as.numeric(scale(growth_alignment, center = TRUE, scale = FALSE))
  )

ptg_domain_items <- panel_scored %>%
  select(
    ptg_appreciation,
    ptg_relationships,
    ptg_strength,
    ptg_new_possibilities,
    ptg_existential_change
  )

integration_items <- panel_scored %>%
  select(meaning_z, support_z, agency_z, narrative_z, context_z)

ptg_domain_alpha <- psych::alpha(ptg_domain_items, warnings = FALSE, check.keys = FALSE)
integration_alpha <- psych::alpha(integration_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    domain = c("ptg_domain_items", "integration_items"),
    raw_alpha = c(ptg_domain_alpha$total$raw_alpha, integration_alpha$total$raw_alpha),
    standardized_alpha = c(ptg_domain_alpha$total$std.alpha, integration_alpha$total$std.alpha),
    average_r = c(ptg_domain_alpha$total$average_r, integration_alpha$total$average_r)
  ),
  file.path(output_dir, "r_ptg_domain_alpha.csv")
)

model_ptg <- lmer(
  ptg_score ~
    wave_c +
    disruption_c +
    deliberate_c +
    meaning_c +
    support_c +
    agency_c +
    narrative_c +
    context_c +
    stress_c +
    meaning_c:agency_c +
    deliberate_c:narrative_c +
    support_c:stress_c +
    growth_alignment_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_distress <- lmer(
  distress_score ~
    wave_c +
    disruption_c +
    intrusive_c +
    stress_c +
    support_c +
    agency_c +
    context_c +
    intrusive_c:stress_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_wellbeing <- lmer(
  wellbeing_score ~
    wave_c +
    ptg_score +
    distress_c +
    integration_c +
    context_c +
    stress_c +
    ptg_score:distress_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_growth_distress_balance <- lmer(
  growth_distress_balance ~
    wave_c +
    reflection_balance_c +
    integration_c +
    support_c +
    context_c +
    growth_alignment_c +
    stress_c +
    trauma_context +
    integration_c:stress_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

ptg_meaning_agency_margins <- emmeans(
  model_ptg,
  ~ meaning_c | agency_c,
  at = list(
    meaning_c = c(-1, 0, 1),
    agency_c = c(-1, 0, 1),
    disruption_c = 0,
    deliberate_c = 0,
    support_c = 0,
    narrative_c = 0,
    context_c = 0,
    stress_c = 0,
    growth_alignment_c = 0,
    wave_c = 0
  )
)

ptg_support_stress_margins <- emmeans(
  model_ptg,
  ~ support_c | stress_c,
  at = list(
    support_c = c(-1, 0, 1),
    stress_c = c(-1, 0, 1),
    disruption_c = 0,
    deliberate_c = 0,
    meaning_c = 0,
    agency_c = 0,
    narrative_c = 0,
    context_c = 0,
    growth_alignment_c = 0,
    wave_c = 0
  )
)

wellbeing_growth_distress_margins <- emmeans(
  model_wellbeing,
  ~ ptg_score | distress_c,
  at = list(
    ptg_score = quantile(panel_scored$ptg_score, probs = c(0.25, 0.50, 0.75), na.rm = TRUE),
    distress_c = c(-1, 0, 1),
    integration_c = 0,
    context_c = 0,
    stress_c = 0,
    wave_c = 0
  )
)

context_summary_by_trauma <- panel_scored %>%
  group_by(trauma_context) %>%
  summarize(
    mean_disruption = mean(assumptive_disruption, na.rm = TRUE),
    mean_intrusive_rumination = mean(intrusive_rumination, na.rm = TRUE),
    mean_deliberate_rumination = mean(deliberate_rumination, na.rm = TRUE),
    mean_meaning_making = mean(meaning_making, na.rm = TRUE),
    mean_social_support = mean(social_support, na.rm = TRUE),
    mean_restored_agency = mean(restored_agency, na.rm = TRUE),
    mean_narrative_integration = mean(narrative_integration, na.rm = TRUE),
    mean_context_support = mean(context_support, na.rm = TRUE),
    mean_ongoing_stress = mean(ongoing_stress, na.rm = TRUE),
    mean_ptg = mean(ptg_score, na.rm = TRUE),
    mean_distress = mean(distress_score, na.rm = TRUE),
    mean_wellbeing = mean(wellbeing_score, na.rm = TRUE),
    mean_growth_alignment = mean(growth_alignment, na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(broom.mixed::tidy(model_ptg, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_ptg_growth_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_distress, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_ptg_distress_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_wellbeing, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_ptg_wellbeing_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_growth_distress_balance, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_ptg_growth_distress_balance_fixed_effects.csv"))
readr::write_csv(as.data.frame(ptg_meaning_agency_margins), file.path(output_dir, "r_ptg_meaning_by_agency_margins.csv"))
readr::write_csv(as.data.frame(ptg_support_stress_margins), file.path(output_dir, "r_ptg_support_by_stress_margins.csv"))
readr::write_csv(as.data.frame(wellbeing_growth_distress_margins), file.path(output_dir, "r_ptg_wellbeing_growth_by_distress_margins.csv"))
readr::write_csv(context_summary_by_trauma, file.path(output_dir, "r_ptg_context_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_ptg_scored_panel.csv"))

message("Professional R post-traumatic growth workflow complete.")
message("Outputs written to: ", output_dir)
