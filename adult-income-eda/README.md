# Adult Income — Exploratory Data Analysis

**Dataset:** UCI Adult / Census Income — 1994 US Current Population Survey extract  
**Language:** R · **Report format:** Quarto HTML  
**Author:** Kwaku Owusu-Tieku · **Date:** 2026-07-20

## What this project is

An exploratory analysis of the [UCI Adult dataset](https://archive.ics.uci.edu/ml/datasets/adult), treating 32,561 CPS respondents not as a machine-learning benchmark but as a cross-section of the 1994 US labor market. The analysis answers three main questions:

1. At which education level does high income (>$50K, ≈$105K in 2024 dollars) become the majority outcome rather than the exception?
2. What does the gender income gap actually look like once marital status is held constant?
3. What does the structure of capital gains reveal about investment access across the income distribution?

Two additional findings are explored: occupational income structure (a 68-point spread) and the narrower mid-career age band of high earners.

## How to reproduce

**Requirements:** R 4.5+, tidyverse 2.0, arrow 14+, ggplot2 3.5+, quarto (for rendering)

```bash
# From the project root:
Rscript R/01_prep.R          # clean raw data → data/processed/adult_clean.parquet
Rscript R/02_phase1_tables.R # quality check tables → data/processed/*.rds
Rscript R/03_charts.R        # all chart objects → data/processed/*.rds + output/figures/*.png
quarto render output/report.qmd
```

The raw data must be present at `data/raw/adult.data` (original source, no header row) and `data/raw/adult.names`. Download from:
- https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data
- https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.names

## What's in output/

| File | What it shows |
|---|---|
| `report.qmd` / rendered HTML | Full EDA narrative with embedded charts |
| `figures/education_income_trend.png` | Income rate by education level (threshold-crossing trend) |
| `figures/gender_marriage_income.png` | Income rate by sex × marital status (2×2 interaction) |
| `figures/occupation_income_ranking.png` | Lollipop ranking of all occupations by income rate |
| `figures/capital_gain_by_income.png` | Capital gain prevalence by income group |
| `figures/age_distribution_by_income.png` | Overlapping age densities by income group |
| `insights/*.md` | One structured finding file per major insight |

## Project structure

```
adult-income-eda/
├── adult-income-eda.Rproj   # RStudio project — opens with correct working directory
├── R/
│   ├── style_tokens.R           # design tokens (fonts, figure sizes, palettes)
│   ├── 01_prep.R                # load + clean raw data → parquet
│   ├── 02_phase1_tables.R       # data quality tables
│   ├── 03_charts.R              # all chart objects
│   └── candidate_questions.md   # full Phase 3 question list with selection reasoning
├── data/
│   ├── raw/                     # original files, untouched
│   └── processed/               # cached intermediates (parquet + rds)
├── exploration/
│   └── log.md                   # iterative EDA journal written during analysis
└── output/
    ├── report.qmd               # the deliverable
    ├── figures/                 # standalone chart exports (PNGs)
    ├── tables/
    └── insights/                # per-finding structured markdown files
```
