"""Composite and network analysis of public well-being metrics.

This script uses synthetic sample data included in the article folder.
Replace the sample data with documented empirical data before using the
workflow for publication-quality analysis.
"""

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import networkx as nx
import numpy as np
import pandas as pd
from sklearn.covariance import GraphicalLassoCV
from sklearn.decomposition import PCA
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler


BASE_DIR = Path(__file__).resolve().parents[1]
DATA_PATH = BASE_DIR / "data" / "raw" / "wellbeing_metrics_crosssectional.csv"
OUTPUT_DIR = BASE_DIR / "outputs"
FIGURE_DIR = OUTPUT_DIR / "figures"
TABLE_DIR = OUTPUT_DIR / "tables"

FIGURE_DIR.mkdir(parents=True, exist_ok=True)
TABLE_DIR.mkdir(parents=True, exist_ok=True)

COLUMNS = [
    "life_satisfaction",
    "health_index",
    "trust_index",
    "income_security",
    "housing_quality",
    "education_access",
    "democratic_quality",
    "environmental_quality",
    "inequality_index",
]


def load_and_scale(path: Path) -> pd.DataFrame:
    """Load data, impute missing values, and standardize indicators."""
    df = pd.read_csv(path)
    missing = [col for col in COLUMNS if col not in df.columns]
    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    imputer = SimpleImputer(strategy="median")
    x_imputed = pd.DataFrame(imputer.fit_transform(df[COLUMNS]), columns=COLUMNS)

    scaler = StandardScaler()
    return pd.DataFrame(scaler.fit_transform(x_imputed), columns=COLUMNS)


def build_composite_index(x_scaled: pd.DataFrame) -> pd.DataFrame:
    """Construct a transparent composite index with an inequality penalty."""
    result = x_scaled.copy()
    result["public_wellbeing_index"] = (
        0.16 * result["life_satisfaction"]
        + 0.14 * result["health_index"]
        + 0.14 * result["trust_index"]
        + 0.14 * result["income_security"]
        + 0.10 * result["housing_quality"]
        + 0.10 * result["education_access"]
        + 0.10 * result["democratic_quality"]
        + 0.08 * result["environmental_quality"]
        - 0.08 * result["inequality_index"]
    )
    return result


def run_pca(x_scaled: pd.DataFrame) -> pd.DataFrame:
    """Run PCA for dimensional inspection."""
    pca = PCA(n_components=3)
    pca.fit_transform(x_scaled[COLUMNS])
    return pd.DataFrame(
        {
            "component": [1, 2, 3],
            "variance_explained": pca.explained_variance_ratio_,
        }
    )


def build_partial_correlation_network(
    x_scaled: pd.DataFrame, threshold: float = 0.08
) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Estimate a sparse partial-correlation network."""
    glasso = GraphicalLassoCV()
    glasso.fit(x_scaled[COLUMNS])

    precision = glasso.precision_
    partial_corr = -precision / np.sqrt(np.outer(np.diag(precision), np.diag(precision)))
    np.fill_diagonal(partial_corr, 0)

    partial_df = pd.DataFrame(partial_corr, index=COLUMNS, columns=COLUMNS)

    graph = nx.Graph()
    graph.add_nodes_from(COLUMNS)

    for i, source in enumerate(COLUMNS):
        for j, target in enumerate(COLUMNS):
            if j > i and abs(partial_df.iloc[i, j]) >= threshold:
                graph.add_edge(source, target, weight=float(partial_df.iloc[i, j]))

    degree = nx.degree_centrality(graph)
    betweenness = nx.betweenness_centrality(graph, weight="weight")

    if graph.number_of_edges() > 0:
        eigenvector = nx.eigenvector_centrality_numpy(graph, weight="weight")
    else:
        eigenvector = {node: 0.0 for node in graph.nodes}

    centrality = pd.DataFrame(
        {
            "node": list(graph.nodes()),
            "degree_centrality": [degree[node] for node in graph.nodes()],
            "betweenness_centrality": [betweenness[node] for node in graph.nodes()],
            "eigenvector_centrality": [eigenvector[node] for node in graph.nodes()],
        }
    ).sort_values("eigenvector_centrality", ascending=False)

    draw_network(graph)
    return partial_df, centrality


def draw_network(graph: nx.Graph) -> None:
    """Save a network figure."""
    plt.figure(figsize=(10, 8))

    if graph.number_of_edges() > 0:
        pos = nx.spring_layout(graph, seed=42, k=0.78)
        edge_widths = [abs(graph[u][v]["weight"]) * 4 for u, v in graph.edges()]
        nx.draw_networkx_edges(graph, pos, width=edge_widths)
    else:
        pos = nx.circular_layout(graph)

    nx.draw_networkx_nodes(graph, pos, node_size=1800)
    nx.draw_networkx_labels(graph, pos, font_size=9)

    plt.title("Partial Correlation Network of Public Well-Being Metrics")
    plt.axis("off")
    plt.tight_layout()
    plt.savefig(FIGURE_DIR / "wellbeing_metrics_network.png", dpi=300, bbox_inches="tight")
    plt.close()


def main() -> None:
    x_scaled = load_and_scale(DATA_PATH)
    indexed = build_composite_index(x_scaled)
    explained = run_pca(x_scaled)
    partial_corr, centrality = build_partial_correlation_network(x_scaled)

    indexed.to_csv(TABLE_DIR / "wellbeing_metrics_scaled_index.csv", index=False)
    explained.to_csv(TABLE_DIR / "wellbeing_metrics_pca_variance.csv", index=False)
    partial_corr.to_csv(TABLE_DIR / "wellbeing_metrics_partial_correlations.csv")
    centrality.to_csv(TABLE_DIR / "wellbeing_metrics_network_centrality.csv", index=False)

    print("Analysis complete.")
    print(f"Outputs written to: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
