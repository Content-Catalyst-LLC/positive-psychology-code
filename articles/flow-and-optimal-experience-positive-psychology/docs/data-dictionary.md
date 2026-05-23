# Data Dictionary

| Variable | Type | Direction | Description |
|---|---:|---|---|
| `domain` | categorical | n/a | Applied setting such as education, creative work, sport, technical work, health training, or digital work. |
| `challenge_level` | numeric | context-dependent | Task difficulty, complexity, novelty, stakes, or cognitive demand. |
| `skill_level` | numeric | higher is more skill | Current competence, training, self-efficacy, or capability relevant to the task. |
| `attention_focus` | numeric | higher is better | Degree of sustained focus and concentration during the activity. |
| `feedback_quality` | numeric | higher is better | Clarity, immediacy, usefulness, and corrective value of task feedback. |
| `goal_clarity` | numeric | higher is better | Degree to which the person knows what the activity requires. |
| `task_meaning` | numeric | higher is better | Perceived value, significance, identity fit, or purpose of the activity. |
| `autonomy_support` | numeric | higher is better | Degree of agency, choice, self-endorsement, and meaningful control. |
| `distraction_load` | numeric | higher is worse | Notification burden, competing demands, noise, surveillance pressure, or attentional friction. |
| `interruption_count` | numeric | higher is worse | Count or indexed frequency of interruptions during an activity/session. |
| `flow_score` | numeric | higher is more flow | Synthetic flow or optimal-experience score. |
| `performance_score` | numeric | higher is better | Performance, quality, task completion, or expert-rated output. |
| `learning_gain` | numeric | higher is better | Synthetic within-session or between-session learning improvement. |
| `fatigue_score` | numeric | higher is worse | Fatigue, depletion, overload, or post-session strain. |
| `recovery_quality` | numeric | higher is better | Rest, restoration, recovery, boundaries, and post-engagement replenishment. |
| `wellbeing_score` | numeric | higher is better | Synthetic well-being or flourishing outcome score. |

## Attention-context audit variables

| Variable | Description |
|---|---|
| `goal_clarity_support` | Whether the setting gives clear goals and task structure. |
| `feedback_quality_support` | Whether feedback is timely, useful, non-punitive, and skill-building. |
| `challenge_calibration` | Whether challenge is adjusted to skill and development. |
| `skill_development_support` | Whether the setting supports practice, training, coaching, and mastery. |
| `attention_protection` | Whether the setting protects uninterrupted deep engagement. |
| `autonomy_support_quality` | Whether people retain agency and meaningful control. |
| `distraction_control` | Whether notifications, interruptions, surveillance, and context switching are minimized. |
| `recovery_support` | Whether rest, boundaries, and human limits are protected. |
| `privacy_safeguards` | Protection for attention, performance, engagement, and productivity data. |
| `anti_surveillance_review` | Review of whether flow or attention data could be misused for surveillance or coercion. |
| `overall_context_quality` | Transparent average-like summary used for teaching; not a validated score. |

## Indicator-bank variables

- `challenge1` to `challenge2`: challenge indicators.
- `skill1` to `skill2`: skill indicators.
- `attention1` to `attention2`: attention focus indicators.
- `feedback1` to `feedback2`: feedback quality indicators.
- `clarity1` to `clarity2`: goal clarity indicators.
- `meaning1` to `meaning2`: task meaning indicators.
- `autonomy1` to `autonomy2`: autonomy support indicators.
- `distraction1` to `distraction2`: distraction indicators, where higher is worse.
- `flow1` to `flow2`: flow indicators.
- `performance1` to `performance2`: performance indicators.
- `fatigue1` to `fatigue2`: fatigue indicators, where higher is worse.
- `recovery1` to `recovery2`: recovery indicators.
- `wellbeing1` to `wellbeing2`: well-being indicators.
