# Professional Self-Determination Theory modeling scaffold
#
# This workflow is designed for psychologists, motivational scientists,
# educational psychologists, organizational researchers, health-behavior
# researchers, sport psychologists, developmental researchers, and
# interdisciplinary teams using synthetic data for methods demonstration.
#
# It is not a clinical, diagnostic, therapeutic, crisis-support, workplace-screening,
# employment-selection, student-ranking, employee-evaluation, school disciplinary,
# public-benefits, or individual psychological assessment tool.

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
  file.path(raw_dir, "self_determination_theory_panel.csv"),
  show_col_types = FALSE
)

indicator_bank <- readr::read_csv(
  file.path(raw_dir, "sdt_indicator_bank.csv"),
  show_col_types = FALSE
)

climate_audit <- readr::read_csv(
  file.path(raw_dir, "sdt_motivational_climate_audit.csv"),
  show_col_types = FALSE
)

indicator_sets <- list(
  autonomy_support = c("autonomy1", "autonomy2"),
  competence_support = c("competence1", "competence2"),
  relatedness_support = c("relatedness1", "relatedness2"),
  need_frustration = c("frustration1", "frustration2"),
  autonomous_motivation = c("autonomous1", "autonomous2"),
  controlled_motivation = c("controlled1", "controlled2"),
  internalization = c("internalization1", "internalization2"),
  wellbeing = c("wellbeing1", "wellbeing2"),
  vitality = c("vitality1", "vitality2")
)

reliability_rows <- purrr::imap_dfr(indicator_sets, function(cols, scale_name) {
  items <- indicator_bank[, cols]

  if (scale_name %in% c("need_frustration", "controlled_motivation")) {
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

climate_summary <- climate_audit %>%
  mutate(
    support_quality_mean = rowMeans(
      select(
        .,
        autonomy_support_design,
        competence_scaffolding,
        relatedness_climate,
        privacy_safeguards,
        power_context_review,
        measurement_quality
      ),
      na.rm = TRUE
    ),
    risk_adjusted_climate_quality = support_quality_mean - 0.35 * need_frustration_risk,
    lowest_support_dimension = pmap_chr(
      select(
        .,
        autonomy_support_design,
        competence_scaffolding,
        relatedness_climate,
        privacy_safeguards,
        power_context_review,
        measurement_quality
      ),
      function(...) {
        vals <- c(...)
        names(vals) <- c(
          "autonomy_support_design",
          "competence_scaffolding",
          "relatedness_climate",
          "privacy_safeguards",
          "power_context_review",
          "measurement_quality"
        )
        names(vals)[which.min(vals)]
      }
    )
  ) %>%
  arrange(desc(risk_adjusted_climate_quality))

readr::write_csv(climate_summary, file.path(output_dir, "r_motivational_climate_audit_summary.csv"))

panel_scored <- panel %>%
  mutate(
    id = as.factor(id),
    wave = as.integer(wave),
    domain = as.factor(domain)
  ) %>%
  filter(complete.cases(
    autonomy_support,
    competence_support,
    relatedness_support,
    need_frustration,
    controlling_pressure,
    autonomous_motivation,
    controlled_motivation,
    internalization,
    wellbeing_score,
    vitality,
    stress_load,
    climate_quality
  )) %>%
  mutate(
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE)),
    autonomy_z = as.numeric(scale(autonomy_support)),
    competence_z = as.numeric(scale(competence_support)),
    relatedness_z = as.numeric(scale(relatedness_support)),
    frustration_z = as.numeric(scale(need_frustration)),
    control_z = as.numeric(scale(controlling_pressure)),
    autonomous_z = as.numeric(scale(autonomous_motivation)),
    controlled_z = as.numeric(scale(controlled_motivation)),
    internalization_z = as.numeric(scale(internalization)),
    wellbeing_z = as.numeric(scale(wellbeing_score)),
    vitality_z = as.numeric(scale(vitality)),
    stress_z = as.numeric(scale(stress_load)),
    climate_z = as.numeric(scale(climate_quality)),
    need_support_index = rowMeans(
      select(., autonomy_z, competence_z, relatedness_z),
      na.rm = TRUE
    ),
    need_balance_index = need_support_index - frustration_z - control_z,
    motivational_quality_index = autonomous_z + internalization_z - controlled_z,
    net_sdt_wellbeing =
      wellbeing_z +
      vitality_z +
      autonomous_z +
      internalization_z +
      need_support_index -
      controlled_z -
      stress_z -
      frustration_z -
      control_z,
    autonomy_c = as.numeric(scale(autonomy_support, center = TRUE, scale = FALSE)),
    competence_c = as.numeric(scale(competence_support, center = TRUE, scale = FALSE)),
    relatedness_c = as.numeric(scale(relatedness_support, center = TRUE, scale = FALSE)),
    frustration_c = as.numeric(scale(need_frustration, center = TRUE, scale = FALSE)),
    control_c = as.numeric(scale(controlling_pressure, center = TRUE, scale = FALSE)),
    autonomous_c = as.numeric(scale(autonomous_motivation, center = TRUE, scale = FALSE)),
    controlled_c = as.numeric(scale(controlled_motivation, center = TRUE, scale = FALSE)),
    internalization_c = as.numeric(scale(internalization, center = TRUE, scale = FALSE)),
    stress_c = as.numeric(scale(stress_load, center = TRUE, scale = FALSE)),
    climate_c = as.numeric(scale(climate_quality, center = TRUE, scale = FALSE)),
    need_balance_c = as.numeric(scale(need_balance_index, center = TRUE, scale = FALSE)),
    motivational_quality_c = as.numeric(scale(motivational_quality_index, center = TRUE, scale = FALSE))
  )

need_items <- panel_scored %>%
  select(autonomy_z, competence_z, relatedness_z)

need_alpha <- psych::alpha(need_items, warnings = FALSE, check.keys = FALSE)

motivation_items <- panel_scored %>%
  transmute(
    autonomous_z = autonomous_z,
    internalization_z = internalization_z,
    controlled_reversed_z = -controlled_z
  )

motivation_alpha <- psych::alpha(motivation_items, warnings = FALSE, check.keys = FALSE)

readr::write_csv(
  tibble(
    domain = c("need_support_items", "motivational_quality_items"),
    raw_alpha = c(need_alpha$total$raw_alpha, motivation_alpha$total$raw_alpha),
    standardized_alpha = c(need_alpha$total$std.alpha, motivation_alpha$total$std.alpha),
    average_r = c(need_alpha$total$average_r, motivation_alpha$total$average_r)
  ),
  file.path(output_dir, "r_sdt_domain_alpha.csv")
)

model_motivation <- lmer(
  autonomous_motivation ~
    wave_c +
    autonomy_c +
    competence_c +
    relatedness_c +
    frustration_c +
    control_c +
    autonomy_c:relatedness_c +
    competence_c:autonomy_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_internalization <- lmer(
  internalization ~
    wave_c +
    autonomy_c +
    competence_c +
    relatedness_c +
    frustration_c +
    control_c +
    autonomous_c +
    controlled_c +
    autonomy_c:relatedness_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_wellbeing <- lmer(
  wellbeing_score ~
    wave_c +
    autonomous_c +
    controlled_c +
    internalization_c +
    autonomy_c +
    competence_c +
    relatedness_c +
    frustration_c +
    control_c +
    stress_c +
    autonomous_c:stress_c +
    need_balance_c:domain +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

model_net_sdt <- lmer(
  net_sdt_wellbeing ~
    wave_c +
    need_balance_c +
    motivational_quality_c +
    climate_c +
    stress_c +
    domain +
    need_balance_c:stress_c +
    (1 + wave_c | id),
  data = panel_scored,
  REML = FALSE
)

motivation_margins <- emmeans(
  model_motivation,
  ~ autonomy_c | relatedness_c,
  at = list(
    autonomy_c = c(-1, 0, 1),
    relatedness_c = c(-1, 0, 1),
    competence_c = 0,
    frustration_c = 0,
    control_c = 0,
    wave_c = 0
  )
)

wellbeing_stress_margins <- emmeans(
  model_wellbeing,
  ~ autonomous_c | stress_c,
  at = list(
    autonomous_c = c(-1, 0, 1),
    stress_c = c(-1, 0, 1),
    controlled_c = 0,
    internalization_c = 0,
    autonomy_c = 0,
    competence_c = 0,
    relatedness_c = 0,
    frustration_c = 0,
    control_c = 0,
    need_balance_c = 0,
    wave_c = 0
  )
)

need_balance_domain_margins <- emmeans(
  model_net_sdt,
  ~ need_balance_c | domain,
  at = list(
    need_balance_c = c(-1, 0, 1),
    motivational_quality_c = 0,
    climate_c = 0,
    stress_c = 0,
    wave_c = 0
  )
)

domain_summary <- panel_scored %>%
  group_by(domain) %>%
  summarize(
    mean_autonomy_support = mean(autonomy_support, na.rm = TRUE),
    mean_competence_support = mean(competence_support, na.rm = TRUE),
    mean_relatedness_support = mean(relatedness_support, na.rm = TRUE),
    mean_need_frustration = mean(need_frustration, na.rm = TRUE),
    mean_controlling_pressure = mean(controlling_pressure, na.rm = TRUE),
    mean_autonomous_motivation = mean(autonomous_motivation, na.rm = TRUE),
    mean_controlled_motivation = mean(controlled_motivation, na.rm = TRUE),
    mean_internalization = mean(internalization, na.rm = TRUE),
    mean_wellbeing = mean(wellbeing_score, na.rm = TRUE),
    mean_vitality = mean(vitality, na.rm = TRUE),
    mean_stress = mean(stress_load, na.rm = TRUE),
    mean_need_balance = mean(need_balance_index, na.rm = TRUE),
    mean_motivational_quality = mean(motivational_quality_index, na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(broom.mixed::tidy(model_motivation, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_sdt_motivation_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_internalization, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_sdt_internalization_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_wellbeing, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_sdt_wellbeing_fixed_effects.csv"))
readr::write_csv(broom.mixed::tidy(model_net_sdt, effects = "fixed", conf.int = TRUE), file.path(output_dir, "r_sdt_net_wellbeing_fixed_effects.csv"))
readr::write_csv(as.data.frame(motivation_margins), file.path(output_dir, "r_sdt_autonomy_by_relatedness_margins.csv"))
readr::write_csv(as.data.frame(wellbeing_stress_margins), file.path(output_dir, "r_sdt_autonomous_motivation_by_stress_margins.csv"))
readr::write_csv(as.data.frame(need_balance_domain_margins), file.path(output_dir, "r_sdt_need_balance_by_domain_margins.csv"))
readr::write_csv(domain_summary, file.path(output_dir, "r_sdt_domain_summary.csv"))
readr::write_csv(panel_scored, file.path(output_dir, "r_sdt_scored_panel.csv"))

message("Professional R Self-Determination Theory workflow complete.")
message("Outputs written to: ", output_dir)
