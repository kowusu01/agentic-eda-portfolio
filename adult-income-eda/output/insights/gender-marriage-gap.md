---
id: gender-marriage-gap
title: "The gender income gap disappears when controlling for marital status — a selection effect, not a pay gap"
phase: anomaly
priority: 2

narrative:
  short_form: "Female 10.9% vs. Male 30.6% raw; among married respondents, Female 45.5% vs. Male 44.6% — the aggregate gap is almost entirely driven by who is in the married-professional category."
  long_form: |
    The raw headline is a 2.8x income gap: women earn >$50K at 10.9%, men at 30.6%.
    Conditioning on marital status nearly eliminates it:
    - Married women: 45.5% earn >$50K
    - Married men: 44.6% earn >$50K (0.9-point difference)
    - Non-married women: 4.6%
    - Non-married men: 8.5%
    The aggregate gender gap is almost entirely a labor-force-participation story. In 1994, married women
    who remained in full-time professional employment were concentrated in exactly the occupations that
    pay above $50K. The large pool of women working part-time, in lower-wage sectors, or with career
    interruptions pulls the aggregate female rate down to 10.9%. What this data cannot say: whether
    women in the same role as men received equal pay — that would require holding occupation and industry
    constant, a conditioning step this cross-sectional sample cannot fully support.

evidence:
  - role: primary
    caption: "Income rate by sex × marital status"
    numeric:
      "Female Married": "45.5%"
      "Female Not married": "4.6%"
      "Male Married": "44.6%"
      "Male Not married": "8.5%"
      "Female aggregate": "10.9%"
      "Male aggregate": "30.6%"
    chart_ref: data/processed/chart_gender_marriage.rds

references: []
