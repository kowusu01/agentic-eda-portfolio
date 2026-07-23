# Adult / Census Income — Exploratory Data Analysis

An EDA of the UCI "Adult" dataset: a 32,561-row extract from the U.S. Census Bureau's 1994 Current
Population Survey, where each row is one working-age adult described by demographic and
employment attributes, labeled with whether their annual income was above or below $50,000.

**Source data:** https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data
(documentation: `adult.names`, same directory).

## What this analysis answers

1. At what education level does earning over $50K become the *majority* outcome?
2. Does the sex gap in `>50K` rates persist within the same occupation, or is it mostly explained
   by occupational segregation?
3. What does the $99,999 capital-gains top-code reveal about the people who hit it?
4. Does working more hours keep paying off at the extreme end? And who is missing an employment
   classification entirely?

See `reports/report.qmd` (or the rendered `reports/report.html`) for the full narrative, findings,
and supporting charts.

## Project layout

```
src/                  analysis code — independently reproducible, own R environment (renv)
  adult-income-eda.Rproj
  renv.lock              pinned package versions for the analysis code
  R/
    01_data_quality.R      Phase 1 — data quality checks, writes cleaned Parquet to reports/
    02_general_eda.R       Phase 2 — univariate/multivariate statistical checks
    03_targeted_followups.R  Phase 3 — targeted numbers behind the report's selected findings
    04_charts.R             Phase 4 — builds and caches all report charts
    candidate_questions.md   full Phase 3 candidate question pool, with selection reasoning
    style_tokens.R           shared chart styling tokens (copy 1 of 2)
  data/raw/               original adult.data / adult.names / adult.test, untouched
  exploration/
    log.md                  narrated exploratory journey — what was tried, what it showed, why
                             it led to the next step (including dead ends)

reports/              the deliverable — self-contained, no reference back into src/
  report.qmd              the narrative report (Quarto)
  report.html              rendered output
  renv.lock                pinned package versions for rendering the report
  manifest.json             deployment manifest (rsconnect)
  styles/style_tokens.R    shared chart styling tokens (copy 2 of 2)
  data/processed/          cached cleaned dataset (Parquet) + cached chart objects/tables (.rds)
  insights/                one file per finding, with evidence and references
  figures/, tables/        exported standalone assets (not read back by the report)
```

## Reproducing this analysis

**Requirements:** R (this project was built and rendered under R 4.6.1), the `renv` package, and
[Quarto](https://quarto.org/) available on `PATH` (or bundled with RStudio, at
`RStudio.app/Contents/Resources/app/quarto/bin/quarto` on macOS).

1. From `src/`, run `renv::restore()` to install the pinned analysis-code dependencies.
2. From `src/`, run the four scripts in `R/` in order:
   ```r
   source("R/01_data_quality.R")
   source("R/02_general_eda.R")
   source("R/03_targeted_followups.R")
   source("R/04_charts.R")
   ```
   Each writes its outputs directly into `reports/data/processed/` (the cleaned dataset, QC
   tables, and cached chart objects the report reads back).
3. From `reports/`, run `renv::restore()` to install the pinned report-rendering dependencies,
   then `quarto render report.qmd` to produce `report.html`.

`src/exploration/log.md` has the full narrated journey behind these scripts, including a couple of
real dead ends (a naming bug in the numeric-range summary, a caching gotcha around loading `.rds`
chart objects without the packages that built them). `src/R/candidate_questions.md` has every
domain-driven question considered in Phase 3, not just the 4–6 that made the final report.

## Notes on this analysis

- All proportions/rates in this report describe the 32,561-row sample as collected — `fnlwgt`
  (the Census sampling weight) is excluded from substantive analysis and nothing here is
  reweighted to population totals. See `reports/report.qmd`'s "Reading the Data" section.
- This is a 1994 dataset. `$50,000` in 1994 is roughly $111,000–$113,000 in 2026 dollars — see the
  report's Conclusion for the full inflation and representativeness context.
