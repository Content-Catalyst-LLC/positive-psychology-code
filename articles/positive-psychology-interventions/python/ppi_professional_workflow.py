"""Professional research scaffold for positive psychology interventions.

Synthetic-data workflow for psychologists and intervention researchers.

Not for clinical diagnosis, treatment planning, workplace screening,
employment selection, public-benefits decisions, or individual assessment.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

import matplotlib.pyplot as plt
import networkx as nx
import numpy as np
import pandas as pd
from sklearn.covariance import GraphicalLassoCV
from sklearn.decomposition import PCA
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler

BASE_DIR = Path(__file__).resolve().parents[1]
RAW_DIR = BASE_DIR / "data" / "raw"
OUTPUT_DIR = BASE_DIR / "outputs"
FIGURE_DIR = OUTPUT_DIR / "figures"
TABLE_DIR = OUTPUT_DIR / "tables"
FIGURE_DIR.mkdir(parents=True, exist_ok=True)
TABLE_DIR.mkdir(parents=True, exist_ok=True)

NETWORK_COLUMNS = [
    "gratitude_score",
    "strengths_use",
    "hope_score",
    "meaning_score",
    "social_support",
    "adherence_rate",
    "intervention_fit",
    "stress_load",
    "depressive_symptoms",
    "wellbeing_score",
    "acceptability",
    "context_fit",
]

MECHANISM_COLUMNS = [
    "gratitude_score",
    "strengths_use",
    "hope_score",
    "meaning_score",
    "social_support",
]

INDICATOR_FAMILIES = {
    "gratitude": ["gratitude1", "gratitude2"],
    "strengths_use": ["strengths1", "strengths2"],
    "hope": ["hope1", "hope2"],
    "meaning": ["meaning1", "meaning2"],
    "social_support": ["support1", "support2"],
    "adherence": ["adherence1", "adherence2"],
    "fit": ["fit1", "fit2"],
    "wellbeing": ["wellbeing1", "wellbeing2"],
    "distress": ["distress1", "distress2"],
}


def require_columns(df: pd.DataFrame, columns: Iterable[str], context: str) -> None:
    missing = [column for column in columns if column not in df.columns]
    if missing:
        raise ValueError(f"{context} is missing required columns: {missing}")


def cronbach_alpha(items: pd.DataFrame) -> float:
    if items.shape[1] < 2:
        return float("nan")
    item_scores = items.dropna()
    if item_scores.empty:
        return float("nan")
    item_variances = item_scores.var(axis=0, ddof=1)
    total_variance = item_scores.sum(axis=1).var(ddof=1)
    n_items = item_scores.shape[1]
    if total_variance == 0:
        return float("nan")
    return float((n_items / (n_items - 1)) * (1 - item_variances.sum() / total_variance))


def missingness_table(df: pd.DataFrame) -> pd.DataFrame:
    return (
        df.isna()
        .mean()
        .rename("missing_rate")
        .reset_index()
        .rename(columns={"index": "variable"})
        .sort_values("missing_rate", ascending=False)
    )


def reliability_report(indicator_df: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for family_name, columns in INDICATOR_FAMILIES.items():
        require_columns(indicator_df, columns, f"{family_name} indicator family")
        items = indicator_df[columns].apply(pd.to_numeric, errors="coerce")
        if family_name == "distress":
            items = -items
        rows.append(
            {
                "indicator_family": family_name,
                "n_indicators": len(columns),
                "cronbach_alpha": cronbach_alpha(items),
                "mean_family_score": float(items.mean(axis=1).mean()),
                "sd_family_score": float(items.mean(axis=1).std(ddof=1)),
            }
        )
    return pd.DataFrame(rows)


def scale_and_impute(df: pd.DataFrame, columns: list[str]) -> pd.DataFrame:
    require_columns(df, columns, "analysis dataframe")
    imputer = SimpleImputer(strategy="median")
    imputed = pd.DataFrame(imputer.fit_transform(df[columns]), columns=columns)
    scaler = StandardScaler()
    return pd.DataFrame(scaler.fit_transform(imputed), columns=columns)


def build_intervention_indices(x_scaled: pd.DataFrame) -> pd.DataFrame:
    result = x_scaled.copy()
    result["mechanism_index"] = result[MECHANISM_COLUMNS].mean(axis=1)
    result["practice_quality_proxy"] = (
        result["adherence_rate"]
        + result["intervention_fit"]
        + result["acceptability"]
        + result["context_fit"]
    ) / 4
    result["net_wellbeing_index"] = (
        result["wellbeing_score"]
        + result["gratitude_score"]
        + result["strengths_use"]
        + result["hope_score"]
        + result["meaning_score"]
        + result["social_support"]
        + result["intervention_fit"]
        - result["stress_load"]
        - result["depressive_symptoms"]
    )
    return result


def audit_practice_quality(practice_df: pd.DataFrame) -> pd.DataFrame:
    quality_columns = [
        "adherence_design",
        "mechanism_clarity",
        "acceptability",
        "context_fit",
        "privacy_safeguards",
        "trauma_sensitive_language",
        "implementation_support",
        "measurement_quality",
    ]
    require_columns(practice_df, quality_columns, "practice quality dataframe")
    result = practice_df.copy()
    result["computed_quality_mean"] = result[quality_columns].mean(axis=1)
    result["lowest_quality_dimension"] = result[quality_columns].idxmin(axis=1)
    result["practice_quality_gap"] = result["overall_practice_quality"] - result["computed_quality_mean"]
    return result.sort_values("computed_quality_mean", ascending=False)


def pca_summary(x_scaled: pd.DataFrame) -> pd.DataFrame:
    pca_columns = MECHANISM_COLUMNS + ["adherence_rate", "intervention_fit", "stress_load"]
    n_components = min(4, len(pca_columns), len(x_scaled) - 1)
    pca = PCA(n_components=n_components)
    pca.fit_transform(x_scaled[pca_columns])
    return pd.DataFrame(
        {
            "component": np.arange(1, len(pca.explained_variance_ratio_) + 1),
            "variance_explained": pca.explained_variance_ratio_,
            "cumulative_variance_explained": np.cumsum(pca.explained_variance_ratio_),
        }
    )


def estimate_network(x_scaled: pd.DataFrame, threshold: float = 0.08):
    glasso = GraphicalLassoCV()
    glasso.fit(x_scaled[NETWORK_COLUMNS])
    precision = glasso.precision_
    partial_corr = -precision / np.sqrt(np.outer(np.diag(precision), np.diag(precision)))
    np.fill_diagonal(partial_corr, 0)
    partial_df = pd.DataFrame(partial_corr, index=NETWORK_COLUMNS, columns=NETWORK_COLUMNS)

    graph = nx.Graph()
    graph.add_nodes_from(NETWORK_COLUMNS)
    for i, source in enumerate(NETWORK_COLUMNS):
        for j, target in enumerate(NETWORK_COLUMNS):
            if j > i and abs(partial_df.iloc[i, j]) >= threshold:
                graph.add_edge(source, target, weight=float(partial_df.iloc[i, j]))

    degree = nx.degree_centrality(graph)
    betweenness = nx.betweenness_centrality(graph, weight="weight")
    try:
        eigenvector = nx.eigenvector_centrality_numpy(graph, weight="weight")
    except Exception:
        eigenvector = {node: np.nan for node in graph.nodes}

    centrality = pd.DataFrame(
        {
            "node": list(graph.nodes()),
            "degree_centrality": [degree[node] for node in graph.nodes()],
            "betweenness_centrality": [betweenness[node] for node in graph.nodes()],
            "eigenvector_centrality": [eigenvector[node] for node in graph.nodes()],
        }
    ).sort_values(["eigenvector_centrality", "degree_centrality"], ascending=False)

    edges = pd.DataFrame(
        [
            {
                "source": source,
                "target": target,
                "partial_correlation": data["weight"],
                "absolute_weight": abs(data["weight"]),
                "sign": "positive" if data["weight"] > 0 else "negative",
            }
            for source, target, data in graph.edges(data=True)
        ]
    )

    if not edges.empty:
        edges = edges.sort_values("absolute_weight", ascending=False)

    return partial_df, centrality, edges, graph


def bootstrap_network_centrality(x_scaled: pd.DataFrame, n_boot: int = 100, seed: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    rows = []
    for boot_id in range(n_boot):
        sample_idx = rng.choice(x_scaled.index.to_numpy(), size=len(x_scaled), replace=True)
        boot_sample = x_scaled.loc[sample_idx, NETWORK_COLUMNS].reset_index(drop=True)
        try:
            _, centrality, _, _ = estimate_network(boot_sample)
            rows.append(centrality.assign(bootstrap=boot_id))
        except Exception as exc:
            rows.append(
                pd.DataFrame(
                    {
                        "node": NETWORK_COLUMNS,
                        "degree_centrality": np.nan,
                        "betweenness_centrality": np.nan,
                        "eigenvector_centrality": np.nan,
                        "bootstrap": boot_id,
                        "error": str(exc),
                    }
                )
            )
    boot = pd.concat(rows, ignore_index=True)
    return (
        boot.groupby("node", as_index=False)
        .agg(
            degree_mean=("degree_centrality", "mean"),
            degree_sd=("degree_centrality", "std"),
            betweenness_mean=("betweenness_centrality", "mean"),
            betweenness_sd=("betweenness_centrality", "std"),
            eigenvector_mean=("eigenvector_centrality", "mean"),
            eigenvector_sd=("eigenvector_centrality", "std"),
        )
        .sort_values("eigenvector_mean", ascending=False)
    )


def draw_network(graph: nx.Graph, path: Path) -> None:
    plt.figure(figsize=(12, 9))
    if graph.number_of_edges() > 0:
        pos = nx.spring_layout(graph, seed=42, k=0.85)
        positive_edges = [(u, v) for u, v in graph.edges() if graph[u][v]["weight"] > 0]
        negative_edges = [(u, v) for u, v in graph.edges() if graph[u][v]["weight"] < 0]
        nx.draw_networkx_edges(graph, pos, edgelist=positive_edges, alpha=0.75)
        nx.draw_networkx_edges(graph, pos, edgelist=negative_edges, style="dashed", alpha=0.75)
    else:
        pos = nx.circular_layout(graph)
    nx.draw_networkx_nodes(graph, pos, node_size=1800)
    nx.draw_networkx_labels(graph, pos, font_size=9)
    plt.title("Partial Correlation Network of Positive Psychology Intervention Mechanisms")
    plt.axis("off")
    plt.tight_layout()
    plt.savefig(path, dpi=300, bbox_inches="tight")
    plt.close()


def main() -> None:
    panel_df = pd.read_csv(RAW_DIR / "positive_psychology_interventions_panel.csv")
    network_df = pd.read_csv(RAW_DIR / "ppi_mechanisms_network.csv")
    indicator_df = pd.read_csv(RAW_DIR / "ppi_indicator_bank.csv")
    practice_quality_df = pd.read_csv(RAW_DIR / "ppi_practice_quality_audit.csv")

    missingness_table(panel_df).to_csv(TABLE_DIR / "panel_missingness.csv", index=False)
    missingness_table(network_df).to_csv(TABLE_DIR / "network_missingness.csv", index=False)
    missingness_table(indicator_df).to_csv(TABLE_DIR / "indicator_bank_missingness.csv", index=False)
    missingness_table(practice_quality_df).to_csv(TABLE_DIR / "practice_quality_missingness.csv", index=False)

    reliability_report(indicator_df).to_csv(TABLE_DIR / "indicator_family_reliability_report.csv", index=False)
    audit_practice_quality(practice_quality_df).to_csv(TABLE_DIR / "practice_quality_audit_summary.csv", index=False)

    x_scaled = scale_and_impute(network_df, NETWORK_COLUMNS)
    indexed = build_intervention_indices(x_scaled)
    pca = pca_summary(x_scaled)
    partial, centrality, edges, graph = estimate_network(x_scaled)
    bootstrap = bootstrap_network_centrality(x_scaled)

    indexed.to_csv(TABLE_DIR / "ppi_mechanisms_scaled_indices.csv", index=False)
    pca.to_csv(TABLE_DIR / "ppi_mechanisms_pca_summary.csv", index=False)
    partial.to_csv(TABLE_DIR / "ppi_mechanisms_partial_correlations.csv")
    centrality.to_csv(TABLE_DIR / "ppi_mechanisms_network_centrality.csv", index=False)
    edges.to_csv(TABLE_DIR / "ppi_mechanisms_network_edges.csv", index=False)
    bootstrap.to_csv(TABLE_DIR / "ppi_mechanisms_bootstrap_centrality.csv", index=False)
    draw_network(graph, FIGURE_DIR / "ppi_mechanisms_network.png")

    print("Professional positive psychology intervention workflow complete.")
    print(f"Tables written to: {TABLE_DIR}")
    print(f"Figures written to: {FIGURE_DIR}")


if __name__ == "__main__":
    main()
