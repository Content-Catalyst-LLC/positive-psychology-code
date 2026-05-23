"""Professional research scaffold for cultural perspectives on well-being.

This workflow is designed for psychologists and cross-cultural well-being
researchers who need a transparent, reproducible example of:

- synthetic data ingestion;
- missingness diagnostics;
- scale reliability;
- composite scoring with culturally relevant domains;
- exploratory factor-style dimensional inspection;
- pooled and group-specific sparse partial-correlation networks;
- bootstrap centrality stability;
- reproducible export of figures and tables.

The included data are synthetic. This code is not a clinical, diagnostic,
therapeutic, workplace-screening, employment-selection, cultural ranking, or
individual well-being assessment tool.
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
    "social_support",
    "relational_harmony",
    "institutional_trust",
    "income_security",
    "cultural_orientation",
    "autonomy_value",
    "harmony_value",
    "civic_voice",
    "cultural_continuity",
    "place_attachment",
]

COMPOSITE_WEIGHTS = {
    "life_satisfaction": 0.12,
    "social_support": 0.11,
    "relational_harmony": 0.12,
    "institutional_trust": 0.10,
    "income_security": 0.10,
    "civic_voice": 0.09,
    "cultural_continuity": 0.12,
    "place_attachment": 0.12,
    "autonomy_value": 0.06,
    "harmony_value": 0.06,
}

SCALE_GROUPS = {
    "general_wellbeing": ["wb1", "wb2", "wb3"],
    "relational_harmony": ["rel1", "rel2", "rel3"],
    "institutional_trust": ["inst1", "inst2", "inst3"],
    "cultural_continuity": ["cult1", "cult2", "cult3"],
    "place_attachment": ["place1", "place2", "place3"],
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
    """Compute reliability diagnostics for synthetic cultural item families."""
    rows = []

    for scale_name, columns in SCALE_GROUPS.items():
        require_columns(item_df, columns, f"{scale_name} item set")
        items = item_df[columns].apply(pd.to_numeric, errors="coerce")

        rows.append(
            {
                "scale": scale_name,
                "n_items": len(columns),
                "cronbach_alpha": cronbach_alpha(items),
                "mean": float(items.mean(axis=1).mean()),
                "sd": float(items.mean(axis=1).std(ddof=1)),
            }
        )

        if "country_group" in item_df.columns:
            for group_name, group_df in item_df.groupby("country_group"):
                group_items = group_df[columns].apply(pd.to_numeric, errors="coerce")
                rows.append(
                    {
                        "scale": f"{scale_name}__{group_name}",
                        "n_items": len(columns),
                        "cronbach_alpha": cronbach_alpha(group_items),
                        "mean": float(group_items.mean(axis=1).mean()),
                        "sd": float(group_items.mean(axis=1).std(ddof=1)),
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
    """Construct a transparent weighted cultural well-being index."""
    result = x_scaled.copy()
    result["cultural_wellbeing_index"] = 0.0

    for variable, weight in COMPOSITE_WEIGHTS.items():
        if variable not in result.columns:
            raise ValueError(f"Composite variable missing: {variable}")
        result["cultural_wellbeing_index"] += weight * result[variable]

    return result


def run_dimensional_checks(x_scaled: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Run PCA and factor-analysis style dimensional inspection."""
    n_components = min(4, len(NETWORK_COLUMNS), len(x_scaled) - 1)
    n_components = max(1, n_components)

    pca = PCA(n_components=n_components)
    pca.fit_transform(x_scaled[NETWORK_COLUMNS])

    pca_table = pd.DataFrame(
        {
            "component": np.arange(1, len(pca.explained_variance_ratio_) + 1),
            "variance_explained": pca.explained_variance_ratio_,
            "cumulative_variance_explained": np.cumsum(pca.explained_variance_ratio_),
        }
    )

    fa_components = min(3, len(NETWORK_COLUMNS), max(1, len(x_scaled) - 1))
    fa = FactorAnalysis(n_components=fa_components, random_state=42)
    fa.fit(x_scaled[NETWORK_COLUMNS])

    loading_table = pd.DataFrame(
        fa.components_.T,
        index=NETWORK_COLUMNS,
        columns=[f"factor_{i + 1}" for i in range(fa_components)],
    ).reset_index(names="variable")

    return pca_table, loading_table


def estimate_network(
    x_scaled: pd.DataFrame,
    label: str,
    threshold: float = 0.08,
) -> NetworkResults:
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

    centrality = centrality_table(graph).assign(group=label)

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


def draw_network(graph: nx.Graph, path: Path, title: str) -> None:
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

    plt.title(title)
    plt.axis("off")
    plt.tight_layout()
    plt.savefig(path, dpi=300, bbox_inches="tight")
    plt.close()


def bootstrap_network_centrality(
    x_scaled: pd.DataFrame,
    label: str,
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
            results = estimate_network(boot_sample, label=label, threshold=threshold)
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
                        "group": label,
                        "bootstrap": boot_id,
                        "error": str(exc),
                    }
                )
            )

    boot = pd.concat(rows, ignore_index=True)

    return (
        boot.groupby(["group", "node"], as_index=False)
        .agg(
            degree_mean=("degree_centrality", "mean"),
            degree_sd=("degree_centrality", "std"),
            betweenness_mean=("betweenness_centrality", "mean"),
            betweenness_sd=("betweenness_centrality", "std"),
            eigenvector_mean=("eigenvector_centrality", "mean"),
            eigenvector_sd=("eigenvector_centrality", "std"),
        )
        .sort_values(["group", "eigenvector_mean"], ascending=[True, False])
    )


def safe_label(value: str) -> str:
    """Create a filesystem-safe label."""
    return str(value).replace(" ", "_").replace("/", "_").replace("&", "and")


def main() -> None:
    network_df = pd.read_csv(RAW_DIR / "cultural_wellbeing_network.csv")
    panel_df = pd.read_csv(RAW_DIR / "cultural_wellbeing_panel.csv")
    item_df = pd.read_csv(RAW_DIR / "cultural_wellbeing_item_bank.csv")

    missingness_table(network_df).to_csv(TABLE_DIR / "network_missingness.csv", index=False)
    missingness_table(panel_df).to_csv(TABLE_DIR / "panel_missingness.csv", index=False)
    missingness_table(item_df).to_csv(TABLE_DIR / "item_bank_missingness.csv", index=False)

    reliability = reliability_report(item_df)
    reliability.to_csv(TABLE_DIR / "item_reliability_report.csv", index=False)

    x_scaled = scale_and_impute(network_df, NETWORK_COLUMNS)
    indexed = build_composite_index(x_scaled)
    pca_table, factor_loadings = run_dimensional_checks(x_scaled)

    indexed.to_csv(TABLE_DIR / "cultural_wellbeing_scaled_index.csv", index=False)
    pca_table.to_csv(TABLE_DIR / "cultural_wellbeing_pca_variance.csv", index=False)
    factor_loadings.to_csv(TABLE_DIR / "cultural_wellbeing_factor_loadings.csv", index=False)

    network_results = []
    bootstrap_results = []

    pooled = estimate_network(x_scaled, label="pooled")
    pooled.partial_correlations.to_csv(TABLE_DIR / "cultural_wellbeing_partial_correlations_pooled.csv")
    pooled.centrality.to_csv(TABLE_DIR / "cultural_wellbeing_network_centrality_pooled.csv", index=False)
    draw_network(
        pooled.graph,
        FIGURE_DIR / "cultural_wellbeing_network_pooled.png",
        "Exploratory Network of Cultural Well-Being: Pooled",
    )
    network_results.append(pooled.centrality)
    bootstrap_results.append(bootstrap_network_centrality(x_scaled, label="pooled"))

    if "country_group" in network_df.columns:
        for group_name, group_df in network_df.groupby("country_group"):
            if len(group_df) < max(6, len(NETWORK_COLUMNS) // 2):
                continue

            label = safe_label(group_name)
            group_scaled = scale_and_impute(group_df, NETWORK_COLUMNS)
            group_network = estimate_network(group_scaled, label=label)

            group_network.partial_correlations.to_csv(
                TABLE_DIR / f"cultural_wellbeing_partial_correlations_{label}.csv"
            )
            group_network.centrality.to_csv(
                TABLE_DIR / f"cultural_wellbeing_network_centrality_{label}.csv",
                index=False,
            )
            draw_network(
                group_network.graph,
                FIGURE_DIR / f"cultural_wellbeing_network_{label}.png",
                f"Exploratory Network of Cultural Well-Being: {label}",
            )

            network_results.append(group_network.centrality)
            bootstrap_results.append(bootstrap_network_centrality(group_scaled, label=label))

    combined_centrality = pd.concat(network_results, ignore_index=True)
    combined_centrality.to_csv(TABLE_DIR / "cultural_wellbeing_network_centrality_combined.csv", index=False)

    combined_bootstrap = pd.concat(bootstrap_results, ignore_index=True)
    combined_bootstrap.to_csv(TABLE_DIR / "cultural_wellbeing_bootstrap_centrality.csv", index=False)

    print("Professional cultural well-being workflow complete.")
    print(f"Tables written to: {TABLE_DIR}")
    print(f"Figures written to: {FIGURE_DIR}")


if __name__ == "__main__":
    main()
