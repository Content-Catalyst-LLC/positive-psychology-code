"""Professional research scaffold for future well-being science.

This workflow is designed for psychologists and interdisciplinary well-being
researchers who need a transparent, reproducible example of:

- synthetic data ingestion;
- missingness diagnostics;
- scale reliability;
- transparent composite scoring;
- PCA / factor-style dimensional inspection;
- sparse partial-correlation networks;
- bootstrap stability for centrality estimates;
- reproducible export of figures and tables.

The included data are synthetic. This code is not a clinical, diagnostic,
therapeutic, workplace-screening, employment-selection, or individual
well-being assessment tool.
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
from sklearn.decomposition import FactorAnalysis, PCA
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
    "life_satisfaction",
    "meaning",
    "social_trust",
    "institutional_quality",
    "environmental_quality",
    "health_index",
    "resilience_score",
    "stress_load",
    "material_security",
    "civic_voice",
]

COMPOSITE_WEIGHTS = {
    "life_satisfaction": 0.13,
    "meaning": 0.13,
    "social_trust": 0.12,
    "institutional_quality": 0.12,
    "environmental_quality": 0.12,
    "health_index": 0.13,
    "resilience_score": 0.10,
    "material_security": 0.10,
    "civic_voice": 0.10,
    "stress_load": -0.05,
}

SCALE_GROUPS = {
    "life_satisfaction": ["ls1", "ls2", "ls3"],
    "meaning": ["meaning1", "meaning2", "meaning3"],
    "social_trust": ["trust1", "trust2", "trust3"],
    "health": ["health1", "health2", "health3"],
    "stress_load": ["stress1", "stress2", "stress3"],
}


@dataclass
class NetworkResults:
    partial_correlations: pd.DataFrame
    centrality: pd.DataFrame
    graph: nx.Graph


def require_columns(df: pd.DataFrame, columns: Iterable[str], context: str) -> None:
    """Raise a clear error if required columns are missing."""
    missing = [column for column in columns if column not in df.columns]
    if missing:
        raise ValueError(f"{context} is missing required columns: {missing}")


def cronbach_alpha(items: pd.DataFrame) -> float:
    """Compute Cronbach's alpha for a dataframe of item responses."""
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
    """Summarize missingness by variable."""
    return (
        df.isna()
        .mean()
        .rename("missing_rate")
        .reset_index()
        .rename(columns={"index": "variable"})
        .sort_values("missing_rate", ascending=False)
    )


def reliability_report(item_df: pd.DataFrame) -> pd.DataFrame:
    """Compute simple reliability diagnostics for each synthetic item family."""
    rows = []

    for scale_name, columns in SCALE_GROUPS.items():
        require_columns(item_df, columns, f"{scale_name} item set")
        items = item_df[columns].apply(pd.to_numeric, errors="coerce")

        alpha = cronbach_alpha(items)
        item_total = {}

        for column in columns:
            remaining = [c for c in columns if c != column]
            if remaining:
                item_total[column] = items[column].corr(items[remaining].mean(axis=1))
            else:
                item_total[column] = np.nan

        rows.append(
            {
                "scale": scale_name,
                "n_items": len(columns),
                "cronbach_alpha": alpha,
                "mean_item_total_correlation": float(np.nanmean(list(item_total.values()))),
                "min_item_total_correlation": float(np.nanmin(list(item_total.values()))),
            }
        )

    return pd.DataFrame(rows)


def scale_and_impute(df: pd.DataFrame, columns: list[str]) -> pd.DataFrame:
    """Median-impute and standardize selected columns."""
    require_columns(df, columns, "analysis dataframe")

    imputer = SimpleImputer(strategy="median")
    imputed = pd.DataFrame(imputer.fit_transform(df[columns]), columns=columns)

    scaler = StandardScaler()
    scaled = pd.DataFrame(scaler.fit_transform(imputed), columns=columns)

    return scaled


def build_composite_index(x_scaled: pd.DataFrame) -> pd.DataFrame:
    """Construct a transparent weighted multidimensional flourishing index."""
    result = x_scaled.copy()
    result["future_wellbeing_index"] = 0.0

    for variable, weight in COMPOSITE_WEIGHTS.items():
        if variable not in result.columns:
            raise ValueError(f"Composite variable missing: {variable}")
        result["future_wellbeing_index"] += weight * result[variable]

    return result


def run_dimensional_checks(x_scaled: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Run PCA and factor-analysis style dimensional inspection."""
    pca = PCA(n_components=min(4, len(NETWORK_COLUMNS)))
    pca.fit_transform(x_scaled[NETWORK_COLUMNS])

    pca_table = pd.DataFrame(
        {
            "component": np.arange(1, len(pca.explained_variance_ratio_) + 1),
            "variance_explained": pca.explained_variance_ratio_,
            "cumulative_variance_explained": np.cumsum(pca.explained_variance_ratio_),
        }
    )

    fa = FactorAnalysis(n_components=3, random_state=42)
    fa.fit(x_scaled[NETWORK_COLUMNS])

    loading_table = pd.DataFrame(
        fa.components_.T,
        index=NETWORK_COLUMNS,
        columns=["factor_1", "factor_2", "factor_3"],
    ).reset_index(names="variable")

    return pca_table, loading_table


def estimate_network(x_scaled: pd.DataFrame, threshold: float = 0.08) -> NetworkResults:
    """Estimate sparse partial-correlation network using Graphical Lasso."""
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

    centrality = centrality_table(graph)

    return NetworkResults(partial_df, centrality, graph)


def centrality_table(graph: nx.Graph) -> pd.DataFrame:
    """Compute centrality diagnostics for a network graph."""
    degree = nx.degree_centrality(graph)
    betweenness = nx.betweenness_centrality(graph, weight="weight")

    if graph.number_of_edges() > 0 and graph.number_of_nodes() > 1:
        try:
            eigenvector = nx.eigenvector_centrality_numpy(graph, weight="weight")
        except Exception:
            eigenvector = {node: np.nan for node in graph.nodes}
    else:
        eigenvector = {node: 0.0 for node in graph.nodes}

    return (
        pd.DataFrame(
            {
                "node": list(graph.nodes()),
                "degree_centrality": [degree[node] for node in graph.nodes()],
                "betweenness_centrality": [betweenness[node] for node in graph.nodes()],
                "eigenvector_centrality": [eigenvector[node] for node in graph.nodes()],
            }
        )
        .sort_values(["eigenvector_centrality", "degree_centrality"], ascending=False)
        .reset_index(drop=True)
    )


def bootstrap_network_centrality(
    x_scaled: pd.DataFrame, n_boot: int = 100, threshold: float = 0.08, seed: int = 42
) -> pd.DataFrame:
    """Bootstrap centrality estimates for exploratory network stability checks."""
    rng = np.random.default_rng(seed)
    rows = []

    for boot_id in range(n_boot):
        sample_idx = rng.choice(x_scaled.index.to_numpy(), size=len(x_scaled), replace=True)
        boot_sample = x_scaled.loc[sample_idx, NETWORK_COLUMNS].reset_index(drop=True)

        try:
            results = estimate_network(boot_sample, threshold=threshold)
            centrality = results.centrality.assign(bootstrap=boot_id)
            rows.append(centrality)
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

    summary = (
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

    return summary


def draw_network(graph: nx.Graph, path: Path) -> None:
    """Save a network figure."""
    plt.figure(figsize=(11, 8))

    if graph.number_of_edges() > 0:
        pos = nx.spring_layout(graph, seed=42, k=0.8)
        edge_widths = [max(0.5, abs(graph[u][v]["weight"]) * 4) for u, v in graph.edges()]
        nx.draw_networkx_edges(graph, pos, width=edge_widths, alpha=0.65)
    else:
        pos = nx.circular_layout(graph)

    nx.draw_networkx_nodes(graph, pos, node_size=1900)
    nx.draw_networkx_labels(graph, pos, font_size=9)

    plt.title("Exploratory Partial-Correlation Network of Future Well-Being Science")
    plt.axis("off")
    plt.tight_layout()
    plt.savefig(path, dpi=300, bbox_inches="tight")
    plt.close()


def main() -> None:
    network_df = pd.read_csv(RAW_DIR / "future_wellbeing_network.csv")
    panel_df = pd.read_csv(RAW_DIR / "future_wellbeing_panel.csv")
    item_df = pd.read_csv(RAW_DIR / "future_wellbeing_item_bank.csv")

    missingness_table(network_df).to_csv(TABLE_DIR / "network_missingness.csv", index=False)
    missingness_table(panel_df).to_csv(TABLE_DIR / "panel_missingness.csv", index=False)
    missingness_table(item_df).to_csv(TABLE_DIR / "item_bank_missingness.csv", index=False)

    reliability = reliability_report(item_df)
    reliability.to_csv(TABLE_DIR / "item_reliability_report.csv", index=False)

    x_scaled = scale_and_impute(network_df, NETWORK_COLUMNS)
    indexed = build_composite_index(x_scaled)
    pca_table, factor_loadings = run_dimensional_checks(x_scaled)
    network = estimate_network(x_scaled)
    bootstrap_summary = bootstrap_network_centrality(x_scaled, n_boot=100)

    indexed.to_csv(TABLE_DIR / "future_wellbeing_scaled_index.csv", index=False)
    pca_table.to_csv(TABLE_DIR / "future_wellbeing_pca_variance.csv", index=False)
    factor_loadings.to_csv(TABLE_DIR / "future_wellbeing_factor_loadings.csv", index=False)
    network.partial_correlations.to_csv(TABLE_DIR / "future_wellbeing_partial_correlations.csv")
    network.centrality.to_csv(TABLE_DIR / "future_wellbeing_network_centrality.csv", index=False)
    bootstrap_summary.to_csv(TABLE_DIR / "future_wellbeing_bootstrap_centrality.csv", index=False)

    draw_network(network.graph, FIGURE_DIR / "future_wellbeing_network.png")

    print("Professional future well-being workflow complete.")
    print(f"Tables written to: {TABLE_DIR}")
    print(f"Figures written to: {FIGURE_DIR}")


if __name__ == "__main__":
    main()
