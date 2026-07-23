---
id: capital-gain-topcode
title: "capital_gain is topcoded at 99,999 — a censored ceiling, not a literal value"
phase: anomaly
priority: 3

narrative:
  short_form: "159 rows sit at exactly 99,999 in capital_gain, all labeled >50K — Census-style disclosure-avoidance topcoding, meaning these true values are unknown and only bounded below, not literal dollar figures."
  long_form: |
    capital_gain has a hard ceiling, not a natural tail. 159 of 32,561 rows (0.49% of all rows; 5.9% of the 2,712 rows with any nonzero capital gain) sit at exactly 99,999 — a spike of exact duplicates at the top of the range, not a smoothly thinning tail. That is the signature of Census-style income top-coding: a disclosure-avoidance practice where amounts above a threshold are truncated to one ceiling value rather than published exactly, to prevent re-identifying very-high-income respondents. All 159 topcoded rows carry the >50K label, which is internally consistent but also means a model or statistic that treats 99,999 as a literal dollar figure is misreading it. The true values are unknown, only bounded below. This needs a deliberate decision before any modeling — drop, cap-and-flag, or treat topcoding as its own binary indicator — not silent inclusion as ordinary numeric data.

evidence:
  - role: primary
    caption: "Distribution of nonzero capital_gain values, with the topcode ceiling marked"
    numeric: { n_topcoded: 159, topcode_value: 99999, pct_of_all_rows: 0.49, pct_of_nonzero_rows: 5.9, pct_topcoded_above_50k: 100 }
    chart_ref: data/processed/capital_gain_nonzero.parquet

references: []
