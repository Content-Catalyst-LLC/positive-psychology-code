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
data_path <- file.path(base_dir, "data", "raw", "wellbeing_policy_panel.csv")
output_dir <- file.path(base_dir, "outputs", "tables")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

df <- read_csv(data_path, show_col_types = FALSE)

panel <- df %>%
  mutate(
    country = as.factor(country),
    year = as.integer(year)
  ) %>%
  filter(complete.cases(
    life_satisfaction, health_index, trust_index,
    income_security, environmental_quality, policy_exposure,
    inequality_index, democratic_quality
  ))

wb_items <- panel %>%
  select(
    life_satisfaction,
    health_index,
    trust_index,
    income_security,
    environmental_quality
  )

alpha_results <- psych::alpha(wb_items)

panel <- panel %>%
  mutate(
    wellbeing_index = rowMeans(
      select(
        .,
        life_satisfaction,
        health_index,
        trust_index,
        income_security,
        environmental_quality
      ),
      na.rm = TRUE
    ),
    policy_c = as.numeric(scale(policy_exposure, center = TRUE, scale = FALSE)),
    inequality_c = as.numeric(scale(inequality_index, center = TRUE, scale = FALSE)),
    democracy_c = as.numeric(scale(democratic_quality, center = TRUE, scale = FALSE)),
    year_c = as.numeric(scale(year, center = TRUE, scale = FALSE))
  )

model_wb <- lmer(
  wellbeing_index ~ year_c + policy_c + democracy_c - inequality_c +
    policy_c:democracy_c +
    (1 + year_c | country),
  data = panel,
  REML = FALSE
)

fixed_effects <- broom.mixed::tidy(model_wb, effects = "fixed", conf.int = TRUE)

estimated_margins <- emmeans(
  model_wb,
  ~ policy_c | democracy_c,
  at = list(
    policy_c = c(-1, 0, 1),
    democracy_c = c(-1, 0, 1),
    year_c = 0,
    inequality_c = 0
  )
)

alpha_summary <- tibble(
  statistic = c("raw_alpha", "std_alpha"),
  value = c(alpha_results$total$raw_alpha, alpha_results$total$std.alpha)
)

write_csv(fixed_effects, file.path(output_dir, "wellbeing_policy_model_results.csv"))
write_csv(as.data.frame(estimated_margins), file.path(output_dir, "wellbeing_policy_estimated_margins.csv"))
write_csv(alpha_summary, file.path(output_dir, "wellbeing_policy_alpha_summary.csv"))

message("R model complete. Outputs written to: ", output_dir)
