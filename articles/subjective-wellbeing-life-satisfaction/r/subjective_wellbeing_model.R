suppressPackageStartupMessages({
  library(tidyverse)
  library(psych)
  library(lme4)
  library(lmerTest)
  library(broom.mixed)
  library(emmeans)
})

script_path <- tryCatch(normalizePath(sys.frame(1)$ofile), error = function(e) NA_character_)
base_dir <- if (!is.na(script_path)) dirname(dirname(script_path)) else getwd()
data_path <- file.path(base_dir, "data", "raw", "subjective_wellbeing_panel.csv")
output_dir <- file.path(base_dir, "outputs", "tables")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

df <- read_csv(data_path, show_col_types = FALSE)

panel <- df %>%
  mutate(
    id = as.factor(id),
    wave = as.integer(wave)
  ) %>%
  filter(complete.cases(
    life_satisfaction,
    positive_affect,
    negative_affect,
    social_support,
    income_security,
    meaning_alignment,
    stress_load
  ))

swb_items <- panel %>%
  select(
    life_satisfaction,
    positive_affect,
    negative_affect
  )

alpha_results <- psych::alpha(
  swb_items %>%
    mutate(negative_affect = -negative_affect)
)

panel <- panel %>%
  mutate(
    swb_index =
      as.numeric(scale(life_satisfaction)) +
      as.numeric(scale(positive_affect)) -
      as.numeric(scale(negative_affect)),
    support_c = as.numeric(scale(social_support, center = TRUE, scale = FALSE)),
    security_c = as.numeric(scale(income_security, center = TRUE, scale = FALSE)),
    meaning_c = as.numeric(scale(meaning_alignment, center = TRUE, scale = FALSE)),
    stress_c = as.numeric(scale(stress_load, center = TRUE, scale = FALSE)),
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE))
  )

model_swb <- lmer(
  swb_index ~ wave_c + support_c + security_c + meaning_c - stress_c +
    support_c:stress_c +
    (1 + wave_c | id),
  data = panel,
  REML = FALSE
)

fixed_effects <- broom.mixed::tidy(model_swb, effects = "fixed", conf.int = TRUE)

estimated_margins <- emmeans(
  model_swb,
  ~ support_c | stress_c,
  at = list(
    support_c = c(-1, 0, 1),
    stress_c = c(-1, 0, 1),
    security_c = 0,
    meaning_c = 0,
    wave_c = 0
  )
)

alpha_summary <- tibble(
  statistic = c("raw_alpha", "std_alpha"),
  value = c(alpha_results$total$raw_alpha, alpha_results$total$std.alpha)
)

write_csv(fixed_effects, file.path(output_dir, "subjective_wellbeing_model_results.csv"))
write_csv(as.data.frame(estimated_margins), file.path(output_dir, "subjective_wellbeing_estimated_margins.csv"))
write_csv(alpha_summary, file.path(output_dir, "subjective_wellbeing_alpha_summary.csv"))

message("R model complete. Outputs written to: ", output_dir)
