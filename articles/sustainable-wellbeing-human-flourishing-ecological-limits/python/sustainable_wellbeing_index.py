"""Composite and network analysis for sustainable well-being."""

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
DATA_PATH = BASE_DIR / "data" / "raw" / "sustainable_wellbeing_crosssectional_sample.csv"
OUTPUT_DIR = BASE_DIR / "outputs"
FIGURE_DIR = OUTPUT_DIR / "figures"
TABLE_DIR = OUTPUT_DIR / "tables"

FIGURE_DIR.mkdir(parents=True, exist_ok=True)
TABLE_DIR.mkdir(parents=True, exist_ok=True)

COLUMNS = [
    "life_satisfaction",
    "meaning",
    "health",
    "social_trust",
    "institutional_quality",
    "ecological_integrity",
    "carbon_pressure",
    "inequality_index",
    "civic_participation",
]


def load_and_scale(path: Path) -> pd.DataFrame:
    df = pd.read_csv(path)
    missing = [col for col in COLUMNS if col not in df.columns]
    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    imputer = SimpleImputer(strategy="median")
    X = pd.DataFrame(imputer.fit_transform(df[COLUMNS]), columns=COLUMNS)

    scaler = StandardScaler()
    return pd.DataFrame(scaler.fit_transform(X), columns=COLUMNS)


def build_composite_index(X_scaled: pd.DataFrame) -> pd.DataFrame:
    result = X_scaled.copy()
    result["sustainable_wellbeing_index"] = (
        0.16 * result["life_satisfaction"]
        + 0.14 * result["meaning"]
        + 0.12 * result["health"]
        + 0.12 * result["social_trust"]
        + 0.14 * result["institutional_quality"]
        + 0.14 * result["ecological_integrity"]
        + 0.10 * result["civic_participation"]
        - 0.04 * result["carbon_pressure"]
        - 0.04 * result["inequality_index"]
    )
    return result


def run_pca(X_scaled: pd.DataFrame) -> pd.DataFrame:
    pca = PCA(n_components=3)
    pca.fit_transform(X_scaled[COLUMNS])
    return pd.DataFrame(
        {
            "component": [1, 2, 3],
            "variance_explained": pca.explained_variance_ratio_,
        }
    )


def build_partial_correlation_network(X_scaled: pd.DataFrame, threshold: float = 0.08) -> tuple[pd.DataFrame, pd.DataFrame]:
    glasso = GraphicalLassoCV()
    glasso.fit(X_scaled[COLUMNS])

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
    plt.figure(figsize=(10, 8))

    if graph.number_of_edges() > 0:
        pos = nx.spring_layout(graph, seed=42, k=0.75)
        edge_widths = [abs(graph[u][v]["weight"]) * 4 for u, v in graph.edges()]
        nx.draw_networkx_edges(graph, pos, width=edge_widths)
    else:
        pos = nx.circular_layout(graph)

    nx.draw_networkx_nodes(graph, pos, node_size=1800)
    nx.draw_networkx_labels(graph, pos, font_size=9)

    plt.title("Partial Correlation Network of Sustainable Well-Being")
    plt.axis("off")
    plt.tight_layout()
    plt.savefig(FIGURE_DIR / "sustainable_wellbeing_network.png", dpi=300, bbox_inches="tight")
    plt.close()


def main() -> None:
    X_scaled = load_and_scale(DATA_PATH)
    indexed = build_composite_index(X_scaled)
    explained = run_pca(X_scaled)
    partial_corr, centrality = build_partial_correlation_network(X_scaled)

    indexed.to_csv(TABLE_DIR / "sustainable_wellbeing_scaled_index.csv", index=False)
    explained.to_csv(TABLE_DIR / "sustainable_wellbeing_pca_variance.csv", index=False)
    partial_corr.to_csv(TABLE_DIR / "sustainable_wellbeing_partial_correlations.csv")
    centrality.to_csv(TABLE_DIR / "sustainable_wellbeing_network_centrality.csv", index=False)

    print("Analysis complete.")
    print(f"Outputs written to: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
