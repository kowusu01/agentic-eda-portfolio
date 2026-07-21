---
id: age-income-band
title: "High earners cluster in a mid-career age band — narrower distribution, not just higher median"
phase: distribution
priority: 5

narrative:
  short_form: "High earners have median age 44 (sd=10.5); lower earners median 34 (sd=14.0) — the spread difference reveals that high income is a mid-career phenomenon, not evenly distributed across working years."
  long_form: |
    >$50K earners are older on average (median 44 vs. 34) but also *less variable* in age (sd=10.5
    vs. 14.0 for ≤$50K earners). The narrowing band reflects career-stage dynamics: reaching
    executive, managerial, or professional income typically requires years of education and experience,
    which pushes the high-earner distribution toward the 35–55 range. Below the threshold, the
    distribution stretches younger (entry-level workers, students) and continues across the full
    working life, including lower-wage older workers who never reached high-income roles. Neither of
    these groups drives the sd=14.0 value alone — together they create the broad, right-skewed
    lower-earner age curve visible in the density chart.

evidence:
  - role: primary
    caption: "Age distribution by income group"
    numeric:
      ">50K median age": "44"
      ">50K age sd": "10.5"
      "<=50K median age": "34"
      "<=50K age sd": "14.0"
    chart_ref: data/processed/chart_age_density.rds

references: []
