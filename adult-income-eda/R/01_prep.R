# 01_prep.R
# Load raw data, apply column names, replace disguised nulls,
# encode ordered factors. Produces the Type 1 cleaned dataset.
# Run from the project root: Rscript R/01_prep.R
library(tidyverse)
library(arrow)

col_names <- c("age", "workclass", "fnlwgt", "education", "education_num",
               "marital_status", "occupation", "relationship", "race", "sex",
               "capital_gain", "capital_loss", "hours_per_week", "native_country", "income")

edu_levels <- c("Preschool", "1st-4th", "5th-6th", "7th-8th", "9th",
                "10th", "11th", "12th", "HS-grad", "Some-college",
                "Assoc-voc", "Assoc-acdm", "Bachelors", "Masters",
                "Prof-school", "Doctorate")

df <- read_csv("data/raw/adult.data",
               col_names    = col_names,
               trim_ws      = TRUE,
               show_col_types = FALSE) %>%
  mutate(
    across(c(workclass, occupation, native_country), ~na_if(., "?")),
    income_bin    = as.integer(income == ">50K"),
    education     = factor(education, levels = edu_levels, ordered = TRUE),
    marital_status = factor(marital_status),
    race          = factor(race),
    sex           = factor(sex),
    workclass     = factor(workclass),
    occupation    = factor(occupation),
    relationship  = factor(relationship),
    # Three-level capital_gain indicator (zero / positive / censored)
    cap_gain_level = case_when(
      capital_gain == 0     ~ "zero",
      capital_gain == 99999 ~ "censored",
      capital_gain > 0      ~ "positive"
    ),
    married = marital_status %in% c("Married-civ-spouse", "Married-AF-spouse")
  )

write_parquet(df, "data/processed/adult_clean.parquet")
message("Saved: data/processed/adult_clean.parquet (", nrow(df), " rows)")
