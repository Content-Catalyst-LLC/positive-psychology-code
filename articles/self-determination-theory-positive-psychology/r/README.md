# R Professional Self-Determination Theory Workflow

This workflow is designed for SDT and motivation-science research methods:

- item-family reliability analysis;
- motivational-climate audit summary;
- need-support and need-balance scoring;
- motivational-quality scoring;
- longitudinal mixed-effects modeling;
- autonomy × relatedness interaction;
- competence × autonomy interaction;
- autonomous motivation × stress-load interaction;
- need balance × domain interaction;
- estimated marginal means;
- domain summary tables;
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
Rscript sdt_professional_models.R
```

## Scope

This is a synthetic-data scaffold for research workflow demonstration. It is not a validated psychological instrument and must not be used for clinical, employment, school disciplinary, public-benefits, ranking, screening, or individual decision-making.
