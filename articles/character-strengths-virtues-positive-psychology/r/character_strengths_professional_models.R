# Professional character strengths and virtues modeling scaffold
#
# This workflow is designed for psychologists, positive psychology researchers,
# moral psychologists, educational psychologists, leadership researchers,
# organizational psychologists, counseling researchers, and interdisciplinary
# teams using synthetic data for methods demonstration.
#
# It is not a clinical, diagnostic, therapeutic, crisis-support, workplace-screening,
# employment-selection, student-ranking, employee-evaluation, school-disciplinary,
# benefits-eligibility, moral-ranking, or individual psychological assessment tool.

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
  file.path(raw_dir, "character_strengths_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "character_strengths_indicator_bank.csv"),
  show_col_types = FALSE
)

context_audit <- readr::read_csv(
  file.path(raw_dir, "character_context_audit.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  wisdom = c("wisdom1", "wisdom2"),
  courage = c("courage1", "courage2"),
  humanity = c("humanity1", "humanity2"),
  justice = c("justice1", "justice2"),
  temperance = c("temperance1", "temperance2"),
  transcendence = c("transcendence1", "transcendence2"),
  signature_strength_use = c("signature1", "signature2"),
  authenticity = c("authenticity1", "authenticity2"),
  contextual_support = c("support1", "support2"),
  institutional_suppression = c("suppression1", "suppression2"),
  strength_overuse_risk = c("overuse1", "overuse2"),
  flourishing = c("flourishing1", "flourishing2"),
  meaning = c("meaning1", "meaning2"),
  relationships = c("relationships1", "relationships2"),
  engagement = c("engagement1", "engagement2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  items <- indicator_bank[, cols]

  if (scale_name %in% c("institutional_suppression", "strength_overuse_risk")) {
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
        truth_telling_support,
        fairness_support,
        humility_support,
        leadership_accountability,
        care_support,
        learning_support,
        autonomy_support,
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
        truth_telling_support,
        fairness_support,
        humility_support,
        leadership_accountability,
        care_support,
        learning_support,
        autonomy_support,
        anti_coercion_review,
        privacy_safeguards,
        cultural_adaptation,
        measurement_quality
      ),
      function(...) {
        vals <- c(...)
        names(vals) <- c(
          "truth_telling_support",
          "fairness_support",
          "humility_support",
          "leadership_accountability",
          "care_support",
          "learning_support",
          "autonomy_support",
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

readr::write_csv(context_summary, file.path(output_dir, "r_character_context_audit_summary.csv"))

panel_scored <- panel %>%
  mutate(
    id = as.factor(id),
    wave = as.integer(wave),
    context = as.factor(context)
  ) %>%
  filter(complete.cases(
    flourishing_score,
    signature_strength_use,
    authenticity_score,
    contextual_support,
    institutional_suppression,
    strength_overuse_risk,
    wellbeing_score,
    meaning_score,
    relationship_quality,
    engagement_score
  )) %>%
  mutate(
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE)),
    wisdom = rowMeans(select(., creativity, curiosity, judgment, love_learning, perspective), na.rm = TRUE),
    courage = rowMeans(select(., bravery, perseverance, honesty, zest), na.rm = TRUE),
    humanity = rowMeans(select(., love, kindness, social_intelligence), na.rm = TRUE),
    justice = rowMeans(select(., teamwork, fairness, leadership), na.rm = TRUE),
    temperance = rowMeans(select(., forgiveness, humility, prudence, self_regulation), na.rm = TRUE),
    transcendence = rowMeans(select(., appreciation_beauty, gratitude, hope, humor, spirituality), na.rm = TRUE),
    virtue_profile_mean = rowMeans(
      select(., wisdom, courage, humanity, justice, temperance, transcendence),
      na.rm = TRUE
    ),
    strength_expression_index =
      signature_strength_use +
      authenticity_score +
      contextual_support -
      institutional_suppression -
      strength_overuse_risk,
    civic_character_index =
      fairness +
      leadership +
      humility +
      honesty +
      self_regulation,
    relational_character_index =
      kindness +
      social_intelligence +
      gratitude +
      honesty,
    context_adjusted_flourishing =
      flourishing_score +
      strength_expression_index +
      contextual_support -
      institutional_suppression -
      strength_overuse_risk,
    wisdom_c = as.numeric(scale(wisdom, center = TRUE, scale = FALSE)),
    courage_c = as.numeric(scale(courage, center = TRUE, scale = FALSE)),
    humanity_c = as.numeric(scale(humanity, center = TRUE, scale = FALSE)),
    justice_c = as.numeric(scale(justice, center = TRUE, scale = FALSE)),
    temperance_c = as.numeric(scale(temperance, center = TRUE, scale = FALSE)),
    transcendence_c = as.numeric(scale(transcendence, center = TRUE, scale = FALSE)),
    signature_use_c = as.numeric(scale(signature_strength_use, center = TRUE, scale = FALSE)),
    authenticity_c = as.numeric(scale(authenticity_score, center = TRUE, scale = FALSE)),
    support_c = as.numeric(scale(contextual_support, center = TRUE, scale = FALSE)),
    suppression_c = as.numeric(scale(institutional_suppression, center = TRUE, scale = FALSE)),
    overuse_c = as.numeric(scale(strength_overuse_risk, center = TRUE, scale = FALSE)),
    virtue_profile_c = as.numeric(scale(virtue_profile_mean, center = TRUE, scale = FALSE)),
    strength_expression_c = as.numeric(scale(strength_expression_index, center = TRUE, scale = FALSE)),
    civic_character_c = as.numeric(scale(civic_character_index, center = TRUE, scale = FALSE)),
    relational_character_c = as.numeric(scale(relational_character_index, center = TRUE, scale = FALSE))
  )

virtue_items <- panel_scored %>%
  select(wisdom_c, courage_c, humanity_c, justice_c, temperance_c, transcendence_c)

strength_expression_items <- panel_scored %>%
  select(signature_use_c, authenticity_c, support_c)

virtue_alpha <- psych::alpha(virtue_items, warnings = FALSE, check.keys = FALSE)
strength_expression_alpha <- psych::alpha(strength_expression_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    domain = c("virtue_cluster_items", "strength_expression_items"),
    raw_alpha = c(virtue_alpha$total$raw_alpha, strength_expression_alpha$total$raw_alpha),
    standardized_alpha = c(virtue_alpha$total$std.alpha, strength_expression_alpha$total$std.alpha),
    average_r = c(virtue_alpha$total$average_r, strength_expression_alpha$total$average_r)
  ),
  file.path(output_dir, "r_character_domain_alpha.csv")
)

model_flourishing <- lmer(
  flourishing_score ~
    wave_c +
    wisdom_c +
    courage_c +
    humanity_c +
    justice_c +
    temperance_c +
    transcendence_c +
    signature_use_c +
    authenticity_c +
    support_c +
    suppression_c +
    overuse_c +
    signature_use_c:support_c +
    authenticity_c:suppression_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_meaning <- lmer(
  meaning_score ~
    wave_c +
    signature_use_c +
    transcendence_c +
    wisdom_c +
    authenticity_c +
    support_c +
    suppression_c +
    overuse_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_relationships <- lmer(
  relationship_quality ~
    wave_c +
    humanity_c +
    justice_c +
    forgiveness +
    gratitude +
    social_intelligence +
    support_c +
    suppression_c +
    overuse_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_engagement <- lmer(
  engagement_score ~
    wave_c +
    creativity +
    curiosity +
    love_learning +
    perseverance +
    zest +
    signature_use_c +
    support_c +
    overuse_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_context_adjusted <- lmer(
  context_adjusted_flourishing ~
    wave_c +
    virtue_profile_c +
    strength_expression_c +
    civic_character_c +
    relational_character_c +
    support_c +
    suppression_c +
    overuse_c +
    context +
    strength_expression_c:support_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

strengths_support_margins <- emmeans(
  model_flourishing,
  ~ signature_use_c | support_c,
  at = list(
    signature_use_c = c(-1, 0, 1),
    support_c = c(-1, 0, 1),
    wisdom_c = 0,
    courage_c = 0,
    humanity_c = 0,
    justice_c = 0,
    temperance_c = 0,
    transcendence_c = 0,
    authenticity_c = 0,
    suppression_c = 0,
    overuse_c = 0,
    wave_c = 0
  )
)

authenticity_suppression_margins <- emmeans(
  model_flourishing,
  ~ authenticity_c | suppression_c,
  at = list(
    authenticity_c = c(-1, 0, 1),
    suppression_c = c(-1, 0, 1),
    wisdom_c = 0,
    courage_c = 0,
    humanity_c = 0,
    justice_c = 0,
    temperance_c = 0,
    transcendence_c = 0,
    signature_use_c = 0,
    support_c = 0,
    overuse_c = 0,
    wave_c = 0
  )
)

context_summary_by_domain <- panel_scored %>%
  group_by(context) %>%
  summarize(
    mean_wisdom = mean(wisdom, na.rm = TRUE),
    mean_courage = mean(courage, na.rm = TRUE),
    mean_humanity = mean(humanity, na.rm = TRUE),
    mean_justice = mean(justice, na.rm = TRUE),
    mean_temperance = mean(temperance, na.rm = TRUE),
    mean_transcendence = mean(transcendence, na.rm = TRUE),
    mean_signature_use = mean(signature_strength_use, na.rm = TRUE),
    mean_authenticity = mean(authenticity_score, na.rm = TRUE),
    mean_contextual_support = mean(contextual_support, na.rm = TRUE),
    mean_institutional_suppression = mean(institutional_suppression, na.rm = TRUE),
    mean_overuse_risk = mean(strength_overuse_risk, na.rm = TRUE),
    mean_strength_expression = mean(strength_expression_index, na.rm = TRUE),
    mean_flourishing = mean(flourishing_score, na.rm = TRUE),
    mean_meaning = mean(meaning_score, na.rm = TRUE),
    mean_relationship_quality = mean(relationship_quality, na.rm = TRUE),
    mean_engagement = mean(engagement_score, na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(broom.mixed::tidy(model_flourishing, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_character_strengths_flourishing_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_meaning, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_character_strengths_meaning_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_relationships, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_character_strengths_relationships_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_engagement, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_character_strengths_engagement_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_context_adjusted, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_context_adjusted_character_fixed_effects.csv"))
readr::write_csv(as.data.frame(strengths_support_margins), file.path(output_dir, "r_signature_strength_use_by_support_margins.csv"))
readr::write_csv(as.data.frame(authenticity_suppression_margins), file.path(output_dir, "r_authenticity_by_suppression_margins.csv"))
readr::write_csv(context_summary_by_domain, file.path(output_dir, "r_character_strengths_context_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_character_strengths_scored_panel.csv"))

message("Professional R character strengths workflow complete.")
message("Outputs written to: ", output_dir)
