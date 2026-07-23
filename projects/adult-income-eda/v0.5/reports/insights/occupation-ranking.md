---
id: occupation-ranking
title: "The dataset's 14 occupation codes already match the Census Bureau's own 1990 major occupation groups"
phase: domain-question
priority: 2

narrative:
  short_form: "Occupation ranges from 0.7% (Private household service) to 48.4% (Exec-managerial) clearing $50K, and the raw 14-level coding turns out to already be the Census Bureau's own authoritative 13-major-group classification (plus Armed Forces), not an arbitrary scheme needing collapse."
  long_form: |
    Before ranking occupations, it's worth checking whether the raw 14-level occupation field is an arbitrary coding that needs collapsing, or something more principled. It turns out to be the latter: the U.S. Census Bureau's own 1990 occupation classification scheme (Technical Paper 65) groups all civilian employed persons into 13 major occupation groups. This dataset's 14 occupation labels are near-verbatim abbreviations of exactly those 13 groups plus Armed Forces, a clean 1-to-1 correspondence. The field doesn't need an external scheme applied to collapse it — it already is the Census Bureau's own authoritative major-group taxonomy. The spread across these groups is the widest of any categorical variable checked: Executive/managerial and Professional specialty roles clear $50K roughly half the time (48.4% and 44.9%), while Private household service work sits at 0.7% — a 69-fold difference between top and bottom.

evidence:
  - role: primary
    caption: "Share earning >$50K by occupation, ranked, raw 14-level coding"
    numeric: { exec_managerial_pct: 48.4, prof_specialty_pct: 44.9, priv_house_serv_pct: 0.7, ratio_top_to_bottom: 69 }
    chart_ref: data/processed/chart_occupation_lollipop.rds
  - role: supporting
    caption: "1990 Census major occupation group scheme, confirmed to map 1:1 onto this dataset's occupation field"
    numeric: { n_census_major_groups: 13, n_dataset_occupation_levels: 14 }

references:
  - source: "U.S. Census Bureau"
    citation: "The Relationship Between the 1990 Census and Census 2000 Industry and Occupation Classification Systems, Technical Paper 65 (2003), Table 7"
    type: government
    note: "Establishes the 13-major-occupation-group scheme this dataset's occupation field corresponds to; confirms the field is already an authoritative external classification rather than an arbitrary one."
