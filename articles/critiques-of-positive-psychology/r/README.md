# R Professional Critiques Workflow

This workflow is designed for psychology-facing and critical well-being research methods:

- indicator-family reliability analysis;
- psychological-only model;
- psychological-plus-structural model;
- critique-sensitive flourishing model;
- model comparison using AIC, BIC, and log-likelihood;
- resilience × stress-load interaction;
- institutional trust × income security interaction;
- construct-distortion regression;
- estimated marginal means;
- reproducible table exports.

## Suggested setup

```r
install.packages(c(
  "tidyverse",
  "psych",
  "lme4",
  "lmerTest",
  "broom",
  "broom.mixed",
  "emmeans"
))
```

Run:

```bash
Rscript positive_psychology_critiques_professional_models.R
```

## Scope

This is a synthetic-data scaffold for research workflow demonstration. It is not a validated psychological instrument and must not be used for clinical, employment, public-benefits, or individual decision-making.
