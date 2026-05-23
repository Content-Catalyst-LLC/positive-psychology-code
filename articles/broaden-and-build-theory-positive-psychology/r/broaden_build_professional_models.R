# Professional Broaden-and-Build Theory modeling scaffold
#
# This workflow is designed for positive psychology researchers, psychologists,
# emotion researchers, resilience researchers, educational researchers,
# organizational researchers, well-being scientists, and interdisciplinary teams
# using synthetic data for methods demonstration.
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
  file.path(raw_dir, "broaden_build_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "broaden_build_indicator_bank.csv"),
  show_col_types = FALSE
)

practice_quality <- readr::read_csv(
  file.path(raw_dir, "broaden_build_practice_quality_audit.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  positive_emotion = c("positive1", "positive2"),
  negative_emotion = c("negative1", "negative2"),
  cognitive_flexibility = c("flexibility1", "flexibility2"),
  exploratory_behavior = c("exploration1", "exploration2"),
  affiliative_behavior = c("affiliation1", "affiliation2"),
  social_support = c("support1", "support2"),
  resilience = c("resilience1", "resilience2"),
  stress_arousal = c("arousal1", "arousal2"),
  contextual_safety = c("safety1", "safety2"),
  resource_stock = c("resource1", "resource2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  items <- indicator_bank[, cols]

  if (scale_name %in% c("negative_emotion", "stress_arousal")) {
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
        emotion_fit,
        mechanism_clarity,
        acceptability,
        contextual_safety,
        privacy_safeguards,
        trauma_sensitive_language,
        implementation_support,
        measurement_quality
      ),
      na.rm = TRUE
    ),
    lowest_quality_dimension = pmap_chr(
      select(
        .,
        emotion_fit,
        mechanism_clarity,
        acceptability,
        contextual_safety,
        privacy_safeguards,
        trauma_sensitive_language,
        implementation_support,
        measurement_quality
      ),
      function(...) {
        vals <- c(...)
        names(vals) <- c(
          "emotion_fit",
          "mechanism_clarity",
          "acceptability",
          "contextual_safety",
          "privacy_safeguards",
          "trauma_sensitive_language",
          "implementation_support",
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
    positive_emotion,
    negative_emotion,
    cognitive_flexibility,
    exploratory_behavior,
    affiliative_behavior,
    social_support,
    resilience_score,
    stress_arousal,
    contextual_safety,
    resource_stock,
    practice_fit
  )) %>%
  mutate(
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE)),
    positive_z = as.numeric(scale(positive_emotion)),
    negative_z = as.numeric(scale(negative_emotion)),
    flexibility_z = as.numeric(scale(cognitive_flexibility)),
    exploration_z = as.numeric(scale(exploratory_behavior)),
    affiliation_z = as.numeric(scale(affiliative_behavior)),
    support_z = as.numeric(scale(social_support)),
    resilience_z = as.numeric(scale(resilience_score)),
    arousal_z = as.numeric(scale(stress_arousal)),
    safety_z = as.numeric(scale(contextual_safety)),
    resource_z = as.numeric(scale(resource_stock)),
    fit_z = as.numeric(scale(practice_fit)),
    broadening_index =
      rowMeans(select(., flexibility_z, exploration_z, affiliation_z, safety_z, positive_z), na.rm = TRUE) -
      0.25 * negative_z,
    resource_index =
      rowMeans(select(., support_z, resilience_z, safety_z, resource_z, fit_z), na.rm = TRUE),
    recovery_capacity =
      rowMeans(select(., positive_z, support_z, safety_z, resilience_z), na.rm = TRUE) -
      0.25 * arousal_z -
      0.25 * negative_z,
    net_adaptation =
      positive_z +
      flexibility_z +
      exploration_z +
      affiliation_z +
      support_z +
      resilience_z +
      safety_z +
      resource_z +
      fit_z -
      negative_z -
      arousal_z,
    positive_c = as.numeric(scale(positive_emotion, center = TRUE, scale = FALSE)),
    negative_c = as.numeric(scale(negative_emotion, center = TRUE, scale = FALSE)),
    flexibility_c = as.numeric(scale(cognitive_flexibility, center = TRUE, scale = FALSE)),
    exploration_c = as.numeric(scale(exploratory_behavior, center = TRUE, scale = FALSE)),
    affiliation_c = as.numeric(scale(affiliative_behavior, center = TRUE, scale = FALSE)),
    support_c = as.numeric(scale(social_support, center = TRUE, scale = FALSE)),
    resilience_c = as.numeric(scale(resilience_score, center = TRUE, scale = FALSE)),
    arousal_c = as.numeric(scale(stress_arousal, center = TRUE, scale = FALSE)),
    safety_c = as.numeric(scale(contextual_safety, center = TRUE, scale = FALSE)),
    resource_c = as.numeric(scale(resource_stock, center = TRUE, scale = FALSE)),
    fit_c = as.numeric(scale(practice_fit, center = TRUE, scale = FALSE)),
    broadening_c = as.numeric(scale(broadening_index, center = TRUE, scale = FALSE)),
    resource_index_c = as.numeric(scale(resource_index, center = TRUE, scale = FALSE))
  )

broadening_items <- panel_scored %>%
  select(flexibility_z, exploration_z, affiliation_z, safety_z, positive_z)

resource_items <- panel_scored %>%
  select(support_z, resilience_z, safety_z, resource_z, fit_z)

broadening_alpha <- psych::alpha(broadening_items, warnings = FALSE, check.keys = FALSE)
resource_alpha <- psych::alpha(resource_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    domain = c("broadening_items", "resource_items"),
    raw_alpha = c(broadening_alpha$total$raw_alpha, resource_alpha$total$raw_alpha),
    standardized_alpha = c(broadening_alpha$total$std.alpha, resource_alpha$total$std.alpha),
    average_r = c(broadening_alpha$total$average_r, resource_alpha$total$average_r)
  ),
  file.path(output_dir, "r_broaden_build_composite_alpha.csv")
)

model_broadening <- lmer(
  broadening_index ~
    wave_c * condition +
    positive_c -
    negative_c +
    safety_c +
    fit_c +
    positive_c:safety_c +
    positive_c:negative_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_resilience <- lmer(
  resilience_score ~
    wave_c * condition +
    positive_c -
    negative_c +
    flexibility_c +
    exploration_c +
    affiliation_c +
    support_c -
    arousal_c +
    safety_c +
    fit_c +
    positive_c:flexibility_c +
    support_c:safety_c +
    broadening_c:condition +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_recovery <- lmer(
  stress_arousal ~
    wave_c * condition -
    positive_c +
    negative_c -
    support_c -
    safety_c -
    resilience_c +
    positive_c:safety_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_net_adaptation <- lmer(
  net_adaptation ~
    wave_c * condition +
    positive_c -
    negative_c +
    broadening_c +
    resource_index_c -
    arousal_c +
    safety_c +
    fit_c +
    condition:safety_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

broadening_margins <- emmeans(
  model_broadening,
  ~ positive_c | safety_c,
  at = list(
    positive_c = c(-1, 0, 1),
    safety_c = c(-1, 0, 1),
    negative_c = 0,
    fit_c = 0,
    wave_c = 0
  )
)

resilience_margins <- emmeans(
  model_resilience,
  ~ positive_c | flexibility_c,
  at = list(
    positive_c = c(-1, 0, 1),
    flexibility_c = c(-1, 0, 1),
    negative_c = 0,
    exploration_c = 0,
    affiliation_c = 0,
    support_c = 0,
    arousal_c = 0,
    safety_c = 0,
    fit_c = 0,
    broadening_c = 0,
    wave_c = 0
  )
)

recovery_margins <- emmeans(
  model_recovery,
  ~ positive_c | safety_c,
  at = list(
    positive_c = c(-1, 0, 1),
    safety_c = c(-1, 0, 1),
    negative_c = 0,
    support_c = 0,
    resilience_c = 0,
    wave_c = 0
  )
)

summary_table <- panel_scored %>%
  group_by(condition) %>%
  summarize(
    mean_positive_emotion = mean(positive_emotion, na.rm = TRUE),
    mean_negative_emotion = mean(negative_emotion, na.rm = TRUE),
    mean_cognitive_flexibility = mean(cognitive_flexibility, na.rm = TRUE),
    mean_exploratory_behavior = mean(exploratory_behavior, na.rm = TRUE),
    mean_affiliative_behavior = mean(affiliative_behavior, na.rm = TRUE),
    mean_social_support = mean(social_support, na.rm = TRUE),
    mean_resilience = mean(resilience_score, na.rm = TRUE),
    mean_stress_arousal = mean(stress_arousal, na.rm = TRUE),
    mean_contextual_safety = mean(contextual_safety, na.rm = TRUE),
    mean_resource_stock = mean(resource_stock, na.rm = TRUE),
    mean_practice_fit = mean(practice_fit, na.rm = TRUE),
    mean_broadening_index = mean(broadening_index, na.rm = TRUE),
    mean_resource_index = mean(resource_index, na.rm = TRUE),
    mean_recovery_capacity = mean(recovery_capacity, na.rm = TRUE),
    mean_net_adaptation = mean(net_adaptation, na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(broom.mixed::tidy(model_broadening, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_broaden_build_broadening_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_resilience, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_broaden_build_resilience_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_recovery, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_broaden_build_recovery_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_net_adaptation, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_broaden_build_net_adaptation_fixed_effects.csv"))
readr::write_csv(as.data.frame(broadening_margins), file.path(output_dir, "r_positive_by_safety_broadening_margins.csv"))
readr::write_csv(as.data.frame(resilience_margins), file.path(output_dir, "r_positive_by_flexibility_resilience_margins.csv"))
readr::write_csv(as.data.frame(recovery_margins), file.path(output_dir, "r_positive_by_safety_recovery_margins.csv"))
readr::write_csv(summary_table, file.path(output_dir, "r_broaden_build_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_broaden_build_scored_panel.csv"))

message("Professional R Broaden-and-Build workflow complete.")
message("Outputs written to: ", output_dir)
