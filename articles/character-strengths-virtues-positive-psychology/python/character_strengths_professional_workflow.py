"""Professional research scaffold for character strengths and virtues.

This workflow is designed for psychologists, positive psychology researchers,
moral psychologists, educational psychologists, leadership researchers,
organizational psychologists, counseling researchers, and interdisciplinary teams
who need a transparent, reproducible example of:

- synthetic character-strength data ingestion;
- missingness diagnostics;
- construct-family reliability;
- VIA-style virtue-cluster scoring;
- signature-strength, authenticity, context, suppression, and overuse scoring;
- institutional character-context auditing;
- sparse partial-correlation networks;
- PCA dimensional inspection;
- bootstrap centrality stability;
- reproducible export of figures and tables.

The included data are synthetic. This code is not a clinical, diagnostic,
therapeutic, crisis-support, workplace-screening, employment-selection,
student-ranking, employee-evaluation, school-disciplinary, benefits-eligibility,
moral-ranking, or individual psychological assessment tool.
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

VIRTUE_CLUSTERS = {
    "wisdom": ["creativity", "curiosity", "judgment", "love_learning", "perspective"],
    "courage": ["bravery", "perseverance", "honesty", "zest"],
    "humanity": ["love", "kindness", "social_intelligence"],
    "justice": ["teamwork", "fairness", "leadership"],
    "temperance": ["forgiveness", "humility", "prudence", "self_regulation"],
    "transcendence": ["appreciation_beauty", "gratitude", "hope", "humor", "spirituality"],
}

NETWORK_COLUMNS = [
    "creativity",
    "curiosity",
    "perseverance",
    "honesty",
    "kindness",
    "social_intelligence",
    "fairness",
    "leadership",
    "humility",
    "self_regulation",
    "gratitude",
    "hope",
    "signature_strength_use",
    "authenticity_score",
    "contextual_support",
    "institutional_suppression",
    "strength_overuse_risk",
    "flourishing_score",
]

INDICATOR_FAMILIES = {
    "wisdom": ["wisdom1", "wisdom2"],
    "courage": ["courage1", "courage2"],
    "humanity": ["humanity1", "humanity2"],
    "justice": ["justice1", "justice2"],
    "temperance": ["temperance1", "temperance2"],
    "transcendence": ["transcendence1", "transcendence2"],
    "signature_strength_use": ["signature1", "signature2"],
    "authenticity": ["authenticity1", "authenticity2"],
    "contextual_support": ["support1", "support2"],
    "institutional_suppression": ["suppression1", "suppression2"],
    "strength_overuse_risk": ["overuse1", "overuse2"],
    "flourishing": ["flourishing1", "flourishing2"],
    "meaning": ["meaning1", "meaning2"],
    "relationships": ["relationships1", "relationships2"],
    "engagement": ["engagement1", "engagement2"],
}


@dataclass
class NetworkResults:
    partial_correlations: pd.DataFrame
    centrality: pd.DataFrame
    edges: pd.DataFrame
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
    """Compute reliability diagnostics for synthetic character-strength construct families."""
    rows = []

    for family_name, columns in INDICATOR_FAMILIES.items():
        require_columns(indicator_df, columns, f"{family_name} indicator family")
        items = indicator_df[columns].apply(pd.to_numeric, errors="coerce")

        if family_name in {"institutional_suppression", "strength_overuse_risk"}:
            items_for_alpha = -items
        else:
            items_for_alpha = items

        rows.append(
            {
                "indicator_family": family_name,
                "n_indicators": len(columns),
                "cronbach_alpha": cronbach_alpha(items_for_alpha),
                "mean_family_score": float(items.mean(axis=1).mean()),
                "sd_family_score": float(items.mean(axis=1).std(ddof=1)),
            }
        )

    return pd.DataFrame(rows)


def score_virtue_clusters(panel_df: pd.DataFrame) -> pd.DataFrame:
    """Score VIA-style virtue clusters and character-expression indices."""
    result = panel_df.copy()

    for cluster_name, columns in VIRTUE_CLUSTERS.items():
        require_columns(result, columns, f"{cluster_name} strength columns")
        result[cluster_name] = result[columns].mean(axis=1)

    result["virtue_profile_mean"] = result[list(VIRTUE_CLUSTERS.keys())].mean(axis=1)

    result["strength_expression_index"] = (
        result["signature_strength_use"]
        + result["authenticity_score"]
        + result["contextual_support"]
        - result["institutional_suppression"]
        - result["strength_overuse_risk"]
    )

    result["civic_character_index"] = (
        result["fairness"]
        + result["leadership"]
        + result["humility"]
        + result["honesty"]
        + result["self_regulation"]
    ) / 5

    result["relational_character_index"] = (
        result["kindness"]
        + result["social_intelligence"]
        + result["gratitude"]
        + result["honesty"]
    ) / 4

    result["context_adjusted_flourishing"] = (
        result["flourishing_score"]
        + result["strength_expression_index"]
        + result["contextual_support"]
        - result["institutional_suppression"]
        - result["strength_overuse_risk"]
    )

    return result


def scale_and_impute(df: pd.DataFrame, columns: list[str]) -> pd.DataFrame:
    """Median-impute and standardize selected columns."""
    require_columns(df, columns, "analysis dataframe")

    imputer = SimpleImputer(strategy="median")
    imputed = pd.DataFrame(imputer.fit_transform(df[columns]), columns=columns)

    scaler = StandardScaler()
    scaled = pd.DataFrame(scaler.fit_transform(imputed), columns=columns)

    return scaled


def build_network_indices(x_scaled: pd.DataFrame) -> pd.DataFrame:
    """Construct transparent character-strength system indices."""
    result = x_scaled.copy()

    result["strength_expression_index"] = (
        result["signature_strength_use"]
        + result["authenticity_score"]
        + result["contextual_support"]
        - result["institutional_suppression"]
        - result["strength_overuse_risk"]
    )

    result["civic_character_index"] = (
        result["fairness"]
        + result["leadership"]
        + result["humility"]
        + result["honesty"]
        + result["self_regulation"]
    ) / 5

    result["relational_character_index"] = (
        result["kindness"]
        + result["social_intelligence"]
        + result["gratitude"]
        + result["honesty"]
    ) / 4

    result["resilient_character_index"] = (
        result["perseverance"]
        + result["hope"]
        + result["self_regulation"]
        + result["humility"]
        - result["institutional_suppression"]
    ) / 5

    return result


def audit_character_context(audit_df: pd.DataFrame) -> pd.DataFrame:
    """Create a transparent institutional/context audit for character-strength work."""
    quality_columns = [
        "truth_telling_support",
        "fairness_support",
        "humility_support",
        "leadership_accountability",
        "care_support",
        "learning_support",
        "autonomy_support",
        "anti_coercion_review",
        "privacy_safeguards",
        "cultural_adaptation",
        "measurement_quality",
    ]
    require_columns(audit_df, quality_columns, "character context audit dataframe")

    result = audit_df.copy()
    result["computed_context_quality"] = result[quality_columns].mean(axis=1)
    result["lowest_support_dimension"] = result[quality_columns].idxmin(axis=1)
    result["quality_gap"] = result["overall_context_quality"] - result["computed_context_quality"]

    return result.sort_values("computed_context_quality", ascending=False)


def pca_summary(x_scaled: pd.DataFrame) -> pd.DataFrame:
    """Run PCA for dimensional inspection of character-strength variables."""
    pca_columns = [
        "creativity",
        "curiosity",
        "perseverance",
        "honesty",
        "kindness",
        "social_intelligence",
        "fairness",
        "leadership",
        "humility",
        "self_regulation",
        "gratitude",
        "hope",
        "flourishing_score",
    ]
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
    edges = edge_table(graph)

    return NetworkResults(partial_df, centrality, edges, graph)


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


def edge_table(graph: nx.Graph) -> pd.DataFrame:
    """Return edge table with sign and magnitude."""
    if graph.number_of_edges() == 0:
        return pd.DataFrame(
            columns=["source", "target", "partial_correlation", "absolute_weight", "sign"]
        )

    return pd.DataFrame(
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
    ).sort_values("absolute_weight", ascending=False)


def bootstrap_network_centrality(
    x_scaled: pd.DataFrame,
    n_boot: int = 100,
    threshold: float = 0.08,
    seed: int = 42,
) -> pd.DataFrame:
    """Bootstrap centrality estimates for exploratory character-network stability checks."""
    rng = np.random.default_rng(seed)
    rows = []

    for boot_id in range(n_boot):
        sample_idx = rng.choice(x_scaled.index.to_numpy(), size=len(x_scaled), replace=True)
        boot_sample = x_scaled.loc[sample_idx, NETWORK_COLUMNS].reset_index(drop=True)

        try:
            results = estimate_network(boot_sample, threshold=threshold)
            rows.append(results.centrality.assign(bootstrap=boot_id))
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
    plt.figure(figsize=(13, 10))

    if graph.number_of_edges() > 0:
        pos = nx.spring_layout(graph, seed=42, k=0.85)
        positive_edges = [(u, v) for u, v in graph.edges() if graph[u][v]["weight"] > 0]
        negative_edges = [(u, v) for u, v in graph.edges() if graph[u][v]["weight"] < 0]

        nx.draw_networkx_edges(
            graph,
            pos,
            edgelist=positive_edges,
            width=[abs(graph[u][v]["weight"]) * 5 for u, v in positive_edges],
            alpha=0.75,
        )
        nx.draw_networkx_edges(
            graph,
            pos,
            edgelist=negative_edges,
            width=[abs(graph[u][v]["weight"]) * 5 for u, v in negative_edges],
            style="dashed",
            alpha=0.75,
        )
    else:
        pos = nx.circular_layout(graph)

    nx.draw_networkx_nodes(graph, pos, node_size=1700)
    nx.draw_networkx_labels(graph, pos, font_size=8)

    plt.title("Partial Correlation Network of Character Strengths Variables")
    plt.axis("off")
    plt.tight_layout()
    plt.savefig(path, dpi=300, bbox_inches="tight")
    plt.close()


def main() -> None:
    panel_df = pd.read_csv(RAW_DIR / "character_strengths_panel.csv")
    network_df = pd.read_csv(RAW_DIR / "character_strengths_network.csv")
    indicator_df = pd.read_csv(RAW_DIR / "character_strengths_indicator_bank.csv")
    audit_df = pd.read_csv(RAW_DIR / "character_context_audit.csv")

    missingness_table(panel_df).to_csv(TABLE_DIR / "panel_missingness.csv", index=False)
    missingness_table(network_df).to_csv(TABLE_DIR / "network_missingness.csv", index=False)
    missingness_table(indicator_df).to_csv(TABLE_DIR / "indicator_bank_missingness.csv", index=False)
    missingness_table(audit_df).to_csv(TABLE_DIR / "character_context_audit_missingness.csv", index=False)

    reliability = reliability_report(indicator_df)
    character_context_audit = audit_character_context(audit_df)
    scored_panel = score_virtue_clusters(panel_df)

    reliability.to_csv(TABLE_DIR / "indicator_family_reliability_report.csv", index=False)
    character_context_audit.to_csv(TABLE_DIR / "character_context_audit_summary.csv", index=False)
    scored_panel.to_csv(TABLE_DIR / "character_strengths_scored_panel.csv", index=False)

    x_scaled = scale_and_impute(network_df, NETWORK_COLUMNS)
    indexed = build_network_indices(x_scaled)
    pca = pca_summary(x_scaled)
    network = estimate_network(x_scaled)
    bootstrap_summary = bootstrap_network_centrality(x_scaled, n_boot=100)

    indexed.to_csv(TABLE_DIR / "character_strengths_scaled_indices.csv", index=False)
    pca.to_csv(TABLE_DIR / "character_strengths_pca_summary.csv", index=False)
    network.partial_correlations.to_csv(TABLE_DIR / "character_strengths_partial_correlations.csv")
    network.centrality.to_csv(TABLE_DIR / "character_strengths_network_centrality.csv", index=False)
    network.edges.to_csv(TABLE_DIR / "character_strengths_network_edges.csv", index=False)
    bootstrap_summary.to_csv(TABLE_DIR / "character_strengths_bootstrap_centrality.csv", index=False)

    draw_network(network.graph, FIGURE_DIR / "character_strengths_network.png")

    print("Professional character strengths and virtues workflow complete.")
    print(f"Tables written to: {TABLE_DIR}")
    print(f"Figures written to: {FIGURE_DIR}")


if __name__ == "__main__":
    main()
