suppressPackageStartupMessages({
  library(tidyverse)
  library(psych)
  library(lme4)
  library(lmerTest)
  library(broom.mixed)
})

script_path <- tryCatch(normalizePath(sys.frame(1)$ofile), error = function(e) NA_character_)
base_dir <- if (!is.na(script_path)) dirname(dirname(script_path)) else getwd()
data_path <- file.path(base_dir, "data", "raw", "sustainable_wellbeing_panel_sample.csv")
output_dir <- file.path(base_dir, "outputs", "tables")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

df <- read_csv(data_path, show_col_types = FALSE)

panel <- df %>%
  mutate(
    id = as.factor(id),
    year = as.integer(year)
  ) %>%
  filter(complete.cases(
    life_satisfaction, meaning, health, social_trust,
    institutional_quality, ecological_integrity, carbon_pressure,
    inequality_index, income_security, civic_participation
  ))

positive_items <- panel %>%
  select(
    life_satisfaction, meaning, health, social_trust,
    institutional_quality, ecological_integrity,
    income_security, civic_participation
  )

alpha_results <- psych::alpha(positive_items)

panel <- panel %>%
  mutate(
    sustainable_wellbeing =
      rowMeans(select(
        .,
        life_satisfaction, meaning, health,
        social_trust, institutional_quality,
        ecological_integrity, income_security,
        civic_participation
      )) -
      0.5 * carbon_pressure -
      0.5 * inequality_index,
    ecological_integrity_c = as.numeric(scale(ecological_integrity, center = TRUE, scale = FALSE)),
    institutional_quality_c = as.numeric(scale(institutional_quality, center = TRUE, scale = FALSE)),
    carbon_pressure_c = as.numeric(scale(carbon_pressure, center = TRUE, scale = FALSE)),
    inequality_c = as.numeric(scale(inequality_index, center = TRUE, scale = FALSE)),
    year_c = as.numeric(scale(year, center = TRUE, scale = FALSE))
  )

model_sw <- lmer(
  sustainable_wellbeing ~ year_c +
    ecological_integrity_c * institutional_quality_c -
    carbon_pressure_c - inequality_c +
    (1 + year_c | id),
  data = panel,
  REML = FALSE
)

tidy_results <- broom.mixed::tidy(model_sw, effects = "fixed", conf.int = TRUE)
write_csv(tidy_results, file.path(output_dir, "sustainable_wellbeing_model_results.csv"))

alpha_summary <- tibble(
  statistic = c("raw_alpha", "std_alpha"),
  value = c(alpha_results$total$raw_alpha, alpha_results$total$std.alpha)
)

write_csv(alpha_summary, file.path(output_dir, "sustainable_wellbeing_alpha_summary.csv"))

message("R model complete. Outputs written to: ", output_dir)
