# Professional positive education modeling scaffold
#
# This workflow is designed for educational psychologists, school psychologists,
# well-being researchers, education-policy analysts, and interdisciplinary teams
# using synthetic data for methods demonstration.
#
# It is not a clinical, diagnostic, therapeutic, disciplinary, student-ranking,
# teacher-ranking, school-ranking, employment-selection, public-benefits, or
# individual student assessment tool.

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
  file.path(raw_dir, "positive_education_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "positive_education_indicator_bank.csv"),
  show_col_types = FALSE
)

implementation <- readr::read_csv(
  file.path(raw_dir, "positive_education_implementation_quality.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  academic_development = c("academic1", "academic2"),
  engagement = c("engage1", "engage2"),
  belonging = c("belong1", "belong2"),
  resilience = c("resilience1", "resilience2"),
  school_climate = c("climate1", "climate2"),
  teacher_support = c("support1", "support2"),
  purpose_learning = c("purpose1", "purpose2"),
  strain = c("strain1", "strain2"),
  equity_access = c("equity1", "equity2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  items <- indicator_bank[, cols]

  if (scale_name == "strain") {
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

implementation_summary <- implementation %>%
  mutate(
    computed_quality_mean = rowMeans(
      select(
        .,
        staff_training,
        implementation_fidelity,
        student_voice_in_design,
        family_engagement,
        equity_review,
        privacy_safeguards,
        mental_health_referral_pathway,
        teacher_workload_support,
        whole_school_alignment
      ),
      na.rm = TRUE
    ),
    lowest_quality_dimension = pmap_chr(
      select(
        .,
        staff_training,
        implementation_fidelity,
        student_voice_in_design,
        family_engagement,
        equity_review,
        privacy_safeguards,
        mental_health_referral_pathway,
        teacher_workload_support,
        whole_school_alignment
      ),
      function(...) {
        vals <- c(...)
        names(vals) <- c(
          "staff_training",
          "implementation_fidelity",
          "student_voice_in_design",
          "family_engagement",
          "equity_review",
          "privacy_safeguards",
          "mental_health_referral_pathway",
          "teacher_workload_support",
          "whole_school_alignment"
        )
        names(vals)[which.min(vals)]
      }
    )
  ) %>%
  arrange(desc(computed_quality_mean))

readr::write_csv(implementation_summary, file.path(output_dir, "r_implementation_quality_audit_summary.csv"))

panel_scored <- panel %>%
  mutate(
    student_id = as.factor(student_id),
    school_id = as.factor(school_id),
    grade_band = as.factor(grade_band),
    wave = as.integer(wave)
  ) %>%
  filter(complete.cases(
    academic_score,
    engagement,
    belonging,
    resilience,
    life_satisfaction,
    school_climate,
    teacher_support,
    purpose_learning,
    stress_load,
    exclusion_exposure,
    access_support,
    student_voice
  )) %>%
  mutate(
    academic_z = as.numeric(scale(academic_score)),
    engagement_z = as.numeric(scale(engagement)),
    belonging_z = as.numeric(scale(belonging)),
    resilience_z = as.numeric(scale(resilience)),
    life_satisfaction_z = as.numeric(scale(life_satisfaction)),
    climate_z = as.numeric(scale(school_climate)),
    teacher_support_z = as.numeric(scale(teacher_support)),
    purpose_z = as.numeric(scale(purpose_learning)),
    stress_z = as.numeric(scale(stress_load)),
    exclusion_z = as.numeric(scale(exclusion_exposure)),
    access_z = as.numeric(scale(access_support)),
    voice_z = as.numeric(scale(student_voice)),
    relational_support = rowMeans(select(., belonging_z, teacher_support_z), na.rm = TRUE),
    psychological_resources = rowMeans(select(., resilience_z, life_satisfaction_z, purpose_z), na.rm = TRUE),
    institutional_support = rowMeans(select(., climate_z, access_z, voice_z), na.rm = TRUE),
    school_flourishing =
      0.20 * academic_z +
      0.18 * engagement_z +
      0.18 * relational_support +
      0.18 * psychological_resources +
      0.20 * institutional_support -
      0.14 * stress_z -
      0.16 * exclusion_z,
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE)),
    academic_c = as.numeric(scale(academic_z, center = TRUE, scale = FALSE)),
    climate_c = as.numeric(scale(climate_z, center = TRUE, scale = FALSE)),
    belonging_c = as.numeric(scale(belonging_z, center = TRUE, scale = FALSE)),
    resilience_c = as.numeric(scale(resilience_z, center = TRUE, scale = FALSE)),
    support_c = as.numeric(scale(teacher_support_z, center = TRUE, scale = FALSE)),
    access_c = as.numeric(scale(access_z, center = TRUE, scale = FALSE)),
    voice_c = as.numeric(scale(voice_z, center = TRUE, scale = FALSE)),
    stress_c = as.numeric(scale(stress_z, center = TRUE, scale = FALSE)),
    exclusion_c = as.numeric(scale(exclusion_z, center = TRUE, scale = FALSE))
  )

school_items <- panel_scored %>%
  select(
    engagement_z,
    belonging_z,
    resilience_z,
    life_satisfaction_z,
    climate_z,
    teacher_support_z,
    purpose_z,
    access_z,
    voice_z
  )

school_alpha <- psych::alpha(school_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    domain = "school_flourishing_items",
    raw_alpha = school_alpha$total$raw_alpha,
    standardized_alpha = school_alpha$total$std.alpha,
    average_r = school_alpha$total$average_r
  ),
  file.path(output_dir, "r_school_flourishing_domain_alpha.csv")
)

model_school <- lmer(
  school_flourishing ~
    wave_c +
    academic_c +
    climate_c +
    belonging_c +
    resilience_c +
    support_c +
    access_c +
    voice_c -
    stress_c -
    exclusion_c +
    academic_c:climate_c +
    belonging_c:support_c +
    resilience_c:stress_c +
    access_c:exclusion_c +
    (1 + wave_c | student_id) +
    (1 | school_id),
  data = panel_scored,
  REML = FALSE
)

fixed_effects <- broom.mixed::tidy(model_school, effects = "fixed", conf.int = TRUE)
random_effects <- broom.mixed::tidy(model_school, effects = "ran_pars", conf.int = TRUE)

academic_climate_margins <- emmeans(
  model_school,
  ~ academic_c | climate_c,
  at = list(
    academic_c = c(-1, 0, 1),
    climate_c = c(-1, 0, 1),
    belonging_c = 0,
    resilience_c = 0,
    support_c = 0,
    access_c = 0,
    voice_c = 0,
    stress_c = 0,
    exclusion_c = 0,
    wave_c = 0
  )
)

resilience_stress_margins <- emmeans(
  model_school,
  ~ resilience_c | stress_c,
  at = list(
    resilience_c = c(-1, 0, 1),
    stress_c = c(-1, 0, 1),
    academic_c = 0,
    climate_c = 0,
    belonging_c = 0,
    support_c = 0,
    access_c = 0,
    voice_c = 0,
    exclusion_c = 0,
    wave_c = 0
  )
)

access_exclusion_margins <- emmeans(
  model_school,
  ~ access_c | exclusion_c,
  at = list(
    access_c = c(-1, 0, 1),
    exclusion_c = c(-1, 0, 1),
    academic_c = 0,
    climate_c = 0,
    belonging_c = 0,
    resilience_c = 0,
    support_c = 0,
    voice_c = 0,
    stress_c = 0,
    wave_c = 0
  )
)

school_summary <- panel_scored %>%
  group_by(school_id) %>%
  summarize(
    mean_school_flourishing = mean(school_flourishing, na.rm = TRUE),
    mean_academic = mean(academic_z, na.rm = TRUE),
    mean_engagement = mean(engagement_z, na.rm = TRUE),
    mean_belonging = mean(belonging_z, na.rm = TRUE),
    mean_climate = mean(climate_z, na.rm = TRUE),
    mean_teacher_support = mean(teacher_support_z, na.rm = TRUE),
    mean_access_support = mean(access_z, na.rm = TRUE),
    mean_student_voice = mean(voice_z, na.rm = TRUE),
    mean_stress = mean(stress_z, na.rm = TRUE),
    mean_exclusion = mean(exclusion_z, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_school_flourishing))

readr::write_csv(fixed_effects, file.path(output_dir, "r_positive_education_fixed_effects.csv"))
readr::write_csv(random_effects, file.path(output_dir, "r_positive_education_random_effects.csv"))
readr::write_csv(as.data.frame(academic_climate_margins), file.path(output_dir, "r_academic_by_climate_estimated_margins.csv"))
readr::write_csv(as.data.frame(resilience_stress_margins), file.path(output_dir, "r_resilience_by_stress_estimated_margins.csv"))
readr::write_csv(as.data.frame(access_exclusion_margins), file.path(output_dir, "r_access_by_exclusion_estimated_margins.csv"))
readr::write_csv(school_summary, file.path(output_dir, "r_positive_education_school_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_positive_education_scored_panel.csv"))

message("Professional R positive education workflow complete.")
message("Outputs written to: ", output_dir)
