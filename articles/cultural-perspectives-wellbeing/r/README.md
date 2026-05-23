# R Professional Cross-Cultural Workflow

This workflow is designed for psychology-facing and cross-cultural methods work:

- reliability analysis by group;
- exploratory factor analysis;
- optional confirmatory factor analysis if `lavaan` is installed;
- optional measurement invariance scaffold;
- multilevel mixed-effects modeling;
- random effects for people nested in cultural groups;
- estimated marginal means;
- reproducible table exports.

## Suggested setup

```r
install.packages(c(
  "tidyverse",
  "psych",
  "lme4",
  "lmerTest",
  "broom.mixed",
  "emmeans",
  "lavaan"
))
```

Run:

```bash
Rscript cultural_wellbeing_professional_models.R
```

## Scope

This is a synthetic-data scaffold for research workflow demonstration. It is not a validated psychological instrument and must not be used for clinical, employment, cultural ranking, or individual decision-making.
