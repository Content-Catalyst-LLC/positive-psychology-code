# R Professional Three Good Things Workflow

This workflow is designed for positive psychology intervention and gratitude research methods:

- item-family reliability analysis;
- practice-quality audit summary;
- appreciative-awareness scoring;
- net well-being scoring;
- longitudinal mixed-effects modeling;
- condition × day interaction;
- condition × stress-load interaction;
- condition × reflection-depth interaction;
- condition × context-fit interaction;
- estimated marginal means;
- practice summary tables;
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
Rscript three_good_things_professional_models.R
```

## Scope

This is a synthetic-data scaffold for research workflow demonstration. It is not a validated psychological instrument and must not be used for clinical, crisis-support, employment, public-benefits, or individual decision-making.
