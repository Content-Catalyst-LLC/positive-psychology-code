# R Professional PERMA Workflow

This workflow is designed for PERMA and multidimensional flourishing research methods:

- item-family reliability analysis;
- PERMA profile reliability;
- institutional-quality reliability;
- context audit summary;
- PERMA index scoring;
- PERMA profile-balance scoring;
- institutional-quality scoring;
- context-adjusted flourishing scoring;
- repeated-measures flourishing modeling;
- life-satisfaction modeling;
- institutional support and barrier moderation;
- estimated marginal means;
- setting summary tables;
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
Rscript perma_professional_models.R
```

## Scope

This is a synthetic-data scaffold for research workflow demonstration. It is not a validated psychological instrument and must not be used for clinical, employment, school disciplinary, benefits eligibility, ranking, screening, or individual decision-making.
