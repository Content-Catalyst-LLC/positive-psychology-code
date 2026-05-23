# R Professional Public Health and Positive Psychology Workflow

This workflow is designed for psychology-facing, public-health, and social-determinants methods work:

- indicator-family reliability analysis;
- composite public well-being index;
- longitudinal mixed-effects modeling;
- social trust × institutional quality interaction;
- housing stability × care access interaction;
- community resilience × stress-load interaction;
- stress-load penalty scoring;
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
Rscript positive_psychology_public_health_professional_models.R
```

## Scope

This is a synthetic-data scaffold for research workflow demonstration. It is not a validated psychological instrument and must not be used for clinical, employment, public-benefits, or individual decision-making.
