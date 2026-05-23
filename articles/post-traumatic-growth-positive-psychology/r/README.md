# R Professional Post-Traumatic Growth Workflow

This workflow is designed for PTG and trauma-adjacent positive psychology research methods:

- item-family reliability analysis;
- PTG-domain reliability;
- context-support audit summary;
- integration-index scoring;
- reflective-processing balance scoring;
- growth-distress balance scoring;
- perceived/corroborated growth alignment scoring;
- longitudinal mixed-effects modeling;
- PTG model and distress model estimated separately;
- meaning-making × agency interaction;
- deliberate rumination × narrative integration interaction;
- social support × ongoing stress interaction;
- PTG × distress model for wellbeing;
- estimated marginal means;
- context summary tables;
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
Rscript ptg_professional_models.R
```

## Scope

This is a synthetic-data scaffold for research workflow demonstration. It is not a validated psychological instrument and must not be used for clinical, crisis, employment, school disciplinary, benefits eligibility, legal, insurance, ranking, screening, or individual decision-making.
