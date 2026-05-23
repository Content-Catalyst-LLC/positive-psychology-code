# Sustainable Well-Being: Human Flourishing Within Ecological Limits

This companion folder supports the article **“Sustainable Well-Being: Human Flourishing Within Ecological Limits.”** It provides reproducible scaffolding for modeling sustainable well-being as a systems problem involving psychological, social, institutional, ecological, and distributional indicators.

## Purpose

The article argues that durable human flourishing cannot be evaluated apart from ecological limits, institutional quality, social trust, inequality, and intergenerational responsibility. This repository folder provides practical workflows for testing those ideas with transparent, reusable code.

## Scope

The included examples support:

- construction of composite sustainable well-being indicators;
- longitudinal modeling of well-being under ecological and social constraints;
- network analysis across psychological, institutional, and ecological variables;
- data documentation and validation planning;
- reproducible outputs for figures and tables.

## Folder structure

```text
.
├── data/
│   ├── raw/
│   └── processed/
├── docs/
├── methods/
├── notebooks/
├── outputs/
│   ├── figures/
│   └── tables/
├── python/
├── r/
├── sql/
└── validation/
```

## Included workflows

| File | Purpose |
|---|---|
| `python/sustainable_wellbeing_index.py` | Builds a composite index, runs PCA, creates a sparse partial-correlation network, and exports tables/figures. |
| `r/sustainable_wellbeing_model.R` | Fits a longitudinal mixed-effects model using panel-style sustainable well-being indicators. |
| `sql/sustainable_wellbeing_schema.sql` | Defines a clean relational schema for sustainable well-being indicators. |
| `docs/data-dictionary.md` | Documents variables used in the sample workflows. |
| `methods/sustainable-wellbeing-framework.md` | Summarizes the conceptual model behind the article and code. |
| `validation/validation-plan.md` | Provides validation checks for missingness, scaling, indicator balance, and sensitivity. |

## Data notes

The sample CSV files are illustrative and synthetic. They are designed to show workflow structure, not to produce real empirical claims. Replace them with documented, source-traceable data before publication-quality analysis.

## Responsible use

Composite well-being indicators should be interpreted carefully. Weights, penalty terms, and missing-data procedures encode assumptions. Treat the code as a transparent starting point for model design, sensitivity testing, and public-interest analysis.
