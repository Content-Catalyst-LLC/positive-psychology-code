"""Network analysis of virtue domains and flourishing indicators."""

from pathlib import Path
import matplotlib.pyplot as plt
import networkx as nx
import numpy as np
import pandas as pd
from sklearn.covariance import GraphicalLassoCV
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data" / "virtue_strengths_crosssectional.csv"
OUT = ROOT / "outputs"
OUT.mkdir(parents=True, exist_ok=True)

COLUMNS = [
    "wisdom", "courage", "humanity", "justice", "temperance", "transcendence",
    "meaning", "relationships", "accomplishment", "positive_emotion",
]


def main() -> None:
    df = pd.read_csv(DATA)
    imputed = SimpleImputer(strategy="median").fit_transform(df[COLUMNS])
    scaled = StandardScaler().fit_transform(imputed)
    x_scaled = pd.DataFrame(scaled, columns=COLUMNS)

    glasso = GraphicalLassoCV()
    glasso.fit(x_scaled)
    precision = glasso.precision_
    partial_corr = -precision / np.sqrt(np.outer(np.diag(precision), np.diag(precision)))
    np.fill_diagonal(partial_corr, 0)
    partial_df = pd.DataFrame(partial_corr, index=COLUMNS, columns=COLUMNS)

    graph = nx.Graph()
    graph.add_nodes_from(COLUMNS)
    for i, source in enumerate(COLUMNS):
        for j, target in enumerate(COLUMNS):
            if j > i and abs(partial_df.iloc[i, j]) >= 0.08:
                graph.add_edge(source, target, weight=float(partial_df.iloc[i, j]))

    degree = nx.degree_centrality(graph)
    betweenness = nx.betweenness_centrality(graph, weight="weight")
    eigenvector = nx.eigenvector_centrality_numpy(graph, weight="weight")

    centrality = pd.DataFrame({
        "node": list(graph.nodes()),
        "degree_centrality": [degree[node] for node in graph.nodes()],
        "betweenness_centrality": [betweenness[node] for node in graph.nodes()],
        "eigenvector_centrality": [eigenvector[node] for node in graph.nodes()],
    }).sort_values("eigenvector_centrality", ascending=False)

    partial_df.to_csv(OUT / "virtue_partial_correlations.csv")
    centrality.to_csv(OUT / "virtue_network_centrality.csv", index=False)

    plt.figure(figsize=(11, 8))
    pos = nx.spring_layout(graph, seed=42, k=0.75)
    edge_widths = [max(abs(graph[u][v]["weight"]) * 5, 0.5) for u, v in graph.edges()]
    nx.draw_networkx_nodes(graph, pos, node_size=1700)
    nx.draw_networkx_labels(graph, pos, font_size=9)
    nx.draw_networkx_edges(graph, pos, width=edge_widths)
    plt.title("Partial Correlation Network of Virtue Domains and Flourishing Indicators")
    plt.axis("off")
    plt.tight_layout()
    plt.savefig(OUT / "virtue_network_plot.png", dpi=300, bbox_inches="tight")

    print(centrality)


if __name__ == "__main__":
    main()
