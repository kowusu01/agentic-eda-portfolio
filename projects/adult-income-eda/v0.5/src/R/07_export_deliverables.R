# Export standalone figures/tables for use outside the report (slides, email, repo preview).
# These are exported FROM the pipeline, never read back BY the report -- see visual-style.md.
library(tidyverse)
library(arrow)
source("R/style_tokens.R")

charts <- list(
  education_income_trend = "chart_education_trend.rds",
  occupation_income_rank = "chart_occupation_lollipop.rds",
  sex_gap_by_marriage    = "chart_sex_gap.rds",
  workclass_income_rank  = "chart_workclass_rank.rds",
  capital_gain_topcode   = "chart_capital_gain.rds",
  hours_distribution     = "chart_hours_dist.rds"
)
for (nm in names(charts)) {
  p <- readRDS(file.path("data/processed", charts[[nm]]))
  ggsave(file.path("reports/figures", paste0(nm, ".png")), p, width = fig_lg$width, height = fig_lg$height, dpi = 150)
}

tables <- c("tbl_record_count", "tbl_nulls", "tbl_numeric_ranges", "tbl_categorical_levels")
for (nm in tables) {
  read_parquet(file.path("data/processed", paste0(nm, ".parquet"))) %>%
    write_csv(file.path("reports/tables", paste0(nm, ".csv")))
}
cat("Exported", length(charts), "figures and", length(tables), "tables.\n")
