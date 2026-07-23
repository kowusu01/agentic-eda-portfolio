# Phase 2 -- General EDA (univariate + multivariate checks)
library(tidyverse)
library(arrow)
source("R/style_tokens.R")

df <- read_parquet("data/processed/adult_clean.parquet")

cat("=== Missingness pattern: are workclass and occupation NA on the same rows? ===\n")
miss_tab <- df %>% mutate(wc_na = is.na(workclass), occ_na = is.na(occupation)) %>%
  count(wc_na, occ_na)
print(miss_tab)
cat("workclass NA count:", sum(is.na(df$workclass)), " occupation NA count:", sum(is.na(df$occupation)), "\n")
cat("Rows where BOTH are NA:", sum(is.na(df$workclass) & is.na(df$occupation)), "\n")
cat("Rows where workclass NA but occupation NOT NA:", sum(is.na(df$workclass) & !is.na(df$occupation)), "\n\n")

cat("=== workclass = 'Never-worked' cross-check against occupation NA ===\n")
print(df %>% filter(workclass == "Never-worked") %>% count(occupation))
cat("\n")

cat("=== native_country NA -- scattered or concentrated? ===\n")
cat("Rows with native_country NA that ALSO have workclass/occupation NA:",
    sum(is.na(df$native_country) & is.na(df$workclass)), "of", sum(is.na(df$native_country)), "\n\n")

cat("=== Univariate: distribution shape + outliers (IQR method) for numeric columns ===\n")
numeric_cols <- c("age", "fnlwgt", "education_num", "capital_gain", "capital_loss", "hours_per_week")
for (nc in numeric_cols) {
  x <- df[[nc]]
  q1 <- quantile(x, .25); q3 <- quantile(x, .75); iqr <- q3 - q1
  lo <- q1 - 1.5*iqr; hi <- q3 + 1.5*iqr
  n_out <- sum(x < lo | x > hi)
  skewness <- (mean(x) - median(x)) / sd(x)
  cat(sprintf("-- %s: mean=%.1f median=%.1f sd=%.1f | IQR outliers: %d (%.1f%%) | mean-median skew index: %.3f\n",
              nc, mean(x), median(x), sd(x), n_out, 100*n_out/length(x), skewness))
}
cat("\n")

cat("=== capital_gain zero-inflation ===\n")
cat("Proportion exactly zero:", round(mean(df$capital_gain == 0), 4), "\n")
cat("Among nonzero capital_gain, proportion at the 99999 ceiling:",
    round(mean(df$capital_gain[df$capital_gain > 0] == 99999), 4), "\n\n")

cat("=== Multivariate: group comparison (mean/std) of numeric vars by income ===\n")
for (nc in numeric_cols) {
  tab <- df %>% group_by(income) %>% summarise(mean = mean(.data[[nc]]), sd = sd(.data[[nc]]), .groups="drop")
  cat("--", nc, "--\n"); print(tab)
}
cat("\n")

cat("=== Multivariate: numeric-numeric correlation ===\n")
cor_mat <- df %>% select(all_of(numeric_cols)) %>% cor()
print(round(cor_mat, 3))
cat("\n")

cat("=== Multivariate: categorical-categorical association (chi-square) ===\n")
assoc_pairs <- list(
  c("sex", "income"),
  c("race", "income"),
  c("workclass", "income"),
  c("marital_status", "income"),
  c("sex", "occupation"),
  c("race", "native_country")
)
for (pr in assoc_pairs) {
  tab <- table(df[[pr[1]]], df[[pr[2]]])
  test <- suppressWarnings(chisq.test(tab))
  cat(sprintf("%s x %s: chi-sq=%.1f, df=%d, p=%.2e, Cramer's V=%.3f\n",
              pr[1], pr[2], test$statistic, test$parameter, test$p.value,
              sqrt(test$statistic / (sum(tab) * (min(dim(tab)) - 1)))))
}
cat("\n")

cat("=== Income rate by sex (proportion, per pattern-library guidance) ===\n")
print(df %>% group_by(sex) %>% summarise(n = n(), pct_above_50k = round(100*mean(income == ">50K"), 2)))
cat("\n")
cat("=== Income rate by race ===\n")
print(df %>% group_by(race) %>% summarise(n = n(), pct_above_50k = round(100*mean(income == ">50K"), 2)))
cat("\n")
cat("=== Income rate by workclass ===\n")
print(df %>% group_by(workclass) %>% summarise(n = n(), pct_above_50k = round(100*mean(income == ">50K"), 2)) %>% arrange(desc(pct_above_50k)))
cat("\n")
cat("=== Income rate by education (ordered) ===\n")
print(df %>% group_by(education, education_num) %>% summarise(n=n(), pct_above_50k = round(100*mean(income == ">50K"),2), .groups="drop") %>% arrange(education_num))
cat("\n")
cat("=== Income rate by hours worked bucket ===\n")
print(df %>% mutate(hrs_bucket = cut(hours_per_week, breaks=c(0,20,35,40,50,60,100), include.lowest=TRUE)) %>%
  group_by(hrs_bucket) %>% summarise(n=n(), pct_above_50k = round(100*mean(income==">50K"),2)))
cat("\n")
cat("=== Income rate by native_country: US vs non-US ===\n")
print(df %>% mutate(is_us = ifelse(native_country == "United-States", "US", "non-US")) %>%
  filter(!is.na(is_us)) %>% group_by(is_us) %>% summarise(n=n(), pct_above_50k = round(100*mean(income==">50K"),2)))
cat("\n")
cat("=== Age distribution by income group (verify shape difference) ===\n")
print(df %>% group_by(income) %>% summarise(min=min(age), p25=quantile(age,.25), median=median(age), p75=quantile(age,.75), max=max(age)))
