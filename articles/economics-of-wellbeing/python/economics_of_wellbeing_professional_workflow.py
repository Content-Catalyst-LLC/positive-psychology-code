"""Professional research scaffold for the economics of well-being.

This workflow is designed for psychologists, well-being economists, and
interdisciplinary research teams who need a transparent, reproducible example of:

- synthetic data ingestion;
- missingness diagnostics;
- indicator-family reliability;
- transparent composite scoring with inequality and time-pressure penalties;
- PCA dimensional inspection;
- sparse partial-correlation networks;
- bootstrap centrality stability;
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
    "income_security",
    "life_satisfaction",
    "health_index",
    "social_trust",
    "institutional_quality",
    "environmental_quality",
    "inequality_index",
    "work_quality",
    "care_security",
    "time_pressure",
    "public_services",
]

COMPOSITE_WEIGHTS = {
    "income_security": 0.12,
    "life_satisfaction": 0.12,
    "health_index": 0.12,
    "social_trust": 0.11,
    "institutional_quality": 0.11,
    "environmental_quality": 0.10,
    "work_quality": 0.10,
    "care_security": 0.10,
    "public_services": 0.10,
    "inequality_index": -0.06,
    "time_pressure": -0.06,
}

INDICATOR_FAMILIES = {
    "material_security": ["mat1", "mat2", "mat3"],
    "subjective_wellbeing": ["swb1", "swb2", "swb3"],
    "institutions": ["inst1", "inst2", "inst3"],
    "work_quality": ["work1", "work2", "work3"],
    "care_security": ["care1", "care2", "care3"],
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
    """Compute Cronbach's alpha for a dataframe of item/indicator responses."""
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


def reliability_report(indicator_df: pd.DataFrame) -> pd.DataFrame:
    """Compute simple reliability diagnostics for synthetic indicator families."""
    rows = []

    for family_name, columns in INDICATOR_FAMILIES.items():
        require_columns(indicator_df, columns, f"{family_name} indicator family")
        items = indicator_df[columns].apply(pd.to_numeric, errors="coerce")

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
    """Median-impute and standardize selected columns."""
    require_columns(df, columns, "analysis dataframe")

    imputer = SimpleImputer(strategy="median")
    imputed = pd.DataFrame(imputer.fit_transform(df[columns]), columns=columns)

    scaler = StandardScaler()
    scaled = pd.DataFrame(scaler.fit_transform(imputed), columns=columns)

    return scaled


def build_composite_index(x_scaled: pd.DataFrame) -> pd.DataFrame:
    """Construct a transparent weighted well-being economy index."""
    result = x_scaled.copy()
    result["wellbeing_economy_index"] = 0.0

    for variable, weight in COMPOSITE_WEIGHTS.items():
        if variable not in result.columns:
            raise ValueError(f"Composite variable missing: {variable}")
        result["wellbeing_economy_index"] += weight * result[variable]

    return result


def run_pca(x_scaled: pd.DataFrame) -> pd.DataFrame:
    """Run PCA for dimensional inspection."""
    n_components = min(4, len(NETWORK_COLUMNS), len(x_scaled) - 1)
    n_components = max(1, n_components)

    pca = PCA(n_components=n_components)
    pca.fit_transform(x_scaled[NETWORK_COLUMNS])

    return pd.DataFrame(
        {
            "component": np.arange(1, len(pca.explained_variance_ratio_) + 1),
            "variance_explained": pca.explained_variance_ratio_,
            "cumulative_variance_explained": np.cumsum(pca.explained_variance_ratio_),
        }
    )


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
    x_scaled: pd.DataFrame,
    n_boot: int = 100,
    threshold: float = 0.08,
    seed: int = 42,
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

    plt.title("Exploratory Network of the Economics of Well-Being")
    plt.axis("off")
    plt.tight_layout()
    plt.savefig(path, dpi=300, bbox_inches="tight")
    plt.close()


def main() -> None:
    panel_df = pd.read_csv(RAW_DIR / "economics_of_wellbeing_panel.csv")
    network_df = pd.read_csv(RAW_DIR / "economics_of_wellbeing_network.csv")
    indicator_df = pd.read_csv(RAW_DIR / "economics_of_wellbeing_indicator_bank.csv")

    missingness_table(panel_df).to_csv(TABLE_DIR / "panel_missingness.csv", index=False)
    missingness_table(network_df).to_csv(TABLE_DIR / "network_missingness.csv", index=False)
    missingness_table(indicator_df).to_csv(TABLE_DIR / "indicator_bank_missingness.csv", index=False)

    reliability = reliability_report(indicator_df)
    reliability.to_csv(TABLE_DIR / "indicator_family_reliability_report.csv", index=False)

    x_scaled = scale_and_impute(network_df, NETWORK_COLUMNS)
    indexed = build_composite_index(x_scaled)
    pca_table = run_pca(x_scaled)
    network = estimate_network(x_scaled)
    bootstrap_summary = bootstrap_network_centrality(x_scaled, n_boot=100)

    indexed.to_csv(TABLE_DIR / "wellbeing_economy_scaled_index.csv", index=False)
    pca_table.to_csv(TABLE_DIR / "economics_of_wellbeing_pca_variance.csv", index=False)
    network.partial_correlations.to_csv(TABLE_DIR / "economics_of_wellbeing_partial_correlations.csv")
    network.centrality.to_csv(TABLE_DIR / "economics_of_wellbeing_network_centrality.csv", index=False)
    bootstrap_summary.to_csv(TABLE_DIR / "economics_of_wellbeing_bootstrap_centrality.csv", index=False)

    draw_network(network.graph, FIGURE_DIR / "economics_of_wellbeing_network.png")

    print("Professional economics of well-being workflow complete.")
    print(f"Tables written to: {TABLE_DIR}")
    print(f"Figures written to: {FIGURE_DIR}")


if __name__ == "__main__":
    main()
