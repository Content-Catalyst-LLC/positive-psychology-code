# Python Professional Workflow

This workflow is designed for psychologists, motivational scientists, educational psychologists, organizational researchers, health-behavior researchers, sport psychologists, developmental researchers, and interdisciplinary teams who need a transparent example of construct reliability, need-balance scoring, motivational-quality scoring, motivational-climate auditing, exploratory network analysis, PCA dimensional inspection, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python sdt_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/motivational_climate_audit_summary.csv`
- `outputs/tables/sdt_scaled_indices.csv`
- `outputs/tables/sdt_pca_summary.csv`
- `outputs/tables/sdt_partial_correlations.csv`
- `outputs/tables/sdt_network_centrality.csv`
- `outputs/tables/sdt_network_edges.csv`
- `outputs/tables/sdt_bootstrap_centrality.csv`
- `outputs/figures/sdt_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, employment tools, school-ranking tools, screening tools, disciplinary tools, or individual assessments.
