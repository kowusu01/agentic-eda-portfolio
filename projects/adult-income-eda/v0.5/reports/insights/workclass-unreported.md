---
id: workclass-unreported
title: "Unreported employer type marks a distinct working population, not unemployment"
phase: anomaly
priority: 2

narrative:
  short_form: "The 1,836 respondents with unreported workclass work real hours (mean 31.9/week, none at zero) and are not unemployed — their 10.4% >$50K rate marks them as a distinct, lower-earning-but-working population rather than a data artifact."
  long_form: |
    The natural first guess for "employer type unreported" is "not currently in the labor force" — but this dataset's own extraction criteria already required hours-per-week > 0 for every row, so a genuinely non-working respondent could not appear at all. Checked directly: the 1,836 workclass-unreported respondents report a mean of 31.9 hours per week, and not one of them reports zero hours. They are working real hours and either declined to specify, or the survey could not resolve, what kind of employer they have. Their income profile (10.4% >$50K) is closer to Never-worked/Without-pay (both near 0%, though on tiny samples of 7 and 14) than to Private (21.9%) — a distinct labor-market position, not simply "unemployed."

evidence:
  - role: primary
    caption: "Share earning >$50K by workclass, with the unreported group highlighted"
    numeric: { unreported_n: 1836, unreported_mean_hours: 31.9, unreported_pct_above_50k: 10.4, private_pct_above_50k: 21.9, never_worked_pct: 0, without_pay_pct: 0 }
    chart_ref: data/processed/workclass_income_rank.parquet
  - role: supporting
    caption: "workclass missingness is structurally tied to occupation missingness, not scattered"
    numeric: { both_na: 1836, workclass_na_total: 1836, occupation_na_total: 1843, extra_occupation_only_na: 7 }

references: []
