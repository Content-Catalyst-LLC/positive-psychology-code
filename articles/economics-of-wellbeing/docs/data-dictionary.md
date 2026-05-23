# Data Dictionary

| Variable | Type | Direction | Description |
|---|---:|---|---|
| `income_security` | numeric | higher is better | Material stability, income adequacy, savings buffer, and reduced financial precarity. |
| `life_satisfaction` | numeric | higher is better | Cognitive evaluation of life as a whole. |
| `health_index` | numeric | higher is better | Health and functional capability. |
| `social_trust` | numeric | higher is better | Interpersonal trust, social cohesion, and cooperative confidence. |
| `institutional_quality` | numeric | higher is better | Governance capacity, legitimacy, public reliability, and fairness. |
| `environmental_quality` | numeric | higher is better | Environmental condition and future-oriented ecological viability. |
| `inequality_index` | numeric | higher is worse | Inequality, unequal burden, and distributional stress. |
| `work_quality` | numeric | higher is better | Dignity, stability, autonomy, safety, and meaning in work. |
| `care_security` | numeric | higher is better | Availability, affordability, reliability, and dignity of care systems. |
| `time_pressure` | numeric | higher is worse | Time scarcity, overwork, commuting burden, schedule volatility, and recovery pressure. |
| `public_services` | numeric | higher is better | Reliability and access to public goods, health, education, housing support, transport, and social protection. |

## Indicator-bank variables

The `economics_of_wellbeing_indicator_bank.csv` file includes synthetic item-level / indicator-family variables:

- `mat1` to `mat3`: material security indicators;
- `swb1` to `swb3`: subjective well-being indicators;
- `inst1` to `inst3`: institutional quality indicators;
- `work1` to `work3`: work-quality indicators;
- `care1` to `care3`: care-security indicators.

These variables are designed for reliability, dimensional inspection, and teaching examples.
