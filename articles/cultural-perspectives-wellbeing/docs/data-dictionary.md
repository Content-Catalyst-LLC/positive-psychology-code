# Data Dictionary

| Variable | Type | Direction | Description |
|---|---:|---|---|
| `life_satisfaction` | numeric | higher is better | Cognitive evaluation of life as a whole. |
| `social_support` | numeric | higher is better | Perceived relational support, belonging, and available help. |
| `income_security` | numeric | higher is better | Material security and reduced precarity. |
| `relational_harmony` | numeric | higher is better | Harmony, reciprocity, family/community balance, and relational fit. |
| `institutional_trust` | numeric | higher is better | Trust in public institutions, fairness, and social reliability. |
| `cultural_orientation` | numeric | context dependent | Synthetic continuum indicating more relational/interdependent orientation at higher values. |
| `autonomy_value` | numeric | context dependent | Value placed on self-direction, personal choice, and self-expression. |
| `harmony_value` | numeric | context dependent | Value placed on relational balance, duty, respect, and social harmony. |
| `civic_voice` | numeric | higher is better | Participation, public voice, institutional responsiveness, and agency. |
| `cultural_continuity` | numeric | higher is better | Continuity of cultural practice, language, memory, identity, and intergenerational transmission. |
| `place_attachment` | numeric | higher is better | Belonging, land/place relation, ecological connection, and rootedness. |

## Item-bank variables

The `cultural_wellbeing_item_bank.csv` file includes synthetic item-level indicators:

- `wb1` to `wb3`: general well-being / life evaluation items;
- `rel1` to `rel3`: relational harmony items;
- `inst1` to `inst3`: institutional trust items;
- `cult1` to `cult3`: cultural continuity / cultural fit items;
- `place1` to `place3`: place attachment items.

These item-level variables are designed for reliability, exploratory factor analysis, optional confirmatory factor analysis, and measurement-invariance teaching examples.
