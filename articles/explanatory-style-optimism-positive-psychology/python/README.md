# Python Professional Workflow

This workflow is designed for psychologists, positive psychology researchers, attribution researchers, resilience researchers, educational psychologists, counseling researchers, health psychologists, organizational psychologists, and interdisciplinary teams who need a transparent example of reliability analysis, explanatory-burden scoring, positive-event integration, context-adjusted agency, context auditing, exploratory network analysis, PCA dimensional inspection, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python explanatory_style_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/explanatory_style_context_audit_summary.csv`
- `outputs/tables/explanatory_style_scaled_indices.csv`
- `outputs/tables/explanatory_style_pca_summary.csv`
- `outputs/tables/explanatory_style_partial_correlations.csv`
- `outputs/tables/explanatory_style_network_centrality.csv`
- `outputs/tables/explanatory_style_network_edges.csv`
- `outputs/tables/explanatory_style_bootstrap_centrality.csv`
- `outputs/figures/explanatory_style_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, employment tools, school-ranking tools, screening tools, disciplinary tools, benefits tools, or individual assessments.
