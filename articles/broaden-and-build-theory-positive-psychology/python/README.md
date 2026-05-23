# Python Professional Workflow

This workflow is designed for positive psychology researchers, psychologists, emotion researchers, resilience researchers, educational researchers, organizational researchers, well-being scientists, and interdisciplinary teams who need a transparent example of domain reliability, broadening/resource scoring, practice-quality auditing, exploratory network analysis, PCA dimensional inspection, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python broaden_build_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/broaden_build_practice_quality_audit_summary.csv`
- `outputs/tables/broaden_build_scaled_indices.csv`
- `outputs/tables/broaden_build_pca_summary.csv`
- `outputs/tables/broaden_build_partial_correlations.csv`
- `outputs/tables/broaden_build_network_centrality.csv`
- `outputs/tables/broaden_build_network_edges.csv`
- `outputs/tables/broaden_build_bootstrap_centrality.csv`
- `outputs/figures/broaden_build_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, employment tools, screening tools, or individual assessments.
