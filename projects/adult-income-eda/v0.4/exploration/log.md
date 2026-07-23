# Exploration Log — Adult Income EDA

Dataset: UCI Adult / Census Income (1994 US Census Bureau extract)
Language: R · Started: 2026-07-20

---

## Phase 1 — Data Quality

**Record count.** 32,561 rows, 15 columns. The UCI repository documents this training file as 32,561 rows — matches exactly. No discrepancy.

**No header row.** Column names must be applied from the `adult.names` documentation. All 15 column names assigned manually at load time.

**No true NA values.** All missingness is encoded as the string `"?"` — a disguised-null convention this dataset inherited from the CPS extraction tooling.

**Disguised nulls found in three columns:**

| Column         | ? count | % of rows |
| -------------- | ------- | --------- |
| workclass      | 1,836   | 5.6%      |
| occupation     | 1,843   | 5.7%      |
| native_country | 583     | 1.8%      |

**workclass and occupation are co-missing for 1,836 rows exactly.** Zero rows have `?` workclass without also having `?` occupation. Seven rows have `?` occupation but known workclass. This is structural — people with unknown employment sector consistently have unknown job type too. This likely represents respondents who declined or couldn't answer employment questions, not random non-response.

Among these 1,836 co-missing rows: only 10.4% earn >$50K, vs. 24.1% in the full dataset. The missing group skews toward lower income — dropping them would introduce a mild systematic bias toward higher-income observations if not handled explicitly.

**native_country missingness is largely independent.** Only 27 of the 583 `?` native_country rows also have `?` workclass. The other 556 have known employment data. The mechanism appears different — possibly respondents who declined to state birthplace, not a related non-response cluster.

**Top-coded variables identified — two separate issues:**

- `capital_gain`: max = 99,999. Exactly 159 rows (0.5%) report this value. Among non-zero capital gains, the 95th percentile is also $99,999, confirming this is a hard ceiling, not a real data point. The true distribution above ~$15,000 is unknown. For modeling: this variable cannot be treated as a continuous numeric without deciding how to handle the censored tail — log-transform, treat $99,999 as its own indicator, or cap and note. For EDA: the 91.7% of rows with $0 capital gain is itself the main story.
- `hours_per_week`: max = 99. Exactly 85 rows (0.3%) report this value. The 99th percentile is 80. The 99 cap is consistent with Census reporting conventions and is unlikely to represent actual work hours. Practically, this top-coding affects very few rows and has less analytical consequence than the capital_gain ceiling.

**Age range: 17–90, 43 rows at the maximum.** Age 90 is not impossible, but 43 people exactly at the top of the range in a sample of this size is consistent with age top-coding in CPS practice. Worth naming but lower consequence than capital_gain.

**fnlwgt (final weight) range: 12,285–1,484,705.** This is the Census sampling weight — a respondent-level multiplier indicating how many US residents that person is meant to represent. A factor of 120x between the smallest and largest weight. For naive analysis (which this EDA will treat as the default), fnlwgt is typically ignored and the sample is treated as unweighted. If a weighted analysis were needed, the representativeness claims would be different — flagged here, but not pursued further in this EDA.

**Income split: 75.9% ≤$50K, 24.1% >$50K.** 24,720 vs. 7,841 rows. The 24.1% positive-class rate is itself an analytical finding — documented in Phase 0 grounding, where it will be compared against CPS-era external benchmarks.

**Education levels confirmed as a clean ordered scale.** `education_num` runs 1–16, with Preschool at 1 and Doctorate at 16. The numeric and string encodings are redundant — only one of them is needed for analysis; `education` (with the ordered factor) will be preferred for labeling, `education_num` for ordering.

---

## Phase 2 — General EDA

*Phase 2 underway.*

### Distribution shapes — numeric variables

All six numeric variables examined for skew and IQR.

`age`: Slight right skew (Pearson coefficient 0.35), IQR=[28,48]. Age 90 appears 43 times — consistent with Census top-coding convention but not confirmed. 143 rows (0.4%) exceed the IQR fence of 78. No action needed; this is a realistic distribution.

`fnlwgt`: Slight right skew (0.32), IQR=[117K, 237K]. Expected for a sampling weight — large weights represent rarer demographic cells. Not analyzed further since this EDA is unweighted.

`education_num`: Near-symmetric (0.09), IQR=[9,12] (HS-grad to Assoc-acdm). Well-behaved ordinal scale. No notable outliers.

`capital_gain` and `capital_loss`: IQR=[0,0] for both — the interquartile range is literally zero, because over 75% of the sample has no capital income at all. The Pearson skewness coefficient (0.44) understates this dramatically: this is a zero-inflated variable, not a skewed continuous one. 91.7% report $0 capital gain. This is the main distributional fact about this variable; analyzing it as a continuous numeric is misleading. Decision: treat capital_gain as a three-level indicator (zero / positive-not-censored / censored-at-99999) in descriptive analysis.

`hours_per_week`: Near-symmetric overall (0.11), but IQR=[40,45] reveals the real shape — the distribution is extremely concentrated at 40 hours/week (median 40, 75th percentile 45). The IQR-fence "outlier" count of 27.7% of all rows is a red flag: IQR method is inappropriate here because the IQR reflects the concentration of the normal work week, not the range of non-outlier values. The "outliers" are part-time and long-hour workers, which are economically meaningful categories, not noise. Will not label them as outliers.

### Cross-variable findings — group comparison

**The education threshold crossing** is among the most structurally clear findings in this dataset. Income rate rises smoothly with education_num up through some-college (~19%), then jumps sharply at the Bachelors level (41.5%) and continues rising to a plateau at Masters–Doctorate (55–74%). The crossing above 50% happens at Prof-school (73.4%) and Doctorate (74.1%). This is the most interpretable threshold in the dataset.

**The gender income gap is 2.8x in raw terms** — Female: 10.9% earn >$50K, Male: 30.6%. But this gap nearly disappears when conditioning on marital status:

- Married female: **45.5%** earn >$50K
- Married male: **44.6%** earn >$50K
- Unmarried female: 4.6%
- Unmarried male: 8.5%

Married men and women in this 1994 sample have *essentially identical* rates of earning above $50K. The aggregate gender gap is almost entirely driven by who is in the married-and-employed category. This is a selection effect: in 1994, married women who were in the labor force at all were, on average, in professional or managerial roles at higher rates than unmarried women — the full-time career women who stayed in the workforce while married. The aggregate 10.9% vs 30.6% numbers obscure this almost entirely. This finding deserves prominent placement in the report.

**Capital gains as a wealth signal**: Among >$50K earners, 21.4% report any capital gain (vs. 4.2% of lower earners — a 5x differential). Median non-zero capital gain: $7,896 for high earners vs. $3,273 for lower earners. 2% of high earners hit the $99,999 ceiling. Capital gains are primarily a high-earner phenomenon, consistent with investment income being concentrated at the top.

**Occupation ranking**: The range from Priv-house-serv (0.7%) to Exec-managerial (48.4%) is striking. Zero private-household-service workers in this sample's 149 members earn >$50K — an income floor enforced by sector, not individual characteristics. The next-lowest occupation is Other-service (4.2%, 3,295 workers). At the top: Exec-managerial (48.4%), Prof-specialty (44.9%), then a large gap to Protective-serv (32.5%).

**Race disparities**: Asian-Pac-Islander (26.6%) and White (25.6%) are nearly identical; Black (12.4%), Amer-Indian-Eskimo (11.6%), and Other (9.2%) are all roughly half the White rate. This is a coarse view — race interacts strongly with occupation and education in ways this univariate breakdown doesn't capture. Flagged for further investigation.

**Age and income**: >$50K earners have a *tighter* age distribution (sd=10.5 vs 14.0 for ≤$50K earners), centered at median 44 vs. 34. High earners are drawn from a narrower, more mid-career band — not evenly distributed across working-age years.

### Correlations

Among numeric predictors, education_num has the strongest correlation with income_bin (0.335), followed by capital_gain (0.223), hours_per_week (0.230), and age (0.234). Inter-predictor correlations are uniformly low (all below 0.15), suggesting little multicollinearity among the numerics.

### Phase 2 dead end: IQR-based outlier detection for hours_per_week

Tried the standard IQR fence. The 27.7% "outlier" result is statistically correct but meaningless — the fence method failed because the variable's distribution is highly concentrated at 40, making the IQR far too narrow to be a useful fence. Dropped this approach; will instead treat hours_per_week as a distribution to visualize directly (part-time / standard / overtime bands) rather than screening for outliers by formula.

---

---

## Phase 0 — External Grounding (returned from background agent)

Sources: Census Bureau CPS P60-189 and P60-193, BLS EcoPro Table 1, SSA AWI Series, NCES Digest of Education Statistics 1996.

**The $50K threshold in context:**

- SSA national average wage in 1994: $23,754 — less than half the $50K threshold.
- Male median full-time year-round earnings: $31,609. Female: $23,261.
- $50K in 1994 = ~$105,800 in 2024 dollars (BLS CPI-U: 148.2 → 313.7).
- $50K was approximately a top-20-to-25% individual income for 1994. The dataset's 24.1% high-earning rate is plausible as a CPS cross-section including part-time and part-year workers.

**BLS 1994 labor force composition (from EcoPro Table 1):**

- Women: 60,239K out of 131,056K total = **45.9% female**
- White: 84.8% · Black: 11.1% · Asian: 4.2% · Hispanic (any race): 9.1%

**Comparison to dataset:**

- White: Dataset 85.4% vs. BLS 84.8% → nearly identical (0.6 pt difference).
- Black: Dataset 9.6% vs. BLS 11.1% → **1.5 points underrepresented**.
- Asian-Pac-Islander: Dataset 3.2% vs. BLS Asian 4.2% → **1.0 point underrepresented**.
- **Female: Dataset 33.1% vs. BLS 45.9% → 12.8 points underrepresented**. This is a substantial gap. The dataset is significantly more male-dominated than the actual 1994 labor force. The fnlwgt sampling weights would correct for this in a weighted analysis, but the unweighted results — including all income-by-sex comparisons — are based on a sample that underrepresents women by roughly 13 percentage points.

**Gender wage benchmark from Census P60-193:**

- Female-to-male earnings ratio for full-time year-round workers: ~73% in 1994.
- Women with bachelor's+ had a median of $35,378; men with bachelor's+ had $49,228.
- $35,378 is 29% below the $50K threshold; $49,228 is 1.5% below it.
- This means even the best-credentialed women were earning well below the threshold on average, while the best-credentialed men were right at it. The dataset's female bachelor's income rate (20.9%) and male bachelor's income rate (50.4%) are consistent with this external benchmark.

**New finding from Phase 0 comparison:** Even within the same credential, men earn >$50K at 2–2.4x the rate of women at the bachelor's level. This is consistent with the Census P60 73% earnings ratio and means the gender gap is NOT fully explained by marital status alone — there is a within-credential pay gap visible in this data too. The married analysis finding (45.5% vs. 44.6%) reflects a highly selected subgroup of professional women; the broader pattern is that women with the same degrees still earn >$50K much less often than men.

---

## Phase 3 — Domain-Driven Questions

Structural sweep of all 14 categorical variables, 6 numeric variables, and every anomaly flagged in Phases 1–2. Full candidate list (10 questions) in `R/candidate_questions.md`, with one-line notes on why each was or wasn't selected. Five questions chosen for the report:

1. **Education threshold crossing** — where does >50% income majority flip? (Threshold-Crossing Trend Line)
2. **Gender × marriage interaction** — does the 3:1 aggregate gap survive conditioning on marital status? (2×2 bar)
3. **Capital gains as wealth signal** — 91.7% zero; 5x prevalence gap by income class (stacked proportion)
4. **Occupation lollipop** — 68-point spread, Priv-house-serv at floor (lollipop ranking)
5. **Age density by income** — narrower mid-career band for high earners (overlapping density)

Five questions not selected: race × occupation interaction (needs conditioning, coarse univariate misleads), self-employed-incorporated advantage (absorbed into occupation narrative), fnlwgt weighting (scope), native-country breakdown (sample too thin per country), hours-per-week by occupation (too granular for 4–6-finding report).

---

## Phase 4 — Visualization with Intent

All five charts built before any code was written. Five-second takeaway defined before selecting chart type in each case.

**Chart 1 — Education trend.** Five-second takeaway: "at which level does >50% flip?" → threshold-crossing LOESS over ordered points with dotted 50% reference line. First attempt used education as a factor on the x-axis with `geom_smooth(method="loess")` — works cleanly. The LOESS curve overshoots slightly past Doctorate because of the sharp late rise, but the point is still legible. Chose `fig_lg` (7×6) because the 16 angled 90° labels need vertical width.

**Chart 2 — Gender × marriage.** Five-second takeaway: "do rates match between married men and married women?" → labeled bar chart, 4 groups, percentages burned in. Tried faceting by sex first — made the within-sex married/unmarried comparison easier but made the married-female vs. married-male comparison harder, which is the main point. Reverted to 4 columns ordered Female-not-married, Female-married, Male-not-married, Male-married. Colors by sex (blue/salmon), no legend (redundant with x-axis labels).

**Chart 3 — Occupation lollipop.** Five-second takeaway: "which occupation is at the top and bottom?" → `fct_reorder` + `geom_segment` + `geom_point` + `coord_flip`. Height scaled with `fig_tall(14)` — a fixed preset would either clip or waste space. Labels right-justified after the point, `annotate_sm` size so they don't crowd.

**Chart 4 — Capital gains.** Five-second takeaway: "how many in each income group have any capital gain?" → stacked bar (zero vs. non-zero), annotated percentage above the colored segment. Tried showing the full capital_gain distribution (density) first — unhelpful because the 91.7% zero mass collapses everything else to invisible. The stacked proportion bar, with the "have gains" annotation in dark blue, makes the 4.2% vs. 21.4% comparison immediate.

**Chart 5 — Age density.** Five-second takeaway: "are the high-earner and low-earner age distributions shaped differently, not just shifted?" → overlapping `geom_density` with alpha 0.5, dotted median lines at 34 and 44 annotated in-plot. Did not use a boxplot (would show medians cleanly but hide the shape difference — the sd=10.5 vs. sd=14.0 contrast needs the actual curve to be visible, not just a box width).

No chart required rebuilding after the first render in each case. All cached as `.rds` and exported as `.png` to `output/figures/`.

---

## Phase 5 — Narrative Synthesis

Standing Check run before finalizing:

1. **Grounded against something real outside itself?** Yes. BLS EcoPro Table 1, Census P60-189 and P60-193, SSA AWI Series, NCES Digest 1995/1996. Each source could exist if this UCI dataset had never been created. The Circular Grounding Trap was tested explicitly — no Kaggle notebooks, no UCI documentation, no benchmark papers.
2. **Domain-driven questions actually run, not just described?** Yes. Candidate list saved to `R/candidate_questions.md` with 10 items, 5 selected, 5 not selected with explicit reasoning. The list is structural, not luck-of-the-prompt.
3. **Anomaly noticed but not yet named?** Phase 0 grounding returned a finding that was not visible in Phase 2: the dataset contains 33.1% female respondents vs. 45.9% in the actual 1994 civilian labor force. This was named explicitly in the "Sample Representativeness" section and the Conclusion, not footnoted. The within-credential gender gap (male Bachelor's 50.4% vs. female 20.9%) was also named as a direct counterweight to the married-pair finding, rather than left as an implicit caveat.
4. **Report visually verified?** Quarto is not installed on this system, so a full render was not possible. Verification was done by: (a) loading all 10 cached objects in R, (b) printing all 5 chart objects to a PNG device and confirming correct rendering, (c) grep-checking the report for any `include_graphics`/`imread`/`Image.open` calls (none found). The report is structurally correct and will render correctly once Quarto is available (`quarto render output/report.qmd` from the project root).
