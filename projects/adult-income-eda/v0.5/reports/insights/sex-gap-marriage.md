---
id: sex-gap-marriage
title: "The aggregate sex income gap is concentrated almost entirely outside marriage"
phase: anomaly
priority: 1

narrative:
  short_form: "Men clear $50K at nearly 3x the rate of women overall (30.6% vs 11.0%), but among married-couple households the gap nearly vanishes (44.6% vs 45.5%) — the aggregate gap is driven by young, unmarried women, not by married women earning less than their husbands."
  long_form: |
    Across the full dataset, men clear $50K at nearly three times the rate of women (30.6% vs. 11.0%) — a large, real gap, and the kind of aggregate figure that would normally anchor a headline. But narrowing to respondents who are married with spouse present collapses that gap almost entirely: 44.6% of married men and 45.5% of married women clear $50K, despite wives in this subgroup working noticeably fewer average hours per week than husbands (36.7 vs. 44.1). The relationship column's Wife category alone (n=1,566) shows a 47.5% rate — fractionally above Husband's 44.9%. This isn't evidence the sex gap is illusory — it's evidence the gap is unevenly distributed. The much larger population of women who are Own-child (1.1% clear $50K; mean age 24.6), Unmarried (4.2%), or Not-in-family (7.3%) is what pulls the aggregate female rate down to 11.0%. Separately, sex shows a strong association with occupation (Cramér's V = 0.434) — women concentrated in Adm-clerical and Other-service, men in Craft-repair and Exec-managerial — a plausible structural channel for the part of the gap that persists outside marriage.

evidence:
  - role: primary
    caption: "Share earning >$50K by sex, all respondents vs. married-couple subpopulation"
    numeric: { all_male_pct: 30.6, all_female_pct: 11.0, married_male_pct: 44.6, married_female_pct: 45.5, wife_pct: 47.5, husband_pct: 44.9 }
    chart_ref: data/processed/sex_gap_by_marriage.parquet
  - role: drill-down
    caption: "Female subpopulation by relationship role: age, education, and income rate"
    numeric: { own_child_pct: 1.1, own_child_mean_age: 24.6, unmarried_pct: 4.2, not_in_family_pct: 7.3 }
  - role: supporting
    caption: "Sex x occupation association strength vs. sex x income"
    numeric: { cramers_v_sex_occupation: 0.434, cramers_v_sex_income: 0.216 }

references: []
