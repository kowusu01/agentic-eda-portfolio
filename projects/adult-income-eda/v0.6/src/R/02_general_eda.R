source("R/style_tokens.R")
library(tidyverse)
library(arrow)

clean <- read_parquet("../reports/data/processed/adult_clean.parquet")

numeric_cols <- c("age", "fnlwgt", "education_num", "capital_gain",
                   "capital_loss", "hours_per_week")
categorical_cols <- c("workclass", "education", "marital_status", "occupation",
                       "relationship", "race", "sex", "native_country")

# ============================================================
# UNIVARIATE — distribution shape + outlier characterization
# ============================================================

cat("\n=== Distribution shape (skew) ===\n")
skew_fn <- function(x) {
  m <- mean(x); s <- sd(x)
  mean(((x - m) / s)^3)
}
dist_shape_tbl <- clean %>%
  summarise(across(all_of(numeric_cols), list(skew = skew_fn), .names = "{.col}"))  %>%
  pivot_longer(everything(), names_to = "column", values_to = "skewness") %>%
  mutate(interpretation = case_when(
    abs(skewness) < 0.5 ~ "roughly symmetric",
    skewness >= 0.5 & skewness < 1 ~ "moderate right skew",
    skewness >= 1 ~ "strong right skew",
    skewness <= -0.5 ~ "left skew"
  ))
print(dist_shape_tbl)

cat("\n=== Outlier characterization (IQR rule, per column) ===\n")
outlier_tbl <- map_dfr(numeric_cols, function(col) {
  x <- clean[[col]]
  q1 <- quantile(x, .25); q3 <- quantile(x, .75); iqr <- q3 - q1
  lo <- q1 - 1.5 * iqr; hi <- q3 + 1.5 * iqr
  tibble(column = col, q1 = q1, q3 = q3,
         n_outliers = sum(x < lo | x > hi),
         pct_outliers = round(100 * sum(x < lo | x > hi) / length(x), 2),
         outlier_hi_bound = hi)
})
print(outlier_tbl)

cat("\n=== Missingness pattern: native_country ===\n")
# Is native_country missingness structural (tied to another variable) or scattered?
nc_missing_by_workclass <- clean %>%
  mutate(nc_missing = is.na(native_country)) %>%
  count(nc_missing, workclass_missing = is.na(workclass)) %>%
  pivot_wider(names_from = workclass_missing, values_from = n, names_prefix = "workclass_missing_")
print(nc_missing_by_workclass)

# ============================================================
# MULTIVARIATE
# ============================================================

cat("\n=== Income prevalence (own-sample, unweighted) ===\n")
income_prevalence <- clean %>% count(income) %>% mutate(pct = round(100 * n / sum(n), 2))
print(income_prevalence)

cat("\n=== Group comparison: numeric vars by income (mean/std four-quadrant) ===\n")
group_comparison_tbl <- clean %>%
  group_by(income) %>%
  summarise(across(all_of(numeric_cols), list(mean = ~mean(.), sd = ~sd(.)), .names = "{.col}__{.fn}")) %>%
  pivot_longer(-income, names_to = c("column", "stat"), names_sep = "__") %>%
  pivot_wider(names_from = c(income, stat), values_from = value, names_sep = "_")
print(group_comparison_tbl, width = Inf)

cat("\n=== Numeric-numeric correlation ===\n")
corr_mat <- clean %>% select(all_of(numeric_cols)) %>% cor(use = "complete.obs") %>% round(3)
print(corr_mat)

cat("\n=== Categorical-categorical association (chi-square) ===\n")
assoc_pairs <- list(
  c("sex", "income"),
  c("race", "income"),
  c("marital_status", "income"),
  c("workclass", "income"),
  c("sex", "relationship"),
  c("sex", "occupation")
)
assoc_tbl <- map_dfr(assoc_pairs, function(p) {
  tab <- table(clean[[p[1]]], clean[[p[2]]])
  test <- suppressWarnings(chisq.test(tab))
  tibble(var1 = p[1], var2 = p[2], chi_sq = round(test$statistic, 1),
         df = test$parameter, p_value = signif(test$p.value, 3),
         cramers_v = round(sqrt(test$statistic / (sum(tab) * (min(dim(tab)) - 1))), 3))
})
print(assoc_tbl)

cat("\n=== sex x relationship crosstab (checking 'Wife'/'Husband' encode sex+role) ===\n")
sex_relationship_tab <- clean %>% count(sex, relationship) %>%
  pivot_wider(names_from = relationship, values_from = n, values_fill = 0)
print(sex_relationship_tab, width = Inf)

cat("\n=== race distribution ===\n")
print(clean %>% count(race) %>% mutate(pct = round(100*n/sum(n),2)))

cat("\n=== sex distribution ===\n")
print(clean %>% count(sex) %>% mutate(pct = round(100*n/sum(n),2)))

cat("\n=== native_country distribution (top 10) ===\n")
print(clean %>% count(native_country, sort = TRUE) %>% mutate(pct = round(100*n/sum(n),2)) %>% head(10))

cat("\n=== income by sex (proportion, not just count) ===\n")
print(clean %>% count(sex, income) %>% group_by(sex) %>% mutate(pct = round(100*n/sum(n),2)))

cat("\n=== income by education (ordered) ===\n")
income_by_edu <- clean %>%
  mutate(education = fct_reorder(education, education_num)) %>%
  count(education, education_num, income) %>%
  group_by(education) %>%
  mutate(pct = round(100 * n / sum(n), 2)) %>%
  filter(income == ">50K") %>%
  arrange(education_num)
print(income_by_edu, n = Inf)

cat("\n=== hours-per-week: how many work exactly 40? how many <=5 or >=80? ===\n")
print(clean %>% summarise(
  pct_exactly_40 = round(100*mean(hours_per_week == 40),2),
  pct_le_5 = round(100*mean(hours_per_week <= 5),2),
  pct_ge_80 = round(100*mean(hours_per_week >= 80),2),
  n_ge_80 = sum(hours_per_week >= 80)
))

cat("\nPhase 2 complete.\n")
