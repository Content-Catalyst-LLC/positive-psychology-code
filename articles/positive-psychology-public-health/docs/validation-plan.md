# Validation Plan

This plan is intended for professional research use with real, ethically collected data.

## Data validation

- Confirm data provenance and collection context.
- Confirm scale direction and units.
- Check missingness by region, year, community type, indicator, and domain.
- Evaluate whether missingness is plausibly MCAR, MAR, or MNAR.
- Inspect outliers, impossible values, and subgroup imbalance.
- Document inclusion, exclusion, and transformation rules.

## Indicator validation

- Estimate internal consistency for indicator families where appropriate.
- Inspect correlations among health, well-being, trust, housing, care, education, environment, and stress-load indicators.
- Test dimensional structure using PCA or factor analysis.
- Avoid collapsing indicators when dimensions behave differently.
- Report sensitivity to weighting and penalty choices.

## Model validation

- Compare complete-case, imputed, and sensitivity models.
- Inspect mixed-model residuals and random-effects assumptions.
- Test whether longitudinal trends are robust to regional heterogeneity.
- Bootstrap network centrality and edge stability.
- Avoid causal claims unless the research design supports them.

## Equity and ethical validation

- Disaggregate where data allow and where interpretation is responsible.
- Avoid deficit framing of communities with lower well-being scores.
- Treat low well-being, stress load, housing instability, and care barriers as signals of structural conditions, not individual failure.
- Document privacy, identifiability, and community interpretation limits.
