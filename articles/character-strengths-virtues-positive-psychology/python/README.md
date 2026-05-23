# Python Professional Workflow

This workflow is designed for psychologists, positive psychology researchers, moral psychologists, educational psychologists, leadership researchers, organizational psychologists, counseling researchers, and interdisciplinary teams who need a transparent example of construct reliability, VIA-style virtue-cluster scoring, signature-strength expression scoring, contextual-support auditing, exploratory network analysis, PCA dimensional inspection, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python character_strengths_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/character_context_audit_summary.csv`
- `outputs/tables/character_strengths_scored_panel.csv`
- `outputs/tables/character_strengths_scaled_indices.csv`
- `outputs/tables/character_strengths_pca_summary.csv`
- `outputs/tables/character_strengths_partial_correlations.csv`
- `outputs/tables/character_strengths_network_centrality.csv`
- `outputs/tables/character_strengths_network_edges.csv`
- `outputs/tables/character_strengths_bootstrap_centrality.csv`
- `outputs/figures/character_strengths_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, employment tools, moral rankings, school-ranking tools, screening tools, disciplinary tools, benefits tools, or individual assessments.
