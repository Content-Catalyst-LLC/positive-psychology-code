"""Synthetic positive psychology flourishing simulation.

This script creates toy longitudinal flourishing data for article examples.
It is educational only and not a clinical, diagnostic, or well-being assessment tool.
"""

from pathlib import Path
import csv
import random

random.seed(42)

n_people = 220
n_waves = 10

rows = []
observation_id = 1

for person_index in range(1, n_people + 1):
    participant = f"P{person_index:03d}"

    positive_emotion = random.uniform(0.25, 0.85)
    engagement = random.uniform(0.25, 0.85)
    relationships = random.uniform(0.25, 0.85)
    meaning = random.uniform(0.25, 0.85)
    accomplishment = random.uniform(0.25, 0.85)
    health = random.uniform(0.25, 0.85)
    hope = random.uniform(0.25, 0.85)
    resilience = random.uniform(0.25, 0.85)
    social_support = random.uniform(0.20, 0.95)
    stress_load = random.uniform(0.05, 0.80)

    for wave in range(1, n_waves + 1):
        intervention_exposure = random.choice([0.0, 0.25, 0.50, 0.75, 1.0])

        flourishing_index = (
            0.10 * positive_emotion +
            0.14 * engagement +
            0.18 * relationships +
            0.18 * meaning +
            0.12 * accomplishment +
            0.12 * health +
            0.08 * hope +
            0.08 * resilience +
            0.08 * social_support -
            0.12 * stress_load +
            0.06 * intervention_exposure
        )

        flourishing_index = max(0.0, min(1.0, flourishing_index + random.gauss(0.0, 0.035)))

        rows.append({
            "observation_id": observation_id,
            "participant": participant,
            "wave": wave,
            "positive_emotion": round(positive_emotion, 3),
            "engagement": round(engagement, 3),
            "relationships": round(relationships, 3),
            "meaning": round(meaning, 3),
            "accomplishment": round(accomplishment, 3),
            "health": round(health, 3),
            "hope": round(hope, 3),
            "resilience": round(resilience, 3),
            "social_support": round(social_support, 3),
            "stress_load": round(stress_load, 3),
            "intervention_exposure": round(intervention_exposure, 3),
            "flourishing_index": round(flourishing_index, 3),
        })

        positive_emotion = max(0.0, min(1.0, positive_emotion + 0.015 * (flourishing_index - 0.45)))
        engagement = max(0.0, min(1.0, engagement + 0.018 * (flourishing_index - 0.45)))
        relationships = max(0.0, min(1.0, relationships + 0.015 * (social_support - 0.45)))
        meaning = max(0.0, min(1.0, meaning + 0.017 * (flourishing_index - 0.45)))
        hope = max(0.0, min(1.0, hope + 0.020 * intervention_exposure - 0.012 * stress_load))
        resilience = max(0.0, min(1.0, resilience + 0.012 * social_support - 0.010 * stress_load))
        stress_load = max(0.0, min(1.0, stress_load + random.gauss(0.0, 0.025) - 0.006 * social_support))

        observation_id += 1

processed = Path(__file__).resolve().parents[1] / "data" / "processed"
processed.mkdir(parents=True, exist_ok=True)

out_path = processed / "synthetic_flourishing_observations.csv"

with out_path.open("w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=rows[0].keys())
    writer.writeheader()
    writer.writerows(rows)

print(f"Wrote {len(rows)} flourishing observations to {out_path}")
