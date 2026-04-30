# Synthetic positive psychology analysis.
# Run after the Python script creates data/processed/synthetic_flourishing_observations.csv.

data_path <- file.path("data", "processed", "synthetic_flourishing_observations.csv")

if (!file.exists(data_path)) {
  stop("Run: python3 python/flourishing_simulation.py")
}

dat <- read.csv(data_path)

summary_table <- aggregate(
  cbind(flourishing_index, positive_emotion, engagement, relationships,
        meaning, accomplishment, health, hope, resilience, social_support,
        stress_load, intervention_exposure) ~ wave,
  data = dat,
  FUN = mean
)

dir.create("outputs", showWarnings = FALSE, recursive = TRUE)
write.csv(summary_table, file.path("outputs", "flourishing_wave_summary.csv"), row.names = FALSE)

model <- lm(
  flourishing_index ~ positive_emotion + engagement + relationships +
    meaning + accomplishment + health + hope + resilience +
    social_support + intervention_exposure - stress_load,
  data = dat
)

print(summary(model))
print(summary_table)
