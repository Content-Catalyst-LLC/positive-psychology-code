# Python Professional Workflow

This workflow is designed for psychologists, psychometricians, well-being researchers, public-policy analysts, and interdisciplinary teams who need a transparent example of domain reliability, multidimensional composite scoring, measurement-quality auditing, PCA dimensional inspection, exploratory network analysis, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python measuring_flourishing_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/measurement_quality_audit_summary.csv`
- `outputs/tables/measuring_flourishing_scaled_indices.csv`
- `outputs/tables/measuring_flourishing_pca_variance.csv`
- `outputs/tables/measuring_flourishing_partial_correlations.csv`
- `outputs/tables/measuring_flourishing_network_centrality.csv`
- `outputs/tables/measuring_flourishing_bootstrap_centrality.csv`
- `outputs/figures/measuring_flourishing_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, employment tools, or individual assessments.
