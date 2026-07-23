---
id: capgain-topcode
title: "Capital Gains Top-Coded at Exactly $99,999 — And Every One of Those 159 People Earns Over $50K"
phase: anomaly
priority: 1

narrative:
  short_form: "159 respondents report capital gains at exactly $99,999 — the documented 1988-95 CPS topcode for self-employment/farm income — and literally 100% of them earn >$50K, revealing the income label understates how far above $50K this subgroup actually sits."
  long_form: |
    Only 8.4% of respondents report any nonzero capital gain at all. Within that nonzero population,
    there's a working distribution of gains from a few hundred dollars to about $25,000 — and then a
    distinct spike of 159 people sitting at exactly $99,999. That is not 159 people who happened to
    report the same six-figure gain; it's the documented behavior of Census-era top-coding, where
    public-use files cap high values at a fixed ceiling to protect respondent privacy — confirmed
    directly, not just inferred from the shape of the spike: IPUMS CPS's published topcode tables
    record that 1988-1995 CPS/March ASEC files capped self-employment/farm income at exactly
    $99,999, the identical figure this dataset's capital_gain column tops out at. Checking directly:
    100% of the 159 top-coded respondents earn >50K, and their average age (46.4) runs well above
    the sample average (38.5). The practical implication is real for anyone modeling this data: the
    income label and the capital_gain column both understate how far above $50K this specific
    subgroup actually sits. Any downstream use that treats $99,999 as a real value, rather than a
    censored one, will misestimate this group specifically.

evidence:
  - role: primary
    caption: "Nonzero capital-gain distribution, with the $99,999 top-code called out"
    numeric: { n_at_topcode: 159, pct_at_topcode_over_50k: 100, mean_age_at_topcode: 46.4, mean_age_overall: 38.5 }
    chart_ref: data/processed/chart_capgain_topcode.rds

references:
  - source: "IPUMS CPS (University of Minnesota), topcode tables"
    citation: "CPS/March ASEC topcodes by year and variable, 1988-1995"
    type: academic
    note: "Documents the exact $99,999 self-employment/farm income topcode this dataset's capital_gain values match, confirming the spike is a censoring artifact rather than coincidence."
