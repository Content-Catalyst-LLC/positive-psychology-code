# R Professional Measuring-Flourishing Workflow

This workflow is designed for psychometric and well-being research methods:

- item-family reliability analysis;
- hedonic reliability analysis;
- eudaimonic reliability analysis;
- measurement-quality audit summary;
- integrated flourishing composite scoring;
- longitudinal mixed-effects modeling;
- hedonic × eudaimonic interaction;
- support × stress-load interaction;
- estimated marginal means;
- group summary tables;
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
  "performance"
))
```

Run:

```bash
Rscript measuring_flourishing_professional_models.R
```

## Scope

This is a synthetic-data scaffold for research workflow demonstration. It is not a validated psychological instrument and must not be used for clinical, employment, public-benefits, or individual decision-making.
