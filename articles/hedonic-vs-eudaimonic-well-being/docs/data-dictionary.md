# Data Dictionary

| Variable | Type | Direction | Description |
|---|---:|---|---|
| `life_satisfaction` | numeric | higher is better | Cognitive evaluation of life as a whole. |
| `positive_affect` | numeric | higher is better | Frequency or intensity of pleasant affective experience. |
| `negative_affect` | numeric | higher is worse | Frequency or intensity of unpleasant affective experience. |
| `autonomy` | numeric | higher is better | Self-direction, agency, and self-endorsed action. |
| `personal_growth` | numeric | higher is better | Perceived development, learning, and expansion of capacities. |
| `purpose_life` | numeric | higher is better | Direction, meaning, and future-oriented aims. |
| `positive_relations` | numeric | higher is better | Supportive, warm, and meaningful relationships. |
| `environmental_mastery` | numeric | higher is better | Capacity to navigate and shape life conditions. |
| `self_acceptance` | numeric | higher is better | Acceptance and integration of self and life history. |
| `contextual_support` | numeric | higher is better | Institutional, social, material, and environmental support for well-being. |
| `stress_load` | numeric | higher is worse | Cumulative strain, stress, insecurity, and burden. |
| `flourishing_outcome` | numeric | higher is better | Synthetic global outcome for model demonstration. |

## Indicator-bank variables

The `hedonic_eudaimonic_indicator_bank.csv` file includes synthetic item-level variables:

- `hed1` to `hed3`: hedonic indicators, with `hed3` representing negative affect and requiring direction correction;
- `eud1` to `eud6`: eudaimonic indicators;
- `rel1` to `rel2`: relational indicators;
- `context1` to `context2`: contextual support indicators;
- `strain1` to `strain2`: strain indicators, where higher is worse.

These variables are designed for reliability, dimensional inspection, and teaching examples.
