# Adult (Census Income) — Exploratory Data Analysis

An EDA of the UCI "Adult" dataset: 32,561 individual records extracted from the 1994 U.S. Census Bureau Current Population Survey (CPS), with a binary label for whether the respondent's individual income exceeds $50,000/year.

- **Source data:** https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data
- **Codebook:** https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.names

## Questions this analysis answers

1. What does the education–income relationship look like, and exactly where does it cross the point where a majority of people clear $50K?
2. Which occupations are most and least associated with high income, and how does that compare once the 14 raw categories are collapsed using an authoritative external occupation classification?
3. Is the large aggregate income gap between men and women uniform across the dataset, or concentrated in a specific subpopulation?
4. Who are the ~1,836 people with an unreported employer type (`workclass`), and does their condition resemble unemployment or something else?
5. What does the capital-gains column's hard ceiling at $99,999 mean for anyone using this column downstream?
6. Is a $50,000 individual-income threshold a demanding bar to clear in 1994 terms, and does that context explain the dataset's ~24% positive rate?

See `R/candidate_questions.md` for the full candidate pool these were selected from, and `exploration/log.md` for the narrated path that led to them.

## Reproducing this analysis

Requires R (4.6+) and RStudio (for the `.Rproj`, and its bundled Quarto CLI — no standalone Quarto install needed; see Technical Notes in `reports/report.qmd`).

1. Open `adult-income-eda.Rproj` in RStudio (sets the working directory correctly for all relative paths below).
2. `renv::restore()` to install the pinned package versions from `renv.lock`.
3. Run the scripts in `R/` in order to regenerate `data/processed/` from `data/raw/`:
   - `R/01_data_quality.R` — Phase 1 checks; writes the cleaned `data/processed/adult_clean.parquet`
   - `R/02_general_eda.R` — Phase 2 univariate/multivariate checks (console output only)
   - `R/03_targeted_followups.R`, `R/04_wife_anomaly.R` — targeted follow-up queries (console output only)
   - `R/05_charts.R` — builds and caches every chart/table `reports/report.qmd` loads, to `data/processed/`
   - `R/06_quality_tables.R` — caches the Phase 1 data-quality tables
   - `R/07_export_deliverables.R` — exports standalone figures/tables to `reports/figures/` and `reports/tables/` (for use outside the report; not read back by it)
4. Render `reports/report.qmd` (via RStudio's Render button, or `quarto render reports/report.qmd` using the bundled Quarto binary) to produce `reports/report.html`.

## What's in `reports/`

- `report.qmd` / `report.html` — the full narrative EDA report (Introduction through Conclusion; stops before any modeling)
- `figures/` — exported standalone chart images
- `tables/` — exported standalone tables
- `insights/` — one file per distinct finding, each citing its own evidence and (where used) external reference

## Data notes

- `data/raw/adult.data` is the exact 32,561-row train split named in the task. `data/raw/adult.test` (16,281 rows) and `data/raw/adult.names` (codebook) were also pulled from the same UCI directory for reference/documentation but `adult.test` is not used in this analysis.
- The raw file encodes missing values as the literal string `"?"`, not blank/NA — `01_data_quality.R` recodes these to real `NA` before writing the cleaned Parquet file. See `exploration/log.md` for how this was discovered.
