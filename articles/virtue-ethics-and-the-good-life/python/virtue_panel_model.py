"""Panel modeling for virtue, practical wisdom, institutional support, and flourishing."""

from pathlib import Path
import pandas as pd
import statsmodels.formula.api as smf

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data" / "virtue_flourishing_panel.csv"
OUT = ROOT / "outputs"
OUT.mkdir(parents=True, exist_ok=True)


def main() -> None:
    df = pd.read_csv(DATA)
    for col in ["virtue_index", "reflective_judgment", "institutional_support", "stress_load"]:
        df[f"{col}_c"] = df[col] - df[col].mean()

    model = smf.mixedlm(
        "flourishing ~ wave + virtue_index_c * reflective_judgment_c + institutional_support_c - stress_load_c",
        data=df,
        groups=df["id"],
        re_formula="~wave",
    )
    result = model.fit(method="lbfgs", maxiter=500, disp=False)

    (OUT / "python_panel_model_summary.txt").write_text(result.summary().as_text(), encoding="utf-8")
    pd.DataFrame(
        {
            "term": result.params.index,
            "estimate": result.params.values,
            "standard_error": result.bse.values,
            "p_value": result.pvalues.values,
        }
    ).to_csv(OUT / "python_panel_model_coefficients.csv", index=False)

    print(result.summary())


if __name__ == "__main__":
    main()
