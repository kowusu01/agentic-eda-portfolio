---
id: income-prevalence
title: "24.1% Earn Over $50K — Selective at the Individual Level, Even If Not at the Household Level"
phase: distribution
priority: 3

narrative:
  short_form: "24.1% of this sample earned over $50,000 in 1994 — a threshold that sat below the top quintile of household income but well above median earnings for either sex at the individual level, which is the dataset's own unit."
  long_form: |
    24.1% of this sample earned over $50,000 in 1994 — close to, though not identical to, the 24.78%
    figure `adult.names` reports for the "without unknowns" subset of the full combined file. Read
    against real 1994 figures rather than the dataset's own documentation: the Census Bureau's
    published household top-quintile (80th-percentile) income threshold for 1994 was $62,841,
    meaning a $50K threshold sat comfortably below the top 20% of households, not at some extreme
    tail. But this dataset's income label is at the individual level, a genuinely different unit than
    household income, and the closer individual-level benchmark makes $50K look far more selective:
    median 1994 earnings for full-time, year-round workers were $31,609 for men and $23,261 for
    women — so an individual clearing $50K was earning well above the median for either sex, not
    merely an upper-middle household.

evidence:
  - role: primary
    caption: "Income label prevalence in this 32,561-row sample"
    numeric: { pct_over_50k: 24.1, pct_at_or_under_50k: 75.9 }
    chart_ref: data/processed/chart_income_prevalence.rds
  - role: supporting
    caption: "1994 household top-quintile threshold vs. individual median earnings by sex"
    numeric: { household_top_quintile_1994_usd: 62841, median_earnings_men_1994_usd: 31609, median_earnings_women_1994_usd: 23261 }
    chart_ref: null

references:
  - source: "U.S. Census Bureau, Current Population Reports P60-189"
    citation: "Income, Poverty, and Valuation of Noncash Benefits: 1994"
    type: government
    note: "1994 household median income and the report this report's household-income framing is drawn from."
  - source: "U.S. Census Bureau Historical Income Tables (H-01/H-03), compiled by Tax Policy Center"
    citation: "Household income quintiles, 1994"
    type: government
    note: "Establishes the $62,841 household top-quintile threshold used to contextualize the $50K label."
  - source: "National Center for Education Statistics, Youth Indicators 1996 (sourcing Census CPS)"
    citation: "Median earnings, full-time year-round workers, 1994, by sex"
    type: government
    note: "Individual-level earnings benchmark — the unit that actually matches this dataset's income label."
