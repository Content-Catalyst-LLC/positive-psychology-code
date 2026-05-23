"""Sensitivity analysis for alternative virtue/flourishing weighting schemes."""

from pathlib import Path
import numpy as np
import pandas as pd
from scipy.stats import spearmanr

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data" / "virtue_flourishing_panel.csv"
OUT = ROOT / "outputs"
OUT.mkdir(parents=True, exist_ok=True)

VIRTUE_COLS = [
    "strengths_wisdom", "strengths_courage", "strengths_humanity",
    "strengths_justice", "strengths_temperance", "strengths_transcendence",
]
FLOURISHING_COLS = ["meaning", "relationships", "accomplishment", "positive_emotion"]


def weighted_index(df: pd.DataFrame, cols: list[str], weights: np.ndarray) -> np.ndarray:
    weights = weights / weights.sum()
    return df[cols].to_numpy() @ weights


def main() -> None:
    df = pd.read_csv(DATA)
    scenarios = []

    virtue_weight_sets = {
        "equal": np.ones(len(VIRTUE_COLS)),
        "wisdom_justice_emphasis": np.array([1.5, 1.0, 1.0, 1.5, 1.0, 1.0]),
        "temperance_courage_emphasis": np.array([1.0, 1.4, 1.0, 1.0, 1.4, 1.0]),
        "humanity_transcendence_emphasis": np.array([1.0, 1.0, 1.4, 1.0, 1.0, 1.4]),
    }
    flourishing_weight_sets = {
        "equal": np.ones(len(FLOURISHING_COLS)),
        "meaning_relationships_emphasis": np.array([1.5, 1.5, 1.0, 1.0]),
        "accomplishment_emotion_emphasis": np.array([1.0, 1.0, 1.4, 1.4]),
    }

    for virtue_name, virtue_weights in virtue_weight_sets.items():
        for flourishing_name, flourishing_weights in flourishing_weight_sets.items():
            virtue_score = weighted_index(df, VIRTUE_COLS, virtue_weights)
            flourishing_score = weighted_index(df, FLOURISHING_COLS, flourishing_weights)
            rho, p_value = spearmanr(virtue_score, flourishing_score)
            scenarios.append({
                "virtue_weighting": virtue_name,
                "flourishing_weighting": flourishing_name,
                "spearman_rho": round(float(rho), 4),
                "p_value": round(float(p_value), 6),
            })

    result = pd.DataFrame(scenarios).sort_values("spearman_rho", ascending=False)
    result.to_csv(OUT / "virtue_weighting_sensitivity.csv", index=False)
    print(result)


if __name__ == "__main__":
    main()
