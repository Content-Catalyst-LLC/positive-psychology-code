# Professional Hope Theory modeling scaffold
#
# This workflow is designed for psychologists, positive psychology researchers,
# counseling researchers, educational psychologists, health psychologists,
# motivational scientists, resilience researchers, and interdisciplinary teams
# using synthetic data for methods demonstration.
#
# It is not a clinical, diagnostic, therapeutic, crisis-support, workplace-screening,
# employment-selection, student-ranking, employee-evaluation, school disciplinary,
# benefits-eligibility, or individual psychological assessment tool.

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
  file.path(raw_dir, "hope_theory_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "hope_indicator_bank.csv"),
  show_col_types = FALSE
)

context_audit <- readr::read_csv(
  file.path(raw_dir, "hope_context_support_audit.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  agency = c("agency1", "agency2"),
  pathways = c("pathways1", "pathways2"),
  goal_clarity = c("goal_clarity1", "goal_clarity2"),
  goal_progress = c("progress1", "progress2"),
  wellbeing = c("wellbeing1", "wellbeing2"),
  meaning = c("meaning1", "meaning2"),
  stress = c("stress1", "stress2"),
  obstacles = c("obstacle1", "obstacle2"),
  support = c("support1", "support2"),
  resources = c("resources1", "resources2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  items <- indicator_bank[, cols]

  if (scale_name %in% c("stress", "obstacles")) {
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
        goal_clarity_support,
        agency_support,
        pathways_support,
        resource_access_support,
        obstacle_mapping_quality,
        privacy_safeguards,
        structural_barrier_review,
        responsible_language
      ),
      na.rm = TRUE
    ),
    lowest_support_dimension = pmap_chr(
      select(
        .,
        goal_clarity_support,
        agency_support,
        pathways_support,
        resource_access_support,
        obstacle_mapping_quality,
        privacy_safeguards,
        structural_barrier_review,
        responsible_language
      ),
      function(...) {
        vals <- c(...)
        names(vals) <- c(
          "goal_clarity_support",
          "agency_support",
          "pathways_support",
          "resource_access_support",
          "obstacle_mapping_quality",
          "privacy_safeguards",
          "structural_barrier_review",
          "responsible_language"
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
    domain = as.factor(domain)
  ) %>%
  filter(complete.cases(
    agency_score,
    pathways_score,
    goal_clarity,
    goal_progress,
    wellbeing_score,
    meaning_score,
    stress_load,
    obstacle_intensity,
    social_support,
    resource_access,
    goal_revision_quality,
    context_support
  )) %>%
  mutate(
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE)),
    agency_z = as.numeric(scale(agency_score)),
    pathways_z = as.numeric(scale(pathways_score)),
    clarity_z = as.numeric(scale(goal_clarity)),
    progress_z = as.numeric(scale(goal_progress)),
    wellbeing_z = as.numeric(scale(wellbeing_score)),
    meaning_z = as.numeric(scale(meaning_score)),
    stress_z = as.numeric(scale(stress_load)),
    obstacle_z = as.numeric(scale(obstacle_intensity)),
    support_z = as.numeric(scale(social_support)),
    resources_z = as.numeric(scale(resource_access)),
    revision_z = as.numeric(scale(goal_revision_quality)),
    context_z = as.numeric(scale(context_support)),
    hope_index = 0.5 * agency_z + 0.5 * pathways_z,
    context_support_index = rowMeans(
      select(., support_z, resources_z, context_z),
      na.rm = TRUE
    ),
    net_pathway_context = pathways_z + context_support_index + revision_z - obstacle_z,
    net_future_orientation =
      agency_z +
      pathways_z +
      clarity_z +
      progress_z +
      meaning_z +
      context_support_index -
      stress_z -
      obstacle_z,
    agency_c = as.numeric(scale(agency_score, center = TRUE, scale = FALSE)),
    pathways_c = as.numeric(scale(pathways_score, center = TRUE, scale = FALSE)),
    clarity_c = as.numeric(scale(goal_clarity, center = TRUE, scale = FALSE)),
    progress_c = as.numeric(scale(goal_progress, center = TRUE, scale = FALSE)),
    wellbeing_c = as.numeric(scale(wellbeing_score, center = TRUE, scale = FALSE)),
    meaning_c = as.numeric(scale(meaning_score, center = TRUE, scale = FALSE)),
    stress_c = as.numeric(scale(stress_load, center = TRUE, scale = FALSE)),
    obstacle_c = as.numeric(scale(obstacle_intensity, center = TRUE, scale = FALSE)),
    support_c = as.numeric(scale(social_support, center = TRUE, scale = FALSE)),
    resources_c = as.numeric(scale(resource_access, center = TRUE, scale = FALSE)),
    revision_c = as.numeric(scale(goal_revision_quality, center = TRUE, scale = FALSE)),
    context_c = as.numeric(scale(context_support, center = TRUE, scale = FALSE)),
    hope_c = as.numeric(scale(hope_index, center = TRUE, scale = FALSE)),
    context_support_c = as.numeric(scale(context_support_index, center = TRUE, scale = FALSE)),
    net_pathway_context_c = as.numeric(scale(net_pathway_context, center = TRUE, scale = FALSE))
  )

hope_items <- panel_scored %>%
  select(agency_z, pathways_z)

hope_alpha <- psych::alpha(hope_items, warnings = FALSE, check.keys = FALSE)

context_items <- panel_scored %>%
  select(support_z, resources_z, context_z, revision_z)

context_alpha <- psych::alpha(context_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    domain = c("agency_pathways_items", "context_support_items"),
    raw_alpha = c(hope_alpha$total$raw_alpha, context_alpha$total$raw_alpha),
    standardized_alpha = c(hope_alpha$total$std.alpha, context_alpha$total$std.alpha),
    average_r = c(hope_alpha$total$average_r, context_alpha$total$average_r)
  ),
  file.path(output_dir, "r_hope_domain_alpha.csv")
)

model_progress <- lmer(
  goal_progress ~
    wave_c +
    agency_c +
    pathways_c +
    clarity_c +
    support_c +
    resources_c +
    revision_c +
    context_c +
    obstacle_c +
    stress_c +
    agency_c:pathways_c +
    pathways_c:obstacle_c +
    context_support_c:obstacle_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_wellbeing <- lmer(
  wellbeing_score ~
    wave_c +
    hope_c +
    progress_c +
    meaning_c +
    context_support_c +
    obstacle_c +
    stress_c +
    hope_c:stress_c +
    net_pathway_context_c:domain +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_meaning <- lmer(
  meaning_score ~
    wave_c +
    agency_c +
    pathways_c +
    progress_c +
    clarity_c +
    context_support_c +
    obstacle_c +
    stress_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_future_orientation <- lmer(
  net_future_orientation ~
    wave_c +
    hope_c +
    context_support_c +
    net_pathway_context_c +
    obstacle_c +
    stress_c +
    domain +
    hope_c:context_support_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

progress_margins <- emmeans(
  model_progress,
  ~ agency_c | pathways_c,
  at = list(
    agency_c = c(-1, 0, 1),
    pathways_c = c(-1, 0, 1),
    clarity_c = 0,
    support_c = 0,
    resources_c = 0,
    revision_c = 0,
    context_c = 0,
    obstacle_c = 0,
    stress_c = 0,
    context_support_c = 0,
    wave_c = 0
  )
)

obstacle_margins <- emmeans(
  model_progress,
  ~ pathways_c | obstacle_c,
  at = list(
    pathways_c = c(-1, 0, 1),
    obstacle_c = c(-1, 0, 1),
    agency_c = 0,
    clarity_c = 0,
    support_c = 0,
    resources_c = 0,
    revision_c = 0,
    context_c = 0,
    stress_c = 0,
    context_support_c = 0,
    wave_c = 0
  )
)

wellbeing_stress_margins <- emmeans(
  model_wellbeing,
  ~ hope_c | stress_c,
  at = list(
    hope_c = c(-1, 0, 1),
    stress_c = c(-1, 0, 1),
    progress_c = 0,
    meaning_c = 0,
    context_support_c = 0,
    obstacle_c = 0,
    net_pathway_context_c = 0,
    wave_c = 0
  )
)

domain_summary <- panel_scored %>%
  group_by(domain) %>%
  summarize(
    mean_agency = mean(agency_score, na.rm = TRUE),
    mean_pathways = mean(pathways_score, na.rm = TRUE),
    mean_goal_clarity = mean(goal_clarity, na.rm = TRUE),
    mean_goal_progress = mean(goal_progress, na.rm = TRUE),
    mean_wellbeing = mean(wellbeing_score, na.rm = TRUE),
    mean_meaning = mean(meaning_score, na.rm = TRUE),
    mean_stress = mean(stress_load, na.rm = TRUE),
    mean_obstacles = mean(obstacle_intensity, na.rm = TRUE),
    mean_support = mean(social_support, na.rm = TRUE),
    mean_resources = mean(resource_access, na.rm = TRUE),
    mean_goal_revision_quality = mean(goal_revision_quality, na.rm = TRUE),
    mean_context_support = mean(context_support, na.rm = TRUE),
    mean_hope_index = mean(hope_index, na.rm = TRUE),
    mean_net_pathway_context = mean(net_pathway_context, na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(broom.mixed::tidy(model_progress, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_hope_goal_progress_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_wellbeing, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_hope_wellbeing_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_meaning, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_hope_meaning_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_future_orientation, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_hope_future_orientation_fixed_effects.csv"))
readr::write_csv(as.data.frame(progress_margins), file.path(output_dir, "r_hope_agency_by_pathways_margins.csv"))
readr::write_csv(as.data.frame(obstacle_margins), file.path(output_dir, "r_hope_pathways_by_obstacles_margins.csv"))
readr::write_csv(as.data.frame(wellbeing_stress_margins), file.path(output_dir, "r_hope_wellbeing_by_stress_margins.csv"))
readr::write_csv(domain_summary, file.path(output_dir, "r_hope_domain_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_hope_scored_panel.csv"))

message("Professional R Hope Theory workflow complete.")
message("Outputs written to: ", output_dir)
