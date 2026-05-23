# Data Dictionary

| Variable | Type | Direction | Description |
|---|---:|---|---|
| `life_satisfaction` | numeric | higher is better | Cognitive evaluation of life as a whole. |
| `meaning` | numeric | higher is better | Purpose, coherence, and perceived significance. |
| `social_trust` | numeric | higher is better | Trust, belonging, relational security, and perceived social support. |
| `institutional_quality` | numeric | higher is better | Governance reliability, legitimacy, fairness, and public capacity. |
| `environmental_quality` | numeric | higher is better | Environmental condition, exposure, and future-oriented ecological quality. |
| `health_index` | numeric | higher is better | Self-rated or population-level health and functional capability. |
| `resilience_score` | numeric | higher is better | Recovery capacity, adaptive resources, and response to stressors. |
| `stress_load` | numeric | higher is worse | Stressor burden, strain, insecurity, or cumulative pressure. |
| `material_security` | numeric | higher is better | Stability of basic resources and reduced material precarity. |
| `civic_voice` | numeric | higher is better | Participation, agency, and perceived public voice. |

## Item-bank variables

The `future_wellbeing_item_bank.csv` file includes synthetic item-level indicators:

- `ls1` to `ls3`: life satisfaction items;
- `meaning1` to `meaning3`: meaning/purpose items;
- `trust1` to `trust3`: social trust items;
- `health1` to `health3`: health/functioning items;
- `stress1` to `stress3`: stress-load items, higher values indicate more stress.

These item-level variables are designed for reliability, exploratory factor analysis, confirmatory factor analysis, and teaching examples.
