---
id: missing-employment-classification
title: "1,836 People With No Employment Classification Aren't Random — They're Older, Work Fewer Hours, and Earn Less"
phase: anomaly
priority: 2

narrative:
  short_form: "The 5.6% of the sample missing both workclass and occupation earn >$50K at less than half the rate of everyone else, skew older, and average fewer hours — a real, identifiable population, not scattered non-response."
  long_form: |
    The 1,836 people missing both workclass and occupation aren't a random 5.6% slice of the
    sample — they earn >50K at less than half the rate of everyone else (10.4% vs. 24.9%), report
    noticeably fewer average hours worked (31.9 vs. 40.9), and skew toward an older age profile
    (75th-percentile age 61, vs. 47 for the rest of the sample). One caveat worth naming before
    over-interpreting this as "retirees": adult.names states this whole extract was built with an
    hours-per-week > 0 filter, so anyone reporting zero hours would already have been excluded from
    the dataset entirely, and this group's own average of 31.9 hours confirms they're not zero-hour.
    What's left is a genuinely narrower claim than "not in the labor force": a group that is still
    working, on average fewer hours, skewing older, earning >50K far less often, and specifically
    missing a formal employment classification — consistent with irregular, informal, or
    reduced-scale work arrangements (partial retirement, for instance) rather than a clean
    "not working" story. Dropping these 1,836 rows and encoding them as their own category are two
    different modeling choices with different implications, and treating the missingness as noise
    to be imputed away would erase a real, identifiable population rather than a data-quality
    nuisance.

evidence:
  - role: primary
    caption: "Income rate, hours, and age profile: workclass-missing vs. rest of sample"
    numeric: { pct_over_50k_missing: 10.4, pct_over_50k_rest: 24.9, mean_hours_missing: 31.9, mean_hours_rest: 40.9, p75_age_missing: 61, p75_age_rest: 47 }
    chart_ref: data/processed/missing_workclass_summary.rds

references: []
