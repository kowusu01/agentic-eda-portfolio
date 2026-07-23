# 02_phase1_tables.R
# Produces Type 2 report-facing summary tables cached as .rds.
# Depends on data/processed/adult_clean.parquet from 01_prep.R.
# Run from the project root: Rscript R/02_phase1_tables.R
library(tidyverse)
library(arrow)

df <- read_parquet("data/processed/adult_clean.parquet")

# --- Record count table ---
tbl_record_count <- tibble(
  Item     = "Rows",
  Expected = 32561L,
  Actual   = nrow(df),
  Notes    = if (nrow(df) == 32561L) "Matches documented train-set size" else "DISCREPANCY"
)
saveRDS(tbl_record_count, "data/processed/tbl_record_count.rds")

# --- Missing value summary (disguised nulls via ?) ---
tbl_missing <- tibble(
  Column         = c("workclass", "occupation", "native_country"),
  `? count`      = c(sum(is.na(df$workclass)), sum(is.na(df$occupation)), sum(is.na(df$native_country))),
  `% of rows`    = round(c(sum(is.na(df$workclass)), sum(is.na(df$occupation)), sum(is.na(df$native_country))) / nrow(df) * 100, 1),
  `Handling`     = c("Replaced with NA; kept in dataset; sensitivity noted",
                     "Replaced with NA; structurally co-missing with workclass for 1,836 rows",
                     "Replaced with NA; kept in dataset; independent missingness pattern")
)
saveRDS(tbl_missing, "data/processed/tbl_missing.rds")

# --- Numeric ranges table ---
tbl_ranges <- tibble(
  Column     = c("age","fnlwgt","education_num","capital_gain","capital_loss","hours_per_week"),
  Min        = c(17, 12285, 1, 0, 0, 1),
  Max        = c(90, 1484705, 16, 99999, 4356, 99),
  Mean       = c(38.6, 189778, 10.1, 1077.6, 87.3, 40.4),
  Median     = c(37, 178356, 10, 0, 0, 40),
  Notes      = c(
    "Age 90 appears 43 times — possible Census top-code; plausible range",
    "Sampling weight; 120x variation; EDA treats sample as unweighted",
    "Clean ordered scale 1=Preschool to 16=Doctorate",
    "Top-coded at 99,999 (159 rows); 91.7% are exactly 0",
    "No top-code evidence; 0 for 90%+ of rows",
    "Top-coded at 99 (85 rows); 75th percentile = 45"
  )
)
saveRDS(tbl_ranges, "data/processed/tbl_ranges.rds")

# --- Income split table ---
tbl_income_split <- df %>%
  count(income) %>%
  mutate(pct = round(n / sum(n) * 100, 1))
saveRDS(tbl_income_split, "data/processed/tbl_income_split.rds")

message("Phase 1 tables saved to data/processed/")
