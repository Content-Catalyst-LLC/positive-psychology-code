# Python Professional Workflow

This workflow is designed for psychologists and cross-cultural researchers who need a transparent example of reliability diagnostics, composite scoring, dimensional inspection, pooled and group-specific exploratory network analysis, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python cultural_wellbeing_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/item_reliability_report.csv`
- `outputs/tables/cultural_wellbeing_pca_variance.csv`
- `outputs/tables/cultural_wellbeing_factor_loadings.csv`
- `outputs/tables/cultural_wellbeing_network_centrality_combined.csv`
- `outputs/tables/cultural_wellbeing_bootstrap_centrality.csv`
- `outputs/figures/cultural_wellbeing_network_pooled.png`
- group-specific network figures where sample size permits.

## Method note

Network results are exploratory structural summaries, not causal proof. Cross-cultural network comparison should be interpreted cautiously and paired with measurement-equivalence checks, local expertise, and qualitative interpretation.
