---
id: external-benchmark-1994
title: "$50,000 individual income was an elite threshold in 1994, well above typical full-time earnings"
phase: domain-question
priority: 1

narrative:
  short_form: "1994 median full-time year-round male earnings were $30,854 (women $22,205) — so a $50K individual threshold was far more demanding than the ~top-30%-of-households framing a naive household-income comparison would suggest."
  long_form: |
    Grounding this dataset's own 24.08% positive rate requires two things: an independent 1994-era income benchmark, and care about which income unit is being compared. The U.S. Census Bureau's Income, Poverty, and Valuation of Noncash Benefits: 1994 puts median household income at $32,264 in 1994, and Historical Income Tables put the fourth-quintile boundary at $62,841 — so $50,000 in household income fell inside the top 30% of households. But this dataset's outcome is individual, not household, income. Census Table P-38 puts 1994 median annual earnings for full-time, year-round male workers at $30,854, and for women at $22,205 — the median full-time male earner didn't clear $31,000. Against that backdrop, $50,000 in individual annual income in 1994 was a genuinely elite threshold. This reframes the dataset's 24% positive rate: it reflects this dataset's own extraction filters (working adults with hours-per-week > 0 and positive income) selecting a population skewed toward higher earners, not evidence that a quarter of 1994 America cleared $50K individually. The same unit-matching caution applies to the sex gap (30.6% vs 11.0% here vs. Census P-38's 72.0% female-to-male earnings ratio) and the race gap (White 25.6% vs Black 12.4% here vs. Census H-5's 61.8% Black-to-White household median income ratio) — both external comparisons confirm direction, not magnitude, since they're different statistics (threshold-crossing rate vs. median ratio) at different income units (individual vs. household). A White/Black comparison alone also understates this dataset's own pattern: Asian-Pac-Islander respondents clear $50K at 26.6%, fractionally above the White rate of 25.6%, while Amer-Indian-Eskimo (11.6%) and Other (9.2%) sit closer to the Black rate — a simple "White vs. non-White" binary would misrepresent it.

evidence:
  - role: primary
    caption: "1994 median household income and quintile breakpoints vs. individual median earnings by sex"
    numeric: { median_household_income_1994: 32264, quintile4_boundary: 62841, median_male_ft_earnings_1994: 30854, median_female_ft_earnings_1994: 22205, per_capita_income_1994: 16555 }
  - role: supporting
    caption: "Dataset's own threshold-crossing rates vs. external median-ratio benchmarks (direction-only comparison)"
    numeric: { dataset_positive_rate: 24.08, dataset_sex_gap_male_pct: 30.6, dataset_sex_gap_female_pct: 11.0, census_female_to_male_earnings_ratio_1994: 72.0, dataset_race_gap_white_pct: 25.6, dataset_race_gap_black_pct: 12.4, census_black_to_white_household_ratio_1994: 61.8 }
  - role: drill-down
    caption: "Full race breakdown, showing the binary White/non-White framing doesn't hold for this dataset"
    numeric: { white_pct: 25.6, asian_pac_islander_pct: 26.6, black_pct: 12.4, amer_indian_eskimo_pct: 11.6, other_pct: 9.2 }

references:
  - source: "U.S. Census Bureau"
    citation: "Income, Poverty, and Valuation of Noncash Benefits: 1994, Current Population Reports P60-189 (April 1996)"
    type: government
    note: "Median household income for 1994."
  - source: "U.S. Census Bureau"
    citation: "Historical Income Tables: Households, Table H-1"
    type: government
    note: "1994 household income quintile breakpoints, used to place $50K in the household income distribution."
  - source: "U.S. Census Bureau"
    citation: "Historical Income Tables: People, Table P-38"
    type: government
    note: "1994 median individual annual earnings by sex for full-time, year-round workers — the individual-income benchmark this dataset's threshold is compared against."
  - source: "U.S. Census Bureau"
    citation: "Historical Income Tables: Households, Table H-5"
    type: government
    note: "1994 household median income by race, used for direction-only comparison against this dataset's race gap."
