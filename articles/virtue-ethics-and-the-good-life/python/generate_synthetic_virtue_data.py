"""Generate synthetic panel and cross-sectional data for virtue/flourishing research."""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data"
DATA_DIR.mkdir(parents=True, exist_ok=True)

RNG = np.random.default_rng(20260522)


def clamp_likert(x, low: float = 1.0, high: float = 5.0):
    return np.clip(x, low, high)


def generate_panel(n_people: int = 240, n_waves: int = 4) -> pd.DataFrame:
    rows = []
    person_virtue = RNG.normal(0, 1, n_people)
    person_wisdom = 0.55 * person_virtue + RNG.normal(0, 0.8, n_people)
    person_support = RNG.normal(0, 1, n_people)
    person_stress = -0.35 * person_support + RNG.normal(0, 1, n_people)

    for pid in range(1, n_people + 1):
        for wave in range(1, n_waves + 1):
            virtue_latent = person_virtue[pid - 1] + 0.10 * (wave - 1) + RNG.normal(0, 0.35)
            wisdom_latent = person_wisdom[pid - 1] + 0.08 * (wave - 1) + RNG.normal(0, 0.30)
            support_latent = person_support[pid - 1] + RNG.normal(0, 0.25)
            stress_latent = person_stress[pid - 1] + RNG.normal(0, 0.35)

            domains = {
                "strengths_wisdom": virtue_latent + 0.35 * wisdom_latent + RNG.normal(0, 0.40),
                "strengths_courage": virtue_latent + 0.15 * stress_latent + RNG.normal(0, 0.45),
                "strengths_humanity": virtue_latent + 0.25 * support_latent + RNG.normal(0, 0.40),
                "strengths_justice": virtue_latent + 0.30 * wisdom_latent + RNG.normal(0, 0.40),
                "strengths_temperance": virtue_latent - 0.20 * stress_latent + RNG.normal(0, 0.45),
                "strengths_transcendence": virtue_latent + 0.20 * wisdom_latent + RNG.normal(0, 0.50),
            }

            scaled_domains = {k: float(clamp_likert(3.5 + 0.55 * v)) for k, v in domains.items()}
            virtue_index = float(np.mean(list(scaled_domains.values())))
            reflective_judgment = float(clamp_likert(3.4 + 0.55 * wisdom_latent))
            institutional_support = float(clamp_likert(3.3 + 0.60 * support_latent))
            stress_load = float(clamp_likert(3.0 + 0.65 * stress_latent))

            wisdom_c = reflective_judgment - 3.4
            virtue_c = virtue_index - 3.5
            support_c = institutional_support - 3.3
            stress_c = stress_load - 3.0

            flourishing_latent = (
                3.15
                + 0.35 * virtue_c
                + 0.28 * wisdom_c
                + 0.22 * support_c
                - 0.30 * stress_c
                + 0.12 * virtue_c * wisdom_c
                + 0.08 * (wave - 1)
                + RNG.normal(0, 0.28)
            )

            meaning = float(clamp_likert(flourishing_latent + 0.25 * wisdom_c + RNG.normal(0, 0.25)))
            relationships = float(clamp_likert(flourishing_latent + 0.20 * support_c + RNG.normal(0, 0.25)))
            accomplishment = float(clamp_likert(flourishing_latent + 0.15 * virtue_c + RNG.normal(0, 0.25)))
            positive_emotion = float(clamp_likert(flourishing_latent - 0.18 * stress_c + RNG.normal(0, 0.30)))
            flourishing = float(np.mean([meaning, relationships, accomplishment, positive_emotion]))

            rows.append(
                {
                    "id": pid,
                    "wave": wave,
                    "meaning": round(meaning, 3),
                    "relationships": round(relationships, 3),
                    "accomplishment": round(accomplishment, 3),
                    "positive_emotion": round(positive_emotion, 3),
                    **{k: round(v, 3) for k, v in scaled_domains.items()},
                    "reflective_judgment": round(reflective_judgment, 3),
                    "institutional_support": round(institutional_support, 3),
                    "stress_load": round(stress_load, 3),
                    "virtue_index": round(virtue_index, 3),
                    "flourishing": round(flourishing, 3),
                }
            )
    return pd.DataFrame(rows)


def generate_cross_sectional(n: int = 400) -> pd.DataFrame:
    latent_virtue = RNG.normal(0, 1, n)
    latent_wisdom = 0.60 * latent_virtue + RNG.normal(0, 0.75, n)
    latent_support = RNG.normal(0, 1, n)
    latent_stress = -0.30 * latent_support + RNG.normal(0, 1, n)

    df = pd.DataFrame(
        {
            "wisdom": clamp_likert(3.4 + 0.55 * latent_virtue + 0.30 * latent_wisdom + RNG.normal(0, 0.35, n)),
            "courage": clamp_likert(3.3 + 0.55 * latent_virtue + RNG.normal(0, 0.45, n)),
            "humanity": clamp_likert(3.5 + 0.50 * latent_virtue + 0.25 * latent_support + RNG.normal(0, 0.35, n)),
            "justice": clamp_likert(3.4 + 0.60 * latent_virtue + 0.25 * latent_wisdom + RNG.normal(0, 0.35, n)),
            "temperance": clamp_likert(3.2 + 0.50 * latent_virtue - 0.22 * latent_stress + RNG.normal(0, 0.40, n)),
            "transcendence": clamp_likert(3.3 + 0.45 * latent_virtue + 0.25 * latent_wisdom + RNG.normal(0, 0.45, n)),
            "meaning": clamp_likert(3.2 + 0.35 * latent_virtue + 0.35 * latent_wisdom + RNG.normal(0, 0.40, n)),
            "relationships": clamp_likert(3.3 + 0.30 * latent_virtue + 0.35 * latent_support + RNG.normal(0, 0.40, n)),
            "accomplishment": clamp_likert(3.1 + 0.35 * latent_virtue + 0.20 * latent_wisdom + RNG.normal(0, 0.45, n)),
            "positive_emotion": clamp_likert(3.2 + 0.25 * latent_virtue - 0.25 * latent_stress + RNG.normal(0, 0.45, n)),
            "institutional_support": clamp_likert(3.2 + 0.60 * latent_support + RNG.normal(0, 0.35, n)),
            "stress_load": clamp_likert(3.0 + 0.65 * latent_stress + RNG.normal(0, 0.35, n)),
        }
    )
    return df.round(3)


def main() -> None:
    panel = generate_panel()
    cross = generate_cross_sectional()
    panel.to_csv(DATA_DIR / "virtue_flourishing_panel.csv", index=False)
    cross.to_csv(DATA_DIR / "virtue_strengths_crosssectional.csv", index=False)
    print(f"Wrote {len(panel):,} panel rows.")
    print(f"Wrote {len(cross):,} cross-sectional rows.")


if __name__ == "__main__":
    main()
