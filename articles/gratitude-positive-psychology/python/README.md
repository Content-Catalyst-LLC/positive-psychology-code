# Python Professional Workflow

This workflow is designed for positive psychology researchers, gratitude researchers, psychologists, relationship researchers, well-being scientists, and interdisciplinary teams who need a transparent example of domain reliability, appreciative-orientation scoring, practice-quality auditing, exploratory network analysis, PCA dimensional inspection, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python gratitude_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/gratitude_practice_quality_audit_summary.csv`
- `outputs/tables/gratitude_mechanisms_scaled_indices.csv`
- `outputs/tables/gratitude_mechanisms_pca_summary.csv`
- `outputs/tables/gratitude_mechanisms_partial_correlations.csv`
- `outputs/tables/gratitude_mechanisms_network_centrality.csv`
- `outputs/tables/gratitude_mechanisms_network_edges.csv`
- `outputs/tables/gratitude_mechanisms_bootstrap_centrality.csv`
- `outputs/figures/gratitude_mechanisms_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, employment tools, screening tools, or individual assessments.
