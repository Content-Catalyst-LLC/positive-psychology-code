# Python Professional Workflow

This workflow is designed for positive psychology researchers, well-being scientists, educational psychologists, organizational psychologists, public-health researchers, community researchers, and interdisciplinary teams who need a transparent example of reliability analysis, PERMA profile scoring, profile-balance scoring, institutional-quality scoring, context auditing, exploratory network analysis, PCA dimensional inspection, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python perma_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/perma_context_audit_summary.csv`
- `outputs/tables/perma_scaled_indices.csv`
- `outputs/tables/perma_pca_summary.csv`
- `outputs/tables/perma_partial_correlations.csv`
- `outputs/tables/perma_network_centrality.csv`
- `outputs/tables/perma_network_edges.csv`
- `outputs/tables/perma_bootstrap_centrality.csv`
- `outputs/figures/perma_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, employment tools, school-ranking tools, screening tools, disciplinary tools, benefits tools, or individual assessments.
