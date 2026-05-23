# R Professional Character Strengths Workflow

This workflow is designed for character-strengths and positive psychology research methods:

- item-family reliability analysis;
- virtue-cluster reliability;
- character-context audit summary;
- VIA-style virtue-cluster scoring;
- strength-expression scoring;
- civic character and relational character scoring;
- repeated-measures flourishing modeling;
- meaning modeling;
- relationship-quality modeling;
- engagement modeling;
- context-adjusted character/flourishing modeling;
- signature-strength use × contextual support interaction;
- authenticity × institutional suppression interaction;
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
Rscript character_strengths_professional_models.R
```

## Scope

This is a synthetic-data scaffold for research workflow demonstration. It is not a validated psychological instrument and must not be used for clinical, employment, school disciplinary, moral ranking, benefits eligibility, ranking, screening, or individual decision-making.
