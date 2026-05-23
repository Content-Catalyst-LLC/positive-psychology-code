# Data Dictionary

| Variable | Type | Direction | Description |
|---|---:|---|---|
| `life_satisfaction` | numeric | higher is better | Cognitive evaluation of life as a whole. |
| `positive_affect` | numeric | higher is better | Pleasant affective experience. |
| `negative_affect` | numeric | higher is worse | Unpleasant affective experience; direction-correct before aggregation. |
| `purpose_life` | numeric | higher is better | Direction, meaning, and valued life aims. |
| `personal_growth` | numeric | higher is better | Perceived development, learning, and growth. |
| `autonomy` | numeric | higher is better | Agency, self-direction, and self-endorsed action. |
| `positive_relations` | numeric | higher is better | Supportive, warm, and meaningful relationships. |
| `accomplishment` | numeric | higher is better | Goal progress, mastery, and effective agency. |
| `health_index` | numeric | higher is better | Synthetic health and functional-capacity indicator. |
| `contextual_support` | numeric | higher is better | Social, institutional, material, and environmental support for flourishing. |
| `stress_load` | numeric | higher is worse | Cumulative strain, insecurity, and stress burden. |

## Measurement-quality variables

| Variable | Description |
|---|---|
| `reliability_evidence` | Synthetic strength of internal consistency, stability, or measurement precision evidence. |
| `validity_evidence` | Synthetic strength of construct, criterion, convergent, or discriminant validity evidence. |
| `cultural_comparability` | Synthetic evidence that measure travels responsibly across groups or contexts. |
| `temporal_sensitivity` | Synthetic evidence that measure can detect meaningful change over time. |
| `use_validity` | Synthetic evidence that measure is appropriate for the proposed use context. |
| `overall_measurement_quality` | Transparent average-like summary used for teaching; not a real validation score. |

## Indicator-bank variables

- `hed1` to `hed3`: hedonic indicators, with `hed3` representing negative affect and requiring direction correction.
- `eud1` to `eud3`: eudaimonic indicators.
- `rel1` to `rel2`: relational indicators.
- `acc1` to `acc2`: accomplishment/effective-agency indicators.
- `health1` to `health2`: health-capacity indicators.
- `context1` to `context2`: contextual-support indicators.
- `strain1` to `strain2`: cumulative-strain indicators, where higher is worse.
