# Python Professional Workflow

This workflow is designed for educational psychologists, school psychologists, well-being researchers, education-policy analysts, and interdisciplinary teams who need a transparent example of domain reliability, school-flourishing composite scoring, implementation-quality auditing, exploratory network analysis, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python positive_education_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/implementation_quality_audit_summary.csv`
- `outputs/tables/positive_education_scaled_indices.csv`
- `outputs/tables/positive_education_partial_correlations.csv`
- `outputs/tables/positive_education_network_centrality.csv`
- `outputs/tables/positive_education_bootstrap_centrality.csv`
- `outputs/figures/positive_education_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, disciplinary tools, ranking tools, or individual student assessments.
