# Python Professional Workflow

This workflow is designed for psychologists, positive psychology researchers, educational psychologists, cognitive psychologists, creativity researchers, sport psychologists, work and organizational psychologists, human factors researchers, and interdisciplinary teams who need a transparent example of construct reliability, challenge-skill scoring, attentional-ecology scoring, sustainable-flow scoring, attention-context auditing, exploratory network analysis, PCA dimensional inspection, and bootstrap centrality stability checks.

## Suggested setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pandas numpy scikit-learn networkx matplotlib
python flow_professional_workflow.py
```

## Outputs

The script writes:

- `outputs/tables/indicator_family_reliability_report.csv`
- `outputs/tables/attention_context_audit_summary.csv`
- `outputs/tables/flow_scaled_indices.csv`
- `outputs/tables/flow_pca_summary.csv`
- `outputs/tables/flow_partial_correlations.csv`
- `outputs/tables/flow_network_centrality.csv`
- `outputs/tables/flow_network_edges.csv`
- `outputs/tables/flow_bootstrap_centrality.csv`
- `outputs/figures/flow_network.png`

## Method note

Network results are exploratory structural summaries, not causal proof. Composite scores should be interpreted as transparent modeling tools, not clinical tools, employment tools, productivity-surveillance tools, school-ranking tools, screening tools, disciplinary tools, benefits tools, or individual assessments.
