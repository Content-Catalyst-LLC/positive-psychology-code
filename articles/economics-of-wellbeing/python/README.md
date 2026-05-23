# Python Professional Workflow

This workflow is designed for psychologists, well-being economists, public-policy researchers, and interdisciplinary teams who need a transparent example of indicator-family reliability, composite scoring, PCA dimensional inspection, exploratory network analysis, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python economics_of_wellbeing_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/wellbeing_economy_scaled_index.csv`
- `outputs/tables/economics_of_wellbeing_pca_variance.csv`
- `outputs/tables/economics_of_wellbeing_partial_correlations.csv`
- `outputs/tables/economics_of_wellbeing_network_centrality.csv`
- `outputs/tables/economics_of_wellbeing_bootstrap_centrality.csv`
- `outputs/figures/economics_of_wellbeing_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not final measurements of social progress.
