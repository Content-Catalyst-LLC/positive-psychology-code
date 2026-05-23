# Data Dictionary

| Variable | Type | Direction | Description |
|---|---:|---|---|
| `life_satisfaction` | numeric | higher is better | Cognitive evaluation of life as a whole. |
| `health_index` | numeric | higher is better | Physical health, functional capability, and self-rated health condition. |
| `social_trust` | numeric | higher is better | Interpersonal trust, community cohesion, and perceived social reliability. |
| `income_security` | numeric | higher is better | Material stability, income adequacy, and reduced financial precarity. |
| `institutional_quality` | numeric | higher is better | Trustworthy public systems, service quality, fairness, and responsiveness. |
| `housing_stability` | numeric | higher is better | Housing security, affordability, safety, and continuity. |
| `education_access` | numeric | higher is better | Access to learning, human development, and educational opportunity. |
| `care_access` | numeric | higher is better | Availability, affordability, dignity, and reliability of health and social care. |
| `environmental_quality` | numeric | higher is better | Environmental safety, exposure reduction, green space, and ecological conditions of health. |
| `stress_load` | numeric | higher is worse | Cumulative strain from insecurity, exposure, overload, trauma, or social pressure. |
| `community_resilience` | numeric | higher is better | Community capacity to adapt, recover, coordinate, and protect vulnerable groups. |

## Indicator-bank variables

The `public_health_indicator_bank.csv` file includes synthetic item-level / indicator-family variables:

- `swb1` to `swb3`: subjective well-being indicators;
- `health1` to `health3`: health/functioning indicators;
- `trust1` to `trust3`: social trust/community cohesion indicators;
- `housing1` to `housing3`: housing stability indicators;
- `care1` to `care3`: care-access indicators;
- `stress1` to `stress3`: cumulative stress-load indicators, where higher is worse.

These variables are designed for reliability, dimensional inspection, and teaching examples.
