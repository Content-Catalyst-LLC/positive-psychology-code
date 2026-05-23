# Professional PERMA and multidimensional flourishing modeling scaffold
#
# This workflow is designed for positive psychology researchers, well-being scientists,
# educational psychologists, organizational psychologists, public-health researchers,
# community researchers, and interdisciplinary teams using synthetic data for methods demonstration.
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
  file.path(raw_dir, "perma_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "perma_indicator_bank.csv"),
  show_col_types = FALSE
)

context_audit <- readr::read_csv(
  file.path(raw_dir, "perma_context_audit.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  positive_emotion = c("positive_emotion1", "positive_emotion2"),
  engagement = c("engagement1", "engagement2"),
  relationships = c("relationships1", "relationships2"),
  meaning = c("meaning1", "meaning2"),
  accomplishment = c("accomplishment1", "accomplishment2"),
  flourishing = c("flourishing1", "flourishing2"),
  life_satisfaction = c("life_satisfaction1", "life_satisfaction2"),
  institutional_support = c("support1", "support2"),
  institutional_barriers = c("barriers1", "barriers2"),
  autonomy_support = c("autonomy1", "autonomy2"),
  fairness = c("fairness1", "fairness2"),
  psychological_safety = c("safety1", "safety2"),
  access = c("access1", "access2"),
  workload_strain = c("strain1", "strain2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  items <- indicator_bank[, cols]

  if (scale_name %in% c("institutional_barriers", "workload_strain")) {
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
        positive_emotion_support,
        engagement_support,
        relationship_support,
        meaning_support,
        accomplishment_support,
        autonomy_support,
        fairness_support,
        psychological_safety,
        access_support,
        anti_coercion_review,
        privacy_safeguards,
        cultural_adaptation,
        measurement_quality
      ),
      na.rm = TRUE
    ),
    lowest_support_dimension = pmap_chr(
      select(
        .,
        positive_emotion_support,
        engagement_support,
        relationship_support,
        meaning_support,
        accomplishment_support,
        autonomy_support,
        fairness_support,
        psychological_safety,
        access_support,
        anti_coercion_review,
        privacy_safeguards,
        cultural_adaptation,
        measurement_quality
      ),
      function(...) {
        vals <- c(...)
        names(vals) <- c(
          "positive_emotion_support",
          "engagement_support",
          "relationship_support",
          "meaning_support",
          "accomplishment_support",
          "autonomy_support",
          "fairness_support",
          "psychological_safety",
          "access_support",
          "anti_coercion_review",
          "privacy_safeguards",
          "cultural_adaptation",
          "measurement_quality"
        )
        names(vals)[which.min(vals)]
      }
    )
  ) %>%
  arrange(desc(computed_context_quality))

readr::write_csv(context_summary, file.path(output_dir, "r_perma_context_audit_summary.csv"))

panel_scored <- panel %>%
  mutate(
    id = as.factor(id),
    wave = as.integer(wave),
    setting = as.factor(setting)
  ) %>%
  filter(complete.cases(
    positive_emotion,
    engagement,
    relationships,
    meaning,
    accomplishment,
    flourishing_score,
    life_satisfaction,
    institutional_support,
    institutional_barriers,
    autonomy_support,
    fairness_score,
    psychological_safety,
    access_score,
    workload_strain
  )) %>%
  mutate(
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE)),
    p_c = as.numeric(scale(positive_emotion, center = TRUE, scale = FALSE)),
    e_c = as.numeric(scale(engagement, center = TRUE, scale = FALSE)),
    r_c = as.numeric(scale(relationships, center = TRUE, scale = FALSE)),
    m_c = as.numeric(scale(meaning, center = TRUE, scale = FALSE)),
    a_c = as.numeric(scale(accomplishment, center = TRUE, scale = FALSE)),
    flourishing_c = as.numeric(scale(flourishing_score, center = TRUE, scale = FALSE)),
    life_satisfaction_c = as.numeric(scale(life_satisfaction, center = TRUE, scale = FALSE)),
    support_c = as.numeric(scale(institutional_support, center = TRUE, scale = FALSE)),
    barriers_c = as.numeric(scale(institutional_barriers, center = TRUE, scale = FALSE)),
    autonomy_c = as.numeric(scale(autonomy_support, center = TRUE, scale = FALSE)),
    fairness_c = as.numeric(scale(fairness_score, center = TRUE, scale = FALSE)),
    safety_c = as.numeric(scale(psychological_safety, center = TRUE, scale = FALSE)),
    access_c = as.numeric(scale(access_score, center = TRUE, scale = FALSE)),
    strain_c = as.numeric(scale(workload_strain, center = TRUE, scale = FALSE)),
    perma_index = rowMeans(select(., p_c, e_c, r_c, m_c, a_c), na.rm = TRUE),
    perma_profile_variance = apply(select(., p_c, e_c, r_c, m_c, a_c), 1, var, na.rm = TRUE),
    perma_balance = -perma_profile_variance,
    institutional_quality =
      support_c +
      autonomy_c +
      fairness_c +
      safety_c +
      access_c -
      barriers_c -
      strain_c,
    context_adjusted_flourishing =
      flourishing_c +
      life_satisfaction_c +
      perma_index +
      perma_balance +
      institutional_quality
  )

perma_items <- panel_scored %>%
  select(p_c, e_c, r_c, m_c, a_c)

institutional_items <- panel_scored %>%
  select(support_c, autonomy_c, fairness_c, safety_c, access_c, barriers_c, strain_c) %>%
  mutate(
    barriers_c = -barriers_c,
    strain_c = -strain_c
  )

perma_alpha <- psych::alpha(perma_items, warnings = FALSE, check.keys = FALSE)
institutional_alpha <- psych::alpha(institutional_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    domain = c("perma_profile_items", "institutional_quality_items"),
    raw_alpha = c(perma_alpha$total$raw_alpha, institutional_alpha$total$raw_alpha),
    standardized_alpha = c(perma_alpha$total$std.alpha, institutional_alpha$total$std.alpha),
    average_r = c(perma_alpha$total$average_r, institutional_alpha$total$average_r)
  ),
  file.path(output_dir, "r_perma_domain_alpha.csv")
)

model_flourishing <- lmer(
  flourishing_score ~
    wave_c +
    p_c +
    e_c +
    r_c +
    m_c +
    a_c +
    support_c +
    barriers_c +
    autonomy_c +
    fairness_c +
    safety_c +
    access_c +
    strain_c +
    perma_balance +
    perma_index:support_c +
    perma_index:barriers_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_life_satisfaction <- lmer(
  life_satisfaction ~
    wave_c +
    perma_index +
    perma_balance +
    institutional_quality +
    setting +
    perma_index:institutional_quality +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_context_adjusted <- lmer(
  context_adjusted_flourishing ~
    wave_c +
    perma_index +
    perma_balance +
    institutional_quality +
    setting +
    perma_index:institutional_quality +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

perma_support_margins <- emmeans(
  model_flourishing,
  ~ perma_index | support_c,
  at = list(
    perma_index = c(-1, 0, 1),
    support_c = c(-1, 0, 1),
    barriers_c = 0,
    p_c = 0,
    e_c = 0,
    r_c = 0,
    m_c = 0,
    a_c = 0,
    autonomy_c = 0,
    fairness_c = 0,
    safety_c = 0,
    access_c = 0,
    strain_c = 0,
    perma_balance = 0,
    wave_c = 0
  )
)

perma_barriers_margins <- emmeans(
  model_flourishing,
  ~ perma_index | barriers_c,
  at = list(
    perma_index = c(-1, 0, 1),
    barriers_c = c(-1, 0, 1),
    support_c = 0,
    p_c = 0,
    e_c = 0,
    r_c = 0,
    m_c = 0,
    a_c = 0,
    autonomy_c = 0,
    fairness_c = 0,
    safety_c = 0,
    access_c = 0,
    strain_c = 0,
    perma_balance = 0,
    wave_c = 0
  )
)

setting_summary <- panel_scored %>%
  group_by(setting) %>%
  summarize(
    mean_positive_emotion = mean(positive_emotion, na.rm = TRUE),
    mean_engagement = mean(engagement, na.rm = TRUE),
    mean_relationships = mean(relationships, na.rm = TRUE),
    mean_meaning = mean(meaning, na.rm = TRUE),
    mean_accomplishment = mean(accomplishment, na.rm = TRUE),
    mean_perma_index = mean(perma_index, na.rm = TRUE),
    mean_perma_balance = mean(perma_balance, na.rm = TRUE),
    mean_institutional_support = mean(institutional_support, na.rm = TRUE),
    mean_institutional_barriers = mean(institutional_barriers, na.rm = TRUE),
    mean_institutional_quality = mean(institutional_quality, na.rm = TRUE),
    mean_flourishing = mean(flourishing_score, na.rm = TRUE),
    mean_life_satisfaction = mean(life_satisfaction, na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(broom.mixed::tidy(model_flourishing, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_perma_flourishing_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_life_satisfaction, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_perma_life_satisfaction_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_context_adjusted, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_context_adjusted_flourishing_fixed_effects.csv"))
readr::write_csv(as.data.frame(perma_support_margins), file.path(output_dir, "r_perma_by_institutional_support_margins.csv"))
readr::write_csv(as.data.frame(perma_barriers_margins), file.path(output_dir, "r_perma_by_institutional_barriers_margins.csv"))
readr::write_csv(setting_summary, file.path(output_dir, "r_perma_setting_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_perma_scored_panel.csv"))

message("Professional R PERMA workflow complete.")
message("Outputs written to: ", output_dir)
