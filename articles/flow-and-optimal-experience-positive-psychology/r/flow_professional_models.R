# Professional flow and optimal experience modeling scaffold
#
# This workflow is designed for psychologists, positive psychology researchers,
# educational psychologists, cognitive psychologists, creativity researchers,
# sport psychologists, work and organizational psychologists, human factors
# researchers, and interdisciplinary teams using synthetic data for methods demonstration.
#
# It is not a clinical, diagnostic, therapeutic, crisis-support, workplace-screening,
# employment-selection, student-ranking, employee-evaluation, productivity-surveillance,
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
  file.path(raw_dir, "flow_optimal_experience_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "flow_indicator_bank.csv"),
  show_col_types = FALSE
)

context_audit <- readr::read_csv(
  file.path(raw_dir, "flow_attention_context_audit.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  challenge = c("challenge1", "challenge2"),
  skill = c("skill1", "skill2"),
  attention = c("attention1", "attention2"),
  feedback = c("feedback1", "feedback2"),
  clarity = c("clarity1", "clarity2"),
  meaning = c("meaning1", "meaning2"),
  autonomy = c("autonomy1", "autonomy2"),
  distraction = c("distraction1", "distraction2"),
  flow = c("flow1", "flow2"),
  performance = c("performance1", "performance2"),
  fatigue = c("fatigue1", "fatigue2"),
  recovery = c("recovery1", "recovery2"),
  wellbeing = c("wellbeing1", "wellbeing2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  items <- indicator_bank[, cols]

  if (scale_name %in% c("distraction", "fatigue")) {
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
        feedback_quality_support,
        challenge_calibration,
        skill_development_support,
        attention_protection,
        autonomy_support_quality,
        distraction_control,
        recovery_support,
        privacy_safeguards,
        anti_surveillance_review
      ),
      na.rm = TRUE
    ),
    lowest_support_dimension = pmap_chr(
      select(
        .,
        goal_clarity_support,
        feedback_quality_support,
        challenge_calibration,
        skill_development_support,
        attention_protection,
        autonomy_support_quality,
        distraction_control,
        recovery_support,
        privacy_safeguards,
        anti_surveillance_review
      ),
      function(...) {
        vals <- c(...)
        names(vals) <- c(
          "goal_clarity_support",
          "feedback_quality_support",
          "challenge_calibration",
          "skill_development_support",
          "attention_protection",
          "autonomy_support_quality",
          "distraction_control",
          "recovery_support",
          "privacy_safeguards",
          "anti_surveillance_review"
        )
        names(vals)[which.min(vals)]
      }
    )
  ) %>%
  arrange(desc(computed_context_quality))

readr::write_csv(context_summary, file.path(output_dir, "r_attention_context_audit_summary.csv"))

panel_scored <- panel %>%
  mutate(
    id = as.factor(id),
    session = as.integer(session),
    domain = as.factor(domain)
  ) %>%
  filter(complete.cases(
    challenge_level,
    skill_level,
    attention_focus,
    feedback_quality,
    goal_clarity,
    task_meaning,
    autonomy_support,
    distraction_load,
    interruption_count,
    flow_score,
    performance_score,
    learning_gain,
    fatigue_score,
    recovery_quality,
    wellbeing_score
  )) %>%
  mutate(
    session_c = as.numeric(scale(session, center = TRUE, scale = FALSE)),
    challenge_c = as.numeric(scale(challenge_level, center = TRUE, scale = FALSE)),
    skill_c = as.numeric(scale(skill_level, center = TRUE, scale = FALSE)),
    attention_c = as.numeric(scale(attention_focus, center = TRUE, scale = FALSE)),
    feedback_c = as.numeric(scale(feedback_quality, center = TRUE, scale = FALSE)),
    clarity_c = as.numeric(scale(goal_clarity, center = TRUE, scale = FALSE)),
    meaning_c = as.numeric(scale(task_meaning, center = TRUE, scale = FALSE)),
    autonomy_c = as.numeric(scale(autonomy_support, center = TRUE, scale = FALSE)),
    distraction_c = as.numeric(scale(distraction_load, center = TRUE, scale = FALSE)),
    interruption_c = as.numeric(scale(interruption_count, center = TRUE, scale = FALSE)),
    fatigue_c = as.numeric(scale(fatigue_score, center = TRUE, scale = FALSE)),
    recovery_c = as.numeric(scale(recovery_quality, center = TRUE, scale = FALSE)),
    flow_c = as.numeric(scale(flow_score, center = TRUE, scale = FALSE)),
    performance_c = as.numeric(scale(performance_score, center = TRUE, scale = FALSE)),
    learning_c = as.numeric(scale(learning_gain, center = TRUE, scale = FALSE)),
    balance_index = -abs(challenge_c - skill_c),
    attentional_ecology =
      attention_focus +
      feedback_quality +
      goal_clarity -
      distraction_load -
      interruption_count,
    sustainable_flow_index =
      flow_score +
      task_meaning +
      autonomy_support +
      recovery_quality -
      fatigue_score -
      distraction_load,
    deep_engagement_context =
      balance_index +
      attention_c +
      feedback_c +
      clarity_c +
      meaning_c +
      autonomy_c -
      distraction_c -
      interruption_c
  )

flow_items <- panel_scored %>%
  select(attention_c, feedback_c, clarity_c, meaning_c, autonomy_c, flow_c)

attention_context_items <- panel_scored %>%
  select(attention_c, feedback_c, clarity_c, recovery_c)

flow_alpha <- psych::alpha(flow_items, warnings = FALSE, check.keys = FALSE)
attention_context_alpha <- psych::alpha(attention_context_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    domain = c("flow_context_items", "attention_context_items"),
    raw_alpha = c(flow_alpha$total$raw_alpha, attention_context_alpha$total$raw_alpha),
    standardized_alpha = c(flow_alpha$total$std.alpha, attention_context_alpha$total$std.alpha),
    average_r = c(flow_alpha$total$average_r, attention_context_alpha$total$average_r)
  ),
  file.path(output_dir, "r_flow_domain_alpha.csv")
)

model_flow <- lmer(
  flow_score ~
    session_c +
    balance_index +
    attention_c +
    feedback_c +
    clarity_c +
    meaning_c +
    autonomy_c +
    distraction_c +
    interruption_c +
    fatigue_c +
    recovery_c +
    balance_index:attention_c +
    meaning_c:autonomy_c +
    (1 + session_c | id),
  data = panel_scored,
  REML = FALSE
)

model_performance <- lmer(
  performance_score ~
    session_c +
    flow_score +
    balance_index +
    attention_c +
    feedback_c +
    learning_gain +
    distraction_c +
    fatigue_c +
    recovery_c +
    (1 + session_c | id),
  data = panel_scored,
  REML = FALSE
)

model_learning <- lmer(
  learning_gain ~
    session_c +
    flow_c +
    balance_index +
    feedback_c +
    attention_c +
    autonomy_c +
    distraction_c +
    fatigue_c +
    (1 + session_c | id),
  data = panel_scored,
  REML = FALSE
)

model_wellbeing <- lmer(
  wellbeing_score ~
    session_c +
    flow_score +
    task_meaning +
    autonomy_support +
    recovery_quality +
    fatigue_score +
    distraction_load +
    flow_score:recovery_quality +
    (1 + session_c | id),
  data = panel_scored,
  REML = FALSE
)

model_sustainable_flow <- lmer(
  sustainable_flow_index ~
    session_c +
    deep_engagement_context +
    recovery_c +
    fatigue_c +
    distraction_c +
    domain +
    deep_engagement_context:recovery_c +
    (1 + session_c | id),
  data = panel_scored,
  REML = FALSE
)

flow_balance_attention_margins <- emmeans(
  model_flow,
  ~ balance_index | attention_c,
  at = list(
    balance_index = c(-1, 0, 1),
    attention_c = c(-1, 0, 1),
    feedback_c = 0,
    clarity_c = 0,
    meaning_c = 0,
    autonomy_c = 0,
    distraction_c = 0,
    interruption_c = 0,
    fatigue_c = 0,
    recovery_c = 0,
    session_c = 0
  )
)

flow_attention_distraction_margins <- emmeans(
  model_flow,
  ~ attention_c | distraction_c,
  at = list(
    attention_c = c(-1, 0, 1),
    distraction_c = c(-1, 0, 1),
    balance_index = 0,
    feedback_c = 0,
    clarity_c = 0,
    meaning_c = 0,
    autonomy_c = 0,
    interruption_c = 0,
    fatigue_c = 0,
    recovery_c = 0,
    session_c = 0
  )
)

wellbeing_recovery_margins <- emmeans(
  model_wellbeing,
  ~ flow_score | recovery_quality,
  at = list(
    flow_score = quantile(panel_scored$flow_score, probs = c(0.25, 0.50, 0.75), na.rm = TRUE),
    recovery_quality = quantile(panel_scored$recovery_quality, probs = c(0.25, 0.50, 0.75), na.rm = TRUE),
    task_meaning = mean(panel_scored$task_meaning, na.rm = TRUE),
    autonomy_support = mean(panel_scored$autonomy_support, na.rm = TRUE),
    fatigue_score = mean(panel_scored$fatigue_score, na.rm = TRUE),
    distraction_load = mean(panel_scored$distraction_load, na.rm = TRUE),
    session_c = 0
  )
)

domain_summary <- panel_scored %>%
  group_by(domain) %>%
  summarize(
    mean_challenge = mean(challenge_level, na.rm = TRUE),
    mean_skill = mean(skill_level, na.rm = TRUE),
    mean_attention = mean(attention_focus, na.rm = TRUE),
    mean_feedback = mean(feedback_quality, na.rm = TRUE),
    mean_goal_clarity = mean(goal_clarity, na.rm = TRUE),
    mean_task_meaning = mean(task_meaning, na.rm = TRUE),
    mean_autonomy = mean(autonomy_support, na.rm = TRUE),
    mean_distraction = mean(distraction_load, na.rm = TRUE),
    mean_interruptions = mean(interruption_count, na.rm = TRUE),
    mean_flow = mean(flow_score, na.rm = TRUE),
    mean_performance = mean(performance_score, na.rm = TRUE),
    mean_learning_gain = mean(learning_gain, na.rm = TRUE),
    mean_fatigue = mean(fatigue_score, na.rm = TRUE),
    mean_recovery = mean(recovery_quality, na.rm = TRUE),
    mean_wellbeing = mean(wellbeing_score, na.rm = TRUE),
    mean_sustainable_flow = mean(sustainable_flow_index, na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(broom.mixed::tidy(model_flow, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_flow_model_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_performance, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_flow_performance_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_learning, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_flow_learning_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_wellbeing, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_flow_wellbeing_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_sustainable_flow, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_sustainable_flow_fixed_effects.csv"))
readr::write_csv(as.data.frame(flow_balance_attention_margins), file.path(output_dir, "r_flow_balance_by_attention_margins.csv"))
readr::write_csv(as.data.frame(flow_attention_distraction_margins), file.path(output_dir, "r_flow_attention_by_distraction_margins.csv"))
readr::write_csv(as.data.frame(wellbeing_recovery_margins), file.path(output_dir, "r_flow_wellbeing_by_recovery_margins.csv"))
readr::write_csv(domain_summary, file.path(output_dir, "r_flow_domain_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_flow_scored_panel.csv"))

message("Professional R flow workflow complete.")
message("Outputs written to: ", output_dir)
