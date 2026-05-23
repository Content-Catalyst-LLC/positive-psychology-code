# Python Professional Workflow

This workflow is designed for positive psychology researchers, gratitude researchers, psychologists, educational researchers, well-being scientists, and interdisciplinary teams who need a transparent example of domain reliability, appreciative-awareness composite scoring, practice-quality auditing, exploratory network analysis, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python three_good_things_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/practice_quality_audit_summary.csv`
- `outputs/tables/three_good_things_scaled_indices.csv`
- `outputs/tables/three_good_things_partial_correlations.csv`
- `outputs/tables/three_good_things_network_centrality.csv`
- `outputs/tables/three_good_things_bootstrap_centrality.csv`
- `outputs/figures/three_good_things_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, employment tools, or individual assessments.
