# R Professional Well-Being Economics Workflow

This workflow is designed for psychology-facing, economic, and public-policy methods work:

- indicator-family reliability analysis;
- composite well-being economy index;
- longitudinal mixed-effects modeling;
- social trust × institutional quality interaction;
- work quality × care security interaction;
- inequality and time-pressure penalties;
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
  "emmeans"
))
```

Run:

```bash
Rscript economics_of_wellbeing_professional_models.R
```

## Scope

This is a synthetic-data scaffold for research workflow demonstration. It is not a validated psychological instrument and must not be used for clinical, employment, or individual decision-making.
