# Phase 3 — Candidate Questions

Generated via structural sweep (Step 1) + Habits of Attention (Step 2), per `references/protocol.md`. Full candidate pool below; selection for the report noted at the bottom with reasons, including reasons for what was *not* selected.

## Step 1 — Structural sweep

### Categorical variables with a plausible relationship to `income`

1. **`education` → `income`.** Monotonic-looking relationship in the raw crosstab (16.0% at HS-grad up to 74.1% at Doctorate). Is there a specific point where the majority crosses from `<=50K` to `>50K`, and how sharp is the crossing?
2. **`marital_status` → `income`.** Strongest categorical association found in Phase 2 (Cramér's V 0.447) — but entangled with age (Phase 2 log). Does the marital-status effect survive when age is held roughly constant, or is it substantially an age proxy?
3. **`sex` → `income`.** Cramér's V 0.216, and raw gap is large: 11.0% of women vs. 30.6% of men earn `>50K`. Phase 0 benchmark needed: does this gap track the real 1994 gender pay/participation gap, or does the dataset's own sex composition (66.9% male, see #7 below) suggest a nonrepresentative sample first?
4. **`race` → `income`.** Weakest of the tested associations (Cramér's V 0.101) but still statistically significant at n=32,561. Worth showing but not overselling given the small effect size and the sample's heavy skew toward `White` (85.4%) diluting the other four categories' precision.
5. **`workclass` → `income`.** Self-employed-incorporated vs. private-sector vs. government — plausible real difference in earnings structure, not yet examined at the category level (only the aggregate chi-sq was run).
6. **`occupation` → `income`.** Not yet examined at the category level; 15 levels, likely to need a ranked/lollipop treatment rather than a crosstab if used.
7. **`native_country` → `income` or → representation.** 89.6% `United-States`, 42 total levels most of which are small. Any question here is more about who's represented at all (composition) than a reliable income comparison — the smaller countries don't have enough rows for a stable per-country income rate.

### Anomalies/surprises already noted in Phase 1/2 — what question do they raise?

8. **Structural missingness in `workclass`/`occupation` (Phase 1).** All 1,836 `workclass`-missing rows are also `occupation`-missing. Who are these ~1,836 people demographically (age, `income` label if present, `hours_per_week`)? Does the pattern look like "not currently working" rather than random non-response?
9. **`native_country` missingness is a separate mechanism from #8 (Phase 2).** Only mentioned as a data-quality nuance so far — not clearly a "question" with a human story, more a caveat. Candidate for a footnote rather than a full question.
10. **`capital_gain` top-coded at 99,999 (159 rows, Phase 2).** Who are the 159 people at the cap — do they skew toward `>50K` overwhelmingly (as top-coded capital gains would suggest), and what does that imply about undercounting the true income spread at the top of the distribution?
11. **`hours_per_week` heaping at 40, and a genuine 80+ hour tail (341 rows, Phase 2).** Two distinct stories bundled in one variable: (a) self-report rounding at the culturally standard "40-hour week," and (b) a small population reporting sustained 80+ hour weeks — who are they, and do they earn more (grinding for income) or not (multiple low-wage jobs)?
12. **3-row `sex`/`relationship` mismatch (`Male`+`Wife`, `Female`+`Husband`) (Phase 2).** Too small to generalize from, but a real instance of people the framing's binary husband/wife role scheme doesn't fit cleanly. A one-line "who this dataset doesn't have a clean box for" note rather than a chart-driving question.
13. **`fnlwgt` shows no relationship to `income` (Phase 2 negative result).** Confirms the framing decision to exclude it from substantive analysis — worth one line in the data-quality section, not a Phase 3 question in its own right.

### Phase 0 external benchmarks — match, diverge, or units-mismatch?

14. **Overall `>50K` prevalence (24.1% in-sample) vs. the real 1994 Census-published income distribution.** Needs Phase 0 figure — pending.
15. **`$50,000` in 1994 dollars vs. 2026 purchasing power.** Needs Phase 0 CPI conversion — pending. Directly shapes how a modern reader should read "24% earned over $50K" — a very different bar in 1994 than in 2026.
16. **Sex composition of the sample (66.9% male) vs. actual 1994 labor force composition.** Needs Phase 0 figure — pending.
17. **Race composition (85.4% White) vs. actual 1994 US population/labor force composition.** Needs Phase 0 figure — pending.

### Variable interactions a domain-knowledgeable reader would expect

18. **`sex` × `occupation`, feeding into `income`.** Phase 2 found `sex` × `occupation` Cramér's V 0.434 — strong occupational segregation by sex. Does the sex income gap (#3) persist *within* the same occupation, or is it substantially explained by which occupations each sex is concentrated in? (This is the single most likely candidate for "what would a high aggregate gap let us ignore that we shouldn't" — occupational segregation vs. within-occupation pay gap are different social stories.)
19. **`age` × `education` compounding on `income`.** Both individually associate with income; does the combination compound (a young highly-educated person vs. an old less-educated one) in a way neither alone predicts?
20. **`relationship` role (`Husband`/`Wife`/`Own-child`/etc.) vs. `income`, independent of raw `sex`.** Household role may carry information beyond sex alone — e.g. is the gap between `Husband` and `Wife` rows different in size from the raw `sex` gap?

## Step 2 — Habits of Attention applied

- **What does this reveal about real people beyond the metric?** #8 (who the ~1,836 missing-employment rows are) and #11 (the 80+ hour tail) both point at real people a simple "predict income" framing would flatten into "missing data" or "outlier" rather than a lived condition (not currently working; working two jobs).
- **What would most analysts smooth over?** #12 (the 3-row sex/relationship mismatch) and #9 (native_country's separate missingness mechanism) are both genuinely footnote-sized, and that's fine — not every noticed thing needs to become a headline finding, but each gets named rather than silently dropped.
- **Who is in this dataset the framing didn't account for?** #12 directly; also relevant to #6/#7 — occupations and countries with too few rows to support a stable estimate are present in the data but effectively invisible to any aggregate statistic.
- **What would high accuracy let us ignore?** #18 is the clearest case — a model could hit good accuracy predicting income while never surfacing that occupational segregation, not just direct pay discrimination, is doing a lot of the explanatory work.

## Step 3/4 — Selected for the report (4–6), with reasons

1. **#1 (education → income, threshold-crossing)** — clean, decision-relevant, textbook case for the threshold-crossing trend line pattern, and grounds the "does education really pay off, and where" question directly in the data's own structure.
2. **#18 (sex × occupation × income)** — most analytically important finding: distinguishes occupational segregation from a flat "men earn more" statement, directly answers a Habit-of-Attention question, and is decision-relevant for anyone using this data to reason about pay equity.
3. **#10 (capital-gain top-coding, who's at the cap)** — most surprising/least obvious finding; a data-quality artifact that turns into a real observation about undercounting income concentration at the top.
4. **#11 (hours-per-week: 40-heaping + 80-hour tail)** — most human-condition-forward finding; two very different stories (rounding artifact vs. a real overwork population) bundled in one variable that a summary stat alone would hide.
5. **#8 (structural missingness in workclass/occupation)** — ties Phase 1's data-quality finding into a real question about who isn't currently working, with direct downstream-modeling relevance (dropping these rows vs. encoding "not in labor force" as its own category are different modeling choices with different implications).
6. **#3 + #14/#16 combined (sex income gap, benchmarked against Phase 0)** — the clearest place Phase 0 grounding actually gets used rather than just mentioned; folds the external benchmark directly into the sex-gap discussion instead of running as a separate question.

**Not selected, with reasons:**
- #2 (marital_status confound) — real and worth a caveat sentence, but marital_status/age/relationship are highly collinear with #20 and #19; selecting all of them would be redundant. Folded into a downstream-implications note rather than its own section.
- #4 (race → income) — smallest effect size of the categorical associations tested; shown as a supporting figure but not built into its own full section, to avoid overstating a Cramér's V of 0.101 as a headline finding.
- #5, #6, #7 (workclass/occupation/native_country level detail), #9, #12, #13, #15 (CPI conversion), #17 (race composition), #19, #20 — genuine candidates, several with real substance (#15 and #17 especially), but the report needs to stay at 4–6 focused sections rather than exhaustively covering every candidate; #9, #12, #13 are folded in as one-line notes elsewhere rather than dropped entirely. #15 and #17 get used as supporting context inside the selected sections above rather than standing alone.
