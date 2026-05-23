# Python Professional Workflow

This workflow is designed for psychologists, positive psychology researchers, attribution researchers, resilience researchers, educational psychologists, counseling researchers, health psychologists, organizational psychologists, public-health researchers, and interdisciplinary teams who need a transparent example of reliability analysis, helplessness-index scoring, control-gap scoring, agency-recovery scoring, context auditing, exploratory network analysis, PCA dimensional inspection, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python learned_helplessness_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/learned_helplessness_context_audit_summary.csv`
- `outputs/tables/learned_helplessness_scaled_indices.csv`
- `outputs/tables/learned_helplessness_pca_summary.csv`
- `outputs/tables/learned_helplessness_partial_correlations.csv`
- `outputs/tables/learned_helplessness_network_centrality.csv`
- `outputs/tables/learned_helplessness_network_edges.csv`
- `outputs/tables/learned_helplessness_bootstrap_centrality.csv`
- `outputs/figures/learned_helplessness_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, employment tools, school-ranking tools, screening tools, disciplinary tools, benefits tools, or individual assessments.
