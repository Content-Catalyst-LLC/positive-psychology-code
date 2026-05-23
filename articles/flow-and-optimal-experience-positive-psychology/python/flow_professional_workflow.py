"""Professional research scaffold for flow and optimal experience.

This workflow is designed for psychologists, positive psychology researchers,
educational psychologists, cognitive psychologists, creativity researchers,
sport psychologists, work and organizational psychologists, human factors
researchers, and interdisciplinary teams who need a transparent,
reproducible example of:

- synthetic flow data ingestion;
- missingness diagnostics;
- construct-family reliability;
- challenge-skill balance, attentional ecology, deep engagement, and sustainable-flow scoring;
- attention-context auditing;
- sparse partial-correlation networks;
- PCA dimensional inspection;
- bootstrap centrality stability;
- reproducible export of figures and tables.

The included data are synthetic. This code is not a clinical, diagnostic,
therapeutic, crisis-support, workplace-screening, employment-selection,
student-ranking, employee-evaluation, productivity-surveillance,
benefits-eligibility, or individual psychological assessment tool.
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
    "challenge_level",
    "skill_level",
    "attention_focus",
    "feedback_quality",
    "goal_clarity",
    "task_meaning",
    "autonomy_support",
    "distraction_load",
    "interruption_count",
    "flow_score",
    "performance_score",
    "learning_gain",
    "fatigue_score",
    "recovery_quality",
    "wellbeing_score",
]

INDICATOR_FAMILIES = {
    "challenge": ["challenge1", "challenge2"],
    "skill": ["skill1", "skill2"],
    "attention": ["attention1", "attention2"],
    "feedback": ["feedback1", "feedback2"],
    "clarity": ["clarity1", "clarity2"],
    "meaning": ["meaning1", "meaning2"],
    "autonomy": ["autonomy1", "autonomy2"],
    "distraction": ["distraction1", "distraction2"],
    "flow": ["flow1", "flow2"],
    "performance": ["performance1", "performance2"],
    "fatigue": ["fatigue1", "fatigue2"],
    "recovery": ["recovery1", "recovery2"],
    "wellbeing": ["wellbeing1", "wellbeing2"],
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
    """Compute reliability diagnostics for synthetic flow construct families."""
    rows = []

    for family_name, columns in INDICATOR_FAMILIES.items():
        require_columns(indicator_df, columns, f"{family_name} indicator family")
        items = indicator_df[columns].apply(pd.to_numeric, errors="coerce")

        if family_name in {"distraction", "fatigue"}:
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


def scale_and_impute(df: pd.DataFrame, columns: list[str]) -> pd.DataFrame:
    """Median-impute and standardize selected columns."""
    require_columns(df, columns, "analysis dataframe")

    imputer = SimpleImputer(strategy="median")
    imputed = pd.DataFrame(imputer.fit_transform(df[columns]), columns=columns)

    scaler = StandardScaler()
    scaled = pd.DataFrame(scaler.fit_transform(imputed), columns=columns)

    return scaled


def build_flow_indices(x_scaled: pd.DataFrame) -> pd.DataFrame:
    """Construct transparent flow and attention-ecology indices for teaching and exploratory analysis."""
    result = x_scaled.copy()

    result["balance_index"] = -(
        result["challenge_level"] - result["skill_level"]
    ).abs()

    result["attentional_ecology"] = (
        result["attention_focus"]
        + result["feedback_quality"]
        + result["goal_clarity"]
        - result["distraction_load"]
        - result["interruption_count"]
    )

    result["deep_engagement_context"] = (
        result["balance_index"]
        + result["attention_focus"]
        + result["feedback_quality"]
        + result["goal_clarity"]
        + result["task_meaning"]
        + result["autonomy_support"]
        - result["distraction_load"]
        - result["interruption_count"]
    )

    result["sustainable_flow_index"] = (
        result["flow_score"]
        + result["task_meaning"]
        + result["autonomy_support"]
        + result["recovery_quality"]
        - result["fatigue_score"]
        - result["distraction_load"]
    )

    return result


def audit_attention_context(audit_df: pd.DataFrame) -> pd.DataFrame:
    """Create a transparent attention-context audit summary."""
    quality_columns = [
        "goal_clarity_support",
        "feedback_quality_support",
        "challenge_calibration",
        "skill_development_support",
        "attention_protection",
        "autonomy_support_quality",
        "distraction_control",
        "recovery_support",
        "privacy_safeguards",
        "anti_surveillance_review",
    ]
    require_columns(audit_df, quality_columns, "attention context audit dataframe")

    result = audit_df.copy()
    result["computed_context_quality"] = result[quality_columns].mean(axis=1)
    result["lowest_support_dimension"] = result[quality_columns].idxmin(axis=1)
    result["quality_gap"] = result["overall_context_quality"] - result["computed_context_quality"]

    return result.sort_values("computed_context_quality", ascending=False)


def pca_summary(x_scaled: pd.DataFrame) -> pd.DataFrame:
    """Run PCA for dimensional inspection of flow-system variables."""
    pca_columns = [
        "challenge_level",
        "skill_level",
        "attention_focus",
        "feedback_quality",
        "goal_clarity",
        "task_meaning",
        "autonomy_support",
        "distraction_load",
        "interruption_count",
        "flow_score",
        "fatigue_score",
        "recovery_quality",
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
    """Bootstrap centrality estimates for exploratory flow-network stability checks."""
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
    plt.figure(figsize=(12, 9))

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

    nx.draw_networkx_nodes(graph, pos, node_size=1800)
    nx.draw_networkx_labels(graph, pos, font_size=8)

    plt.title("Partial Correlation Network of Flow and Optimal Experience Variables")
    plt.axis("off")
    plt.tight_layout()
    plt.savefig(path, dpi=300, bbox_inches="tight")
    plt.close()


def main() -> None:
    panel_df = pd.read_csv(RAW_DIR / "flow_optimal_experience_panel.csv")
    network_df = pd.read_csv(RAW_DIR / "flow_optimal_experience_network.csv")
    indicator_df = pd.read_csv(RAW_DIR / "flow_indicator_bank.csv")
    audit_df = pd.read_csv(RAW_DIR / "flow_attention_context_audit.csv")

    missingness_table(panel_df).to_csv(TABLE_DIR / "panel_missingness.csv", index=False)
    missingness_table(network_df).to_csv(TABLE_DIR / "network_missingness.csv", index=False)
    missingness_table(indicator_df).to_csv(TABLE_DIR / "indicator_bank_missingness.csv", index=False)
    missingness_table(audit_df).to_csv(TABLE_DIR / "attention_context_audit_missingness.csv", index=False)

    reliability = reliability_report(indicator_df)
    attention_audit = audit_attention_context(audit_df)

    reliability.to_csv(TABLE_DIR / "indicator_family_reliability_report.csv", index=False)
    attention_audit.to_csv(TABLE_DIR / "attention_context_audit_summary.csv", index=False)

    x_scaled = scale_and_impute(network_df, NETWORK_COLUMNS)
    indexed = build_flow_indices(x_scaled)
    pca = pca_summary(x_scaled)
    network = estimate_network(x_scaled)
    bootstrap_summary = bootstrap_network_centrality(x_scaled, n_boot=100)

    indexed.to_csv(TABLE_DIR / "flow_scaled_indices.csv", index=False)
    pca.to_csv(TABLE_DIR / "flow_pca_summary.csv", index=False)
    network.partial_correlations.to_csv(TABLE_DIR / "flow_partial_correlations.csv")
    network.centrality.to_csv(TABLE_DIR / "flow_network_centrality.csv", index=False)
    network.edges.to_csv(TABLE_DIR / "flow_network_edges.csv", index=False)
    bootstrap_summary.to_csv(TABLE_DIR / "flow_bootstrap_centrality.csv", index=False)

    draw_network(network.graph, FIGURE_DIR / "flow_network.png")

    print("Professional flow and optimal experience workflow complete.")
    print(f"Tables written to: {TABLE_DIR}")
    print(f"Figures written to: {FIGURE_DIR}")


if __name__ == "__main__":
    main()
