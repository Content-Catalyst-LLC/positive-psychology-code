# Python Professional Workflow

This workflow is designed for psychologists and interdisciplinary researchers who need a transparent example of reliability diagnostics, composite scoring, dimensional inspection, exploratory network analysis, and bootstrap stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python future_wellbeing_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/item_reliability_report.csv`
- `outputs/tables/future_wellbeing_pca_variance.csv`
- `outputs/tables/future_wellbeing_factor_loadings.csv`
- `outputs/tables/future_wellbeing_partial_correlations.csv`
- `outputs/tables/future_wellbeing_network_centrality.csv`
- `outputs/tables/future_wellbeing_bootstrap_centrality.csv`
- `outputs/figures/future_wellbeing_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Centrality should be interpreted cautiously and preferably checked with larger samples, sensitivity analysis, and theory-driven models.
