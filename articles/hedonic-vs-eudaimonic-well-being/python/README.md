# Python Professional Workflow

This workflow is designed for psychologists, well-being researchers, public-policy analysts, and interdisciplinary teams who need a transparent example of domain reliability, hedonic/eudaimonic composite scoring, PCA dimensional inspection, exploratory network analysis, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python hedonic_eudaimonic_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/hedonic_eudaimonic_scaled_indices.csv`
- `outputs/tables/hedonic_eudaimonic_pca_variance.csv`
- `outputs/tables/hedonic_eudaimonic_partial_correlations.csv`
- `outputs/tables/hedonic_eudaimonic_network_centrality.csv`
- `outputs/tables/hedonic_eudaimonic_bootstrap_centrality.csv`
- `outputs/figures/hedonic_eudaimonic_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, employment tools, or individual assessments.
