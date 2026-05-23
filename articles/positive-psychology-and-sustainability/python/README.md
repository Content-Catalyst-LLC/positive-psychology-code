# Python Professional Workflow

This workflow is designed for psychologists, sustainability researchers, public-health researchers, and interdisciplinary teams who need a transparent example of indicator-family reliability, direction-corrected composite scoring, PCA dimensional inspection, exploratory network analysis, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python positive_psychology_sustainability_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/positive_psychology_sustainability_scaled_index.csv`
- `outputs/tables/positive_psychology_sustainability_pca_variance.csv`
- `outputs/tables/positive_psychology_sustainability_partial_correlations.csv`
- `outputs/tables/positive_psychology_sustainability_network_centrality.csv`
- `outputs/tables/positive_psychology_sustainability_bootstrap_centrality.csv`
- `outputs/figures/sustainable_flourishing_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, employment tools, or individual assessments.
