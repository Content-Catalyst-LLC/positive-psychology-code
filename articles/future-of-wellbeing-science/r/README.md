# R Professional Psychometrics Workflow

This workflow is designed for psychology-facing methods work:

- reliability analysis;
- exploratory factor analysis;
- optional confirmatory factor analysis if `lavaan` is installed;
- longitudinal mixed-effects modeling;
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
Rscript future_wellbeing_professional_psychometrics.R
```

## Scope

This is a synthetic-data scaffold for research workflow demonstration. It is not a validated psychological instrument and must not be used for clinical, employment, or individual decision-making.
