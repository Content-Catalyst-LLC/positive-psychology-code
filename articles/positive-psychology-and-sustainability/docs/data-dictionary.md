# Data Dictionary

| Variable | Type | Direction | Description |
|---|---:|---|---|
| `life_satisfaction` | numeric | higher is better | Cognitive evaluation of life as a whole. |
| `meaning` | numeric | higher is better | Sense of meaning, coherence, and life significance. |
| `purpose` | numeric | higher is better | Future-oriented direction and valued aims. |
| `autonomy` | numeric | higher is better | Agency, self-direction, and perceived freedom under real conditions. |
| `social_trust` | numeric | higher is better | Interpersonal trust and cooperative social confidence. |
| `belonging` | numeric | higher is better | Relational inclusion and social embeddedness. |
| `institutional_quality` | numeric | higher is better | Trustworthy governance, fairness, reliability, and public legitimacy. |
| `public_service_access` | numeric | higher is better | Access to public goods, care, education, infrastructure, and social protection. |
| `ecological_stability` | numeric | higher is better | Environmental viability, ecosystem stability, and climate-safety conditions. |
| `environmental_exposure` | numeric | higher is worse | Heat, pollution, disaster, displacement, or ecological-risk burden. |
| `health_index` | numeric | higher is better | Physical health and functional capacity. |
| `mental_health_index` | numeric | higher is better | Mental-health functioning and psychological stability. |
| `adaptive_capacity` | numeric | higher is better | Capacity to learn, adjust, coordinate, and respond under changing conditions. |
| `insecurity_load` | numeric | higher is worse | Material insecurity, housing precarity, employment instability, and uncertainty burden. |
| `inequality_index` | numeric | higher is worse | Unequal burden and distributional stress. |

## Indicator-bank variables

The `sustainable_flourishing_indicator_bank.csv` file includes synthetic item-level variables:

- `psych1` to `psych4`: psychological functioning indicators;
- `rel1` to `rel2`: relational support indicators;
- `inst1` to `inst2`: institutional capacity indicators;
- `eco1` and `eco2`: ecological condition indicators, where `eco2` is exposure and should be direction-corrected;
- `health1` to `health2`: health-capacity indicators;
- `adapt1` to `adapt2`: adaptive-capacity indicators;
- `strain1` to `strain2`: cumulative strain indicators, where higher is worse.

These variables are designed for reliability, dimensional inspection, and teaching examples.
