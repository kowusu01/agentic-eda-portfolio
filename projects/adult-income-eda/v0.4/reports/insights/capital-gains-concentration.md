2---
id: capital-gains-concentration
title: "Capital gains are nearly invisible below $50K income — a five-fold prevalence gap signals investment access stratification"
phase: distribution
priority: 4

narrative:
  short_form: "91.7% of the sample has $0 capital gain; among >$50K earners, 21.4% have any capital gain vs. 4.2% of lower earners — investment income is a high-earner phenomenon."
  long_form: |
    Capital gains in this dataset form a zero-inflated distribution: 91.7% of all respondents report $0,
    7.8% report a positive non-censored amount, and 0.5% hit the $99,999 Census reporting ceiling.
    Among >$50K earners, the capital-gain prevalence is 21.4% — five times the 4.2% rate among <=50K
    earners. The median non-zero gain is $7,896 for high earners and $3,273 for lower earners.
    2% of high earners hit the $99,999 top-code (suggesting actual gains potentially far higher).
    This pattern reveals that wage income and investment income co-occur at the top of the distribution —
    people who have cleared the wage threshold are also, at much higher rates, earning from investments.
    The capital_gain variable cannot be used as a simple continuous predictor in any downstream model
    without deciding how to handle the 91.7% zero mass and the censored upper tail.

evidence:

- role: primary
  caption: "Any capital gain prevalence by income group"
  numeric:
  "<=50K: any gain": "4.2%"
  ">50K: any gain": "21.4%"
  "All rows: $0 capital gain": "91.7%"
  ">50K: at ceiling ($99,999)": "2.0%"
  "<=50K median non-zero gain": "$3,273"
  ">50K median non-zero gain": "$7,896"
  chart_ref: data/processed/chart_capital_gain.rds

references: []
