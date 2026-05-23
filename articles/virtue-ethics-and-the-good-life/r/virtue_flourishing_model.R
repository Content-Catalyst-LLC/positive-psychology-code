suppressPackageStartupMessages({
  library(tidyverse)
  library(psych)
  library(lme4)
  library(lmerTest)
  library(broom.mixed)
})

args <- commandArgs(trailingOnly = FALSE)
file_arg <- "--file="
script_path <- normalizePath(sub(file_arg, "", args[grep(file_arg, args)]))
article_dir <- dirname(dirname(script_path))
data_path <- file.path(article_dir, "data", "virtue_flourishing_panel.csv")
output_dir <- file.path(article_dir, "outputs")
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

df <- read_csv(data_path, show_col_types = FALSE)

panel <- df %>%
  mutate(
    id = as.factor(id),
    wave = as.integer(wave),
    flourishing_composite = rowMeans(select(., meaning, relationships, accomplishment, positive_emotion)),
    virtue_composite = rowMeans(select(., strengths_wisdom, strengths_courage, strengths_humanity,
                                       strengths_justice, strengths_temperance, strengths_transcendence)),
    virtue_c = as.numeric(scale(virtue_composite, center = TRUE, scale = FALSE)),
    wisdom_c = as.numeric(scale(reflective_judgment, center = TRUE, scale = FALSE)),
    institutional_support_c = as.numeric(scale(institutional_support, center = TRUE, scale = FALSE)),
    stress_load_c = as.numeric(scale(stress_load, center = TRUE, scale = FALSE))
  )

alpha_flourishing <- psych::alpha(panel %>% select(meaning, relationships, accomplishment, positive_emotion))
alpha_virtue <- psych::alpha(panel %>% select(starts_with("strengths_")))

model_virtue <- lmer(
  flourishing_composite ~ wave + virtue_c * wisdom_c + institutional_support_c - stress_load_c +
    (1 + wave | id),
  data = panel,
  REML = FALSE
)

tidy_results <- broom.mixed::tidy(model_virtue, effects = "fixed", conf.int = TRUE)
write_csv(tidy_results, file.path(output_dir, "r_panel_model_coefficients.csv"))

capture.output(summary(model_virtue), file = file.path(output_dir, "r_panel_model_summary.txt"))

cat("Flourishing alpha:\n")
print(alpha_flourishing$total)
cat("\nVirtue alpha:\n")
print(alpha_virtue$total)
cat("\nModel summary written to outputs/r_panel_model_summary.txt\n")
