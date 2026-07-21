---
id: education-threshold
title: "Bachelor's degree is the inflection point — income majority requires a professional degree"
phase: trend
priority: 1

narrative:
  short_form: "Income rate stays below 20% at every sub-bachelor's level, then jumps to 41.5% at Bachelors and 73-74% at Prof-school/Doctorate — a threshold shape, not a gradient."
  long_form: |
    Education is the strongest numeric predictor of income in this dataset (r=0.335 with the binary outcome).
    Below HS-grad, income rates range from 0% (Preschool) to 7.6% (12th grade). HS-grad: 16%.
    Some-college: 19%. Then a sharp discontinuity: Bachelors: 41.5%. Masters: 55.7%.
    The majority threshold (>50%) is crossed only at Prof-school (73.4%) and Doctorate (74.1%).
    The associate degrees (Assoc-voc: 26.1%, Assoc-acdm: 24.8%) occupy a middle position —
    meaningfully above high school, but well below the bachelor's step change.

evidence:
  - role: primary
    caption: "Income rate by education level (ordered lowest to highest)"
    numeric:
      Preschool: "0.0%"
      HS-grad: "16.0%"
      Bachelors: "41.5%"
      Masters: "55.7%"
      Prof-school: "73.4%"
      Doctorate: "74.1%"
    chart_ref: data/processed/chart_edu_trend.rds

references:
  - source: "UCI Adult dataset, 1994 CPS extract"
    citation: "data/raw/adult.data"
    type: government
    note: "All proportions computed directly from this dataset; no external benchmark applied to the education-income gradient itself."
