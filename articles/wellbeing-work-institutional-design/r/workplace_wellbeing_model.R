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
data_path <- file.path(base_dir, "data", "raw", "workplace_wellbeing_panel.csv")
output_dir <- file.path(base_dir, "outputs", "tables")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

df <- read_csv(data_path, show_col_types = FALSE)

panel <- df %>%
  mutate(
    employee_id = as.factor(employee_id),
    wave = as.integer(wave)
  ) %>%
  filter(complete.cases(
    autonomy_support, competence_growth, relatedness_trust,
    work_meaning, psychological_safety, role_overload,
    job_insecurity, supervisor_support, recovery_capacity
  ))

wb_items <- panel %>%
  select(
    autonomy_support,
    competence_growth,
    relatedness_trust,
    work_meaning,
    psychological_safety
  )

alpha_results <- psych::alpha(wb_items)

panel <- panel %>%
  mutate(
    workplace_flourishing = rowMeans(
      select(
        .,
        autonomy_support,
        competence_growth,
        relatedness_trust,
        work_meaning,
        psychological_safety
      ),
      na.rm = TRUE
    ) -
      0.5 * role_overload -
      0.5 * job_insecurity,
    support_c = as.numeric(scale(supervisor_support, center = TRUE, scale = FALSE)),
    recovery_c = as.numeric(scale(recovery_capacity, center = TRUE, scale = FALSE)),
    overload_c = as.numeric(scale(role_overload, center = TRUE, scale = FALSE)),
    insecurity_c = as.numeric(scale(job_insecurity, center = TRUE, scale = FALSE)),
    wave_c = as.numeric(scale(wave, center = TRUE, scale = FALSE))
  )

model_work <- lmer(
  workplace_flourishing ~ wave_c + support_c + recovery_c -
    overload_c - insecurity_c +
    support_c:overload_c +
    (1 + wave_c | employee_id),
  data = panel,
  REML = FALSE
)

fixed_effects <- broom.mixed::tidy(model_work, effects = "fixed", conf.int = TRUE)

estimated_margins <- emmeans(
  model_work,
  ~ support_c | overload_c,
  at = list(
    support_c = c(-1, 0, 1),
    overload_c = c(-1, 0, 1),
    recovery_c = 0,
    insecurity_c = 0,
    wave_c = 0
  )
)

alpha_summary <- tibble(
  statistic = c("raw_alpha", "std_alpha"),
  value = c(alpha_results$total$raw_alpha, alpha_results$total$std.alpha)
)

write_csv(fixed_effects, file.path(output_dir, "workplace_flourishing_model_results.csv"))
write_csv(as.data.frame(estimated_margins), file.path(output_dir, "workplace_flourishing_estimated_margins.csv"))
write_csv(alpha_summary, file.path(output_dir, "workplace_flourishing_alpha_summary.csv"))

message("R model complete. Outputs written to: ", output_dir)
