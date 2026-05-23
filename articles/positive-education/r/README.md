# R Professional Positive Education Workflow

This workflow is designed for educational psychology, school psychology, and positive education research methods:

- item-family reliability analysis;
- implementation-quality audit summary;
- school-flourishing composite scoring;
- longitudinal mixed-effects modeling;
- academic × climate interaction;
- belonging × teacher-support interaction;
- resilience × stress-load interaction;
- access-support × exclusion-exposure interaction;
- estimated marginal means;
- school summary tables;
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
Rscript positive_education_professional_models.R
```

## Scope

This is a synthetic-data scaffold for research workflow demonstration. It is not a validated student measure and must not be used for clinical, disciplinary, ranking, public-benefits, or individual decision-making.
