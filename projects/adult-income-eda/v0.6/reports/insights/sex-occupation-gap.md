---
id: sex-income-gap-within-occupation
title: "The Sex Income Gap Persists Within Nearly Every Occupation, Not Just Across Them"
phase: domain-question
priority: 1

narrative:
  short_form: "Every occupation in the data shows a positive male-minus-female >$50K rate gap (average 16.4pp), nearly as large as the 19.6pp raw sample-wide gap — meaning occupational segregation is not the primary driver of the aggregate disparity."
  long_form: |
    The raw, sample-wide gap — 30.6% of men vs. 11.0% of women earning >50K, a 19.6 percentage-point
    difference — could be explained two very different ways: either men and women are concentrated
    in different occupations that happen to pay differently (a segregation story), or men out-earn
    women within the same occupation (a within-occupation pay-rate story). Checking directly settles
    which one dominates: every single occupation in the data, without exception, shows a positive
    male-minus-female gap (the one near-zero/negative case, Priv-house-serv, is a small,
    94.6%-female occupation with almost no male comparison group). The average within-occupation
    gap is 16.4 percentage points — nearly as large as the 19.6-point raw gap — and the largest
    gaps appear in the higher-paying professional/managerial occupations (Exec-managerial at 34pp,
    Prof-specialty at 31pp), not the lower-paying ones. Occupational segregation by sex is real in
    this data too — women are 5.4% of Craft-repair but 94.6% of Priv-house-serv — but it is not the
    primary driver of the aggregate gap the way a "different jobs, different pay" story alone would
    suggest. This lines up directionally with the real 1994 labor market (a national women's-to-men's
    earnings ratio of roughly 72-77 cents on the dollar through the era), though that's a continuous
    dollar ratio being compared, with an explicit units caveat, against this dataset's binary
    threshold-crossing rate gap — the two aren't directly equatable, only checked for pointing the
    same direction.

evidence:
  - role: primary
    caption: "Male-minus-female >$50K rate gap, by occupation, ranked"
    numeric: { overall_gap_pp: 19.6, avg_within_occupation_gap_pp: 16.4, exec_managerial_gap_pp: 33.9, prof_specialty_gap_pp: 30.8 }
    chart_ref: data/processed/chart_occ_gap.rds
  - role: supporting
    caption: "Occupational segregation by sex — share female, most vs. least segregated occupations"
    numeric: { craft_repair_pct_female: 5.4, priv_house_serv_pct_female: 94.6 }
    chart_ref: data/processed/occ_sex_share.rds

references:
  - source: "BLS/Census CPS earnings series, as summarized by Econlib's Encyclopedia of Economics"
    citation: "Women's-to-men's earnings ratio, early-to-mid 1990s"
    type: government
    note: "National ~72-77% earnings-ratio benchmark used, with an explicit units caveat, to check directional consistency against this dataset's binary income-gap finding."
