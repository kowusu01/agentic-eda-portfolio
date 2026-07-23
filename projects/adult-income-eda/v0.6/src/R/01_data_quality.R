source("R/style_tokens.R")
library(tidyverse)
library(arrow)

# --- Load ---------------------------------------------------------------
col_names <- c("age", "workclass", "fnlwgt", "education", "education_num",
               "marital_status", "occupation", "relationship", "race", "sex",
               "capital_gain", "capital_loss", "hours_per_week",
               "native_country", "income")

raw <- read_csv("data/raw/adult.data", col_names = col_names, na = character(),
                 trim_ws = TRUE, show_col_types = FALSE)

# Frame the data (stated, not silently assumed):
# - Multivariate: 15 relatable columns (14 predictors + income label).
# - Supervised: `income` is a given binary target (<=50K / >50K).
# - Domain structure: fnlwgt is a CPS *sampling weight*, not a demographic
#   attribute. No pack exists in this skill for survey-weighted data yet, so
#   per protocol this is stated plainly rather than guessed at: fnlwgt is
#   treated as a technical/administrative column, excluded from substantive
#   analysis, and every proportion/rate reported in this project is of the
#   *raw sample*, not reweighted to population totals. That's a real caveat,
#   named here and repeated in the report, not silently assumed away.
# No temporal, geospatial-coordinate, or free-text structure otherwise.

cat("Rows loaded:", nrow(raw), "\n")
cat("Cols loaded:", ncol(raw), "\n")

# --- 1. Record count verification ---------------------------------------
# adult.names states: "48842 instances ... (train=32561, test=16281)"
expected_rows <- 32561
record_count_tbl <- tibble(
  item = "Rows",
  expected = expected_rows,
  actual = nrow(raw),
  notes = if (nrow(raw) == expected_rows) "Matches adult.names documentation exactly" else "Mismatch vs documentation — investigate"
)
print(record_count_tbl)

# --- 2. Null / disguised-null presence -----------------------------------
disguised_null_code <- "?"

null_tbl <- raw %>%
  summarise(across(everything(), ~ sum(. == disguised_null_code | is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "n_missing") %>%
  mutate(pct_missing = round(100 * n_missing / nrow(raw), 2)) %>%
  arrange(desc(n_missing))
print(null_tbl, n = Inf)

# --- Duplicate rows (adult.names claims 6 duplicate/conflicting instances
#     across the full 48842-instance adult.all; check within this 32561-row
#     train partition specifically) ---
n_duplicates <- sum(duplicated(raw))
cat("Exact duplicate rows in this file:", n_duplicates, "\n")
cat("(adult.names reports 6 duplicate/conflicting instances across the full",
    "48842-row adult.all; this file is the 32561-row train partition alone.)\n")

# workclass vs occupation missingness: do they co-occur (same people), or
# does occupation go missing more often on its own (e.g. "Never-worked")?
missingness_overlap <- raw %>%
  summarise(
    workclass_missing = sum(workclass == disguised_null_code),
    occupation_missing = sum(occupation == disguised_null_code),
    both_missing = sum(workclass == disguised_null_code & occupation == disguised_null_code),
    occupation_missing_only = sum(occupation == disguised_null_code & workclass != disguised_null_code)
  )
print(missingness_overlap)

# --- 3. Numeric range validation ------------------------------------------
numeric_cols <- c("age", "fnlwgt", "education_num", "capital_gain",
                   "capital_loss", "hours_per_week")

numeric_range_tbl <- raw %>%
  summarise(across(all_of(numeric_cols),
                    list(min = ~min(.), max = ~max(.), mean = ~mean(.),
                         median = ~median(.), nzero = ~sum(. == 0)),
                    .names = "{.col}__{.fn}")) %>%
  pivot_longer(everything(), names_to = c("column", "statistic"), names_sep = "__") %>%
  pivot_wider(names_from = statistic, values_from = value)
print(numeric_range_tbl, n = Inf)

# capital-gain / capital-loss known top-coding check (CPS-era income
# variables were commonly top-coded at a cap for public-use files)
cat("capital_gain top value:", max(raw$capital_gain),
    "| count at that value:", sum(raw$capital_gain == max(raw$capital_gain)), "\n")
cat("capital_loss top value:", max(raw$capital_loss),
    "| count at that value:", sum(raw$capital_loss == max(raw$capital_loss)), "\n")

# --- 4. Categorical level inventory ---------------------------------------
categorical_cols <- c("workclass", "education", "marital_status", "occupation",
                       "relationship", "race", "sex", "native_country", "income")

categorical_inventory <- map_dfr(categorical_cols, function(col) {
  tibble(column = col, n_levels = n_distinct(raw[[col]]))
})
print(categorical_inventory)

# Full level listing per column (saved, not just counted)
categorical_levels_full <- map(set_names(categorical_cols), ~ sort(unique(raw[[.x]])))

# education vs education_num: confirm 1:1 mapping (documentation implies
# education_num is an ordinal encoding of education — verify, don't assume)
education_mapping_check <- raw %>% distinct(education, education_num) %>% arrange(education_num)
print(education_mapping_check, n = Inf)

# --- 5. Unit ambiguity ------------------------------------------------------
# age: years — unambiguous.
# fnlwgt: CPS sampling weight — no natural "unit", excluded from substantive analysis (see above).
# education_num: ordinal years-of-schooling-equivalent — confirmed 1:1 with `education` above.
# capital_gain / capital_loss: dollars. Period is NOT stated in adult.names beyond
#   being drawn from the same 1994 CPS/IRS-linked extract as `income` — treated here
#   as the same annual accounting period as the income label itself, consistent with
#   how capital gains/losses are reported on U.S. tax returns. Stated explicitly
#   rather than silently assumed, since the source docs don't spell it out.
# hours_per_week: stated as such in adult.names — unambiguous, weekly.

# --- Save cleaned Type 1 pipeline intermediate ----------------------------
clean <- raw %>%
  mutate(across(all_of(categorical_cols), ~ na_if(., disguised_null_code))) %>%
  mutate(income = factor(income, levels = c("<=50K", ">50K")))

dir.create("../reports/data/processed", recursive = TRUE, showWarnings = FALSE)
write_parquet(clean, "../reports/data/processed/adult_clean.parquet")

# Save quality-check tables as Type 2 report-facing artifacts
saveRDS(record_count_tbl, "../reports/data/processed/qc_record_count.rds")
saveRDS(null_tbl, "../reports/data/processed/qc_null_tbl.rds")
saveRDS(numeric_range_tbl, "../reports/data/processed/qc_numeric_range.rds")
saveRDS(categorical_inventory, "../reports/data/processed/qc_categorical_inventory.rds")
saveRDS(categorical_levels_full, "../reports/data/processed/qc_categorical_levels_full.rds")

cat("\nPhase 1 complete. Cleaned data + QC tables written to reports/data/processed/\n")
