# R Professional Gratitude Workflow

This workflow is designed for gratitude, relationship, and positive psychology research methods:

- item-family reliability analysis;
- gratitude-practice quality audit summary;
- appreciative-orientation scoring;
- relational-support scoring;
- net well-being scoring;
- longitudinal mixed-effects modeling;
- condition × wave interaction;
- gratitude × support interaction;
- gratitude × stress-load interaction;
- expression × relationship-quality interaction;
- condition × intervention-fit interaction;
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
  "performance"
))
```

Run:

```bash
Rscript gratitude_professional_models.R
```

## Scope

This is a synthetic-data scaffold for research workflow demonstration. It is not a validated psychological instrument and must not be used for clinical, crisis-support, employment, school disciplinary, public-benefits, or individual decision-making.
