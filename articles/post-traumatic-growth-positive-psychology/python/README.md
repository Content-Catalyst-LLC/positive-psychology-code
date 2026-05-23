# Python Professional Workflow

This workflow is designed for psychologists, trauma researchers, positive psychology researchers, counseling researchers, clinical researchers, resilience researchers, meaning-making researchers, and interdisciplinary teams who need a transparent example of construct reliability, PTG domain scoring, integration scoring, growth-distress scoring, trauma-context auditing, exploratory network analysis, PCA dimensional inspection, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python ptg_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/context_support_audit_summary.csv`
- `outputs/tables/ptg_scored_panel.csv`
- `outputs/tables/ptg_pca_summary.csv`
- `outputs/tables/ptg_partial_correlations.csv`
- `outputs/tables/ptg_network_centrality.csv`
- `outputs/tables/ptg_network_edges.csv`
- `outputs/tables/ptg_bootstrap_centrality.csv`
- `outputs/figures/ptg_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, crisis tools, employment tools, school-ranking tools, screening tools, disciplinary tools, benefits tools, legal tools, insurance tools, or individual assessments.
