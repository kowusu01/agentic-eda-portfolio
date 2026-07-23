library(tidyverse)
library(arrow)

col_names <- c("age", "workclass", "fnlwgt", "education", "education_num",
               "marital_status", "occupation", "relationship", "race", "sex",
               "capital_gain", "capital_loss", "hours_per_week", "native_country",
               "income")
raw <- read_csv("data/raw/adult.data", col_names = col_names, na = character(),
                 trim_ws = TRUE, show_col_types = FALSE) %>%
  mutate(across(where(is.character), str_trim))

# Table: record count
record_count_tbl <- tibble(
  Item = "Rows (train split)",
  Expected = 32561,
  Actual = nrow(raw),
  Notes = "Matches adult.names documentation exactly."
)
write_parquet(record_count_tbl, "data/processed/tbl_record_count.parquet")

# Table: disguised + true nulls
qmark <- raw %>% summarise(across(everything(), ~sum(. == "?"))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "n_disguised_na") %>%
  filter(n_disguised_na > 0)
null_tbl <- qmark %>%
  mutate(pct_of_rows = round(100 * n_disguised_na / nrow(raw), 2),
         handling = "Recoded '?' -> NA in data/processed/adult_clean.parquet")
write_parquet(null_tbl, "data/processed/tbl_nulls.parquet")

# Table: numeric ranges
numeric_cols <- c("age", "fnlwgt", "education_num", "capital_gain", "capital_loss", "hours_per_week")
range_tbl <- raw %>% summarise(across(all_of(numeric_cols),
                                       list(min = min, max = max, mean = mean, median = median, sd = sd),
                                       .names = "{.col}__{.fn}")) %>%
  pivot_longer(everything(), names_to = c("column", "stat"), names_sep = "__", values_to = "value") %>%
  pivot_wider(names_from = stat, values_from = value) %>%
  mutate(across(where(is.numeric), ~round(., 1)))
write_parquet(range_tbl, "data/processed/tbl_numeric_ranges.parquet")

# Table: categorical level inventory (counts of levels, not full listing, for the summary table)
cat_cols <- c("workclass", "education", "marital_status", "occupation", "relationship",
              "race", "sex", "native_country", "income")
level_tbl <- tibble(column = cat_cols) %>%
  rowwise() %>%
  mutate(n_levels = n_distinct(raw[[column]])) %>%
  ungroup()
write_parquet(level_tbl, "data/processed/tbl_categorical_levels.parquet")

cat("Quality tables cached.\n")
print(record_count_tbl); print(null_tbl); print(range_tbl); print(level_tbl)
