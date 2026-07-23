# Phase 1 -- Data Quality Checks
library(tidyverse)

col_names <- c("age", "workclass", "fnlwgt", "education", "education_num",
               "marital_status", "occupation", "relationship", "race", "sex",
               "capital_gain", "capital_loss", "hours_per_week", "native_country",
               "income")

raw <- read_csv("data/raw/adult.data", col_names = col_names, na = character(),
                 trim_ws = TRUE, show_col_types = FALSE)

cat("Raw row count:", nrow(raw), "\n")
cat("Raw col count:", ncol(raw), "\n\n")

# trim whitespace on character columns (source data has leading spaces after commas)
raw <- raw %>% mutate(across(where(is.character), str_trim))

cat("=== Record count check ===\n")
cat("Documented (train split, adult.names): 32561\n")
cat("Actual read:", nrow(raw), "\n\n")

cat("=== Disguised nulls ('?') per column ===\n")
qmark_counts <- raw %>% summarise(across(everything(), ~sum(. == "?"))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "n_question_mark") %>%
  filter(n_question_mark > 0)
print(qmark_counts)
cat("\n")

cat("=== True NA per column ===\n")
na_counts <- raw %>% summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "n_na")
print(na_counts, n = 30)
cat("\n")

cat("=== Numeric range validation ===\n")
numeric_cols <- c("age", "fnlwgt", "education_num", "capital_gain", "capital_loss", "hours_per_week")
ranges <- raw %>% summarise(across(all_of(numeric_cols),
                                    list(min = min, max = max, mean = mean, median = median, sd = sd),
                                    .names = "{.col}__{.fn}")) %>%
  pivot_longer(everything(), names_to = c("column", "stat"), names_sep = "__", values_to = "value") %>%
  pivot_wider(names_from = stat, values_from = value)
print(ranges, n = 30)
cat("\n")

cat("=== capital_gain / capital_loss zero & cap check ===\n")
cat("capital_gain == 0:", sum(raw$capital_gain == 0), "/", nrow(raw), "\n")
cat("capital_gain == max (", max(raw$capital_gain), "):", sum(raw$capital_gain == max(raw$capital_gain)), "\n")
cat("capital_loss == 0:", sum(raw$capital_loss == 0), "/", nrow(raw), "\n")
cat("capital_loss == max (", max(raw$capital_loss), "):", sum(raw$capital_loss == max(raw$capital_loss)), "\n\n")

cat("=== Categorical level inventory ===\n")
cat_cols <- c("workclass", "education", "marital_status", "occupation", "relationship",
              "race", "sex", "native_country", "income")
for (cc in cat_cols) {
  cat("--", cc, "( n_levels =", n_distinct(raw[[cc]]), ") --\n")
  print(raw %>% count(.data[[cc]], sort = TRUE))
  cat("\n")
}

cat("=== education vs education_num consistency ===\n")
print(raw %>% distinct(education, education_num) %>% arrange(education_num))
cat("\n")

cat("=== Duplicate rows ===\n")
cat("Exact duplicate rows:", sum(duplicated(raw)), "\n\n")

cat("=== income label formatting ===\n")
print(raw %>% count(income))

# write cleaned Type-1 parquet artifact
dir.create("data/processed", showWarnings = FALSE)
raw_clean <- raw %>%
  mutate(across(where(is.character), ~na_if(., "?"))) %>%
  mutate(income = str_remove(income, "\\.$"),
         income = factor(income, levels = c("<=50K", ">50K")))
arrow::write_parquet(raw_clean, "data/processed/adult_clean.parquet")
cat("\nWrote data/processed/adult_clean.parquet with", nrow(raw_clean), "rows\n")
