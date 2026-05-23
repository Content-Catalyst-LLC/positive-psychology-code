# Data Dictionary

| Variable | Type | Direction | Description |
|---|---:|---|---|
| `meaning` | numeric | higher is better | Sense of meaning, purpose, and coherence. |
| `relationships` | numeric | higher is better | Supportive relationships and relational embeddedness. |
| `optimism` | numeric | higher is better | Future-oriented positive expectation, interpreted cautiously. |
| `resilience` | numeric | higher is better | Adaptive capacity under stress, not a substitute for reducing harm. |
| `income_security` | numeric | higher is better | Material security and reduced precarity. |
| `institutional_trust` | numeric | higher is better | Trust in public systems, fairness, and institutional responsiveness. |
| `inequality_exposure` | numeric | higher is worse | Exposure to unequal burden, exclusion, or structural disadvantage. |
| `stress_load` | numeric | higher is worse | Cumulative strain from insecurity, overload, trauma, or social pressure. |
| `cultural_fit` | numeric | higher is better | Conceptual and lived fit between well-being measures/interventions and cultural context. |
| `environmental_quality` | numeric | higher is better | Environmental conditions supporting health, safety, and future flourishing. |
| `applied_uptake` | numeric | higher means more uptake | Degree to which a construct is adopted in applied/public settings. |
| `retained_nuance` | numeric | higher is better | Degree to which scientific nuance is preserved during applied use. |
| `commercial_pressure` | numeric | higher is worse | Degree of market/productivity pressure attached to a construct. |
| `distortion_risk` | numeric | higher is worse | Risk that a construct is simplified, instrumentalized, or misused. |

## Indicator-bank variables

The `critique_indicator_bank.csv` file includes synthetic item-level indicators:

- `meaning1` to `meaning3`: meaning/purpose indicators;
- `rel1` to `rel3`: relationship indicators;
- `agency1` to `agency3`: agency/optimism/resilience indicators;
- `structure1` to `structure3`: structural security indicators;
- `culture1` to `culture3`: cultural fit indicators;
- `stress1` to `stress3`: stress-load indicators, where higher is worse.

These item-level variables are designed for reliability, dimensional inspection, and teaching examples.
