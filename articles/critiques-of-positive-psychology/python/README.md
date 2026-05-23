# Python Professional Workflow

This workflow is designed for psychologists, well-being researchers, critical psychology scholars, and interdisciplinary teams who need a transparent example of reliability diagnostics, critique-sensitive composite scoring, PCA dimensional inspection, exploratory network analysis, bootstrap centrality stability checks, and construct-distortion modeling.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python positive_psychology_critiques_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/critique_sensitive_flourishing_scaled_index.csv`
- `outputs/tables/positive_psychology_critiques_pca_variance.csv`
- `outputs/tables/positive_psychology_critiques_partial_correlations.csv`
- `outputs/tables/positive_psychology_critiques_network_centrality.csv`
- `outputs/tables/positive_psychology_critiques_bootstrap_centrality.csv`
- `outputs/tables/construct_distortion_model_coefficients.csv`
- `outputs/figures/positive_psychology_critiques_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, employment tools, or individual assessments.
