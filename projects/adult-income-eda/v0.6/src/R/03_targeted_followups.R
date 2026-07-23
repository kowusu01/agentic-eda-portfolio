source("R/style_tokens.R")
library(tidyverse)
library(arrow)

clean <- read_parquet("../reports/data/processed/adult_clean.parquet")

# ============================================================
# Q1 — education -> income threshold crossing
# ============================================================
cat("\n=== Q1: income >50K rate by education (ordered) ===\n")
edu_income <- clean %>%
  mutate(education = fct_reorder(education, education_num)) %>%
  group_by(education, education_num) %>%
  summarise(n = n(), pct_over50k = mean(income == ">50K"), .groups = "drop") %>%
  arrange(education_num)
print(edu_income, n = Inf)

# crossing point: first education_num where pct_over50k >= 0.5
crossing_row <- edu_income %>% filter(pct_over50k >= 0.5) %>% slice_min(education_num, n = 1)
cat("First education level crossing 50%:", as.character(crossing_row$education),
    "(", round(100*crossing_row$pct_over50k,1), "%)\n")
saveRDS(edu_income, "../reports/data/processed/edu_income_trend.rds")

# ============================================================
# Q2 — sex x occupation x income
# ============================================================
cat("\n=== Q2: >50K rate by occupation and sex ===\n")
occ_sex_income <- clean %>%
  filter(!is.na(occupation)) %>%
  group_by(occupation, sex) %>%
  summarise(n = n(), pct_over50k = round(100*mean(income == ">50K"),1), .groups = "drop")
print(occ_sex_income %>% pivot_wider(names_from = sex, values_from = c(n, pct_over50k)), n=Inf)

# overall gap vs within-occupation gap
overall_gap <- clean %>% group_by(sex) %>% summarise(pct = mean(income==">50K")) %>%
  pivot_wider(names_from = sex, values_from = pct) %>% mutate(gap = Male - Female)
cat("Overall M-F >50K pct-point gap:", round(100*overall_gap$gap,1), "\n")

within_occ_gap <- occ_sex_income %>%
  select(occupation, sex, pct_over50k) %>%
  pivot_wider(names_from = sex, values_from = pct_over50k) %>%
  mutate(gap = Male - Female) %>%
  arrange(desc(gap))
print(within_occ_gap, n = Inf)
cat("Mean within-occupation M-F gap (unweighted across occupations):",
    round(mean(within_occ_gap$gap, na.rm=TRUE),1), "\n")

# how much of the workforce is in male- vs female-dominated occupations?
occ_sex_share <- clean %>% filter(!is.na(occupation)) %>%
  count(occupation, sex) %>%
  group_by(occupation) %>%
  mutate(pct = round(100*n/sum(n),1)) %>%
  filter(sex == "Female") %>%
  arrange(pct)
print(occ_sex_share, n = Inf)

saveRDS(within_occ_gap, "../reports/data/processed/occ_sex_income_gap.rds")
saveRDS(occ_sex_share, "../reports/data/processed/occ_sex_share.rds")

# ============================================================
# Q3 — capital-gain top-coding demographics
# ============================================================
cat("\n=== Q3: who is at the capital_gain top-code (99999)? ===\n")
topcode_grp <- clean %>% mutate(at_cap = capital_gain == 99999)
topcode_summary <- topcode_grp %>%
  group_by(at_cap) %>%
  summarise(n = n(), pct_over50k = round(100*mean(income==">50K"),1),
            mean_age = round(mean(age),1), .groups = "drop")
print(topcode_summary)
saveRDS(topcode_summary, "../reports/data/processed/capgain_topcode_summary.rds")

# ============================================================
# Q4 — hours-per-week: 40-heaping vs 80+ tail
# ============================================================
cat("\n=== Q4: income rate by hours-per-week band ===\n")
hours_band <- clean %>%
  mutate(hours_band = case_when(
    hours_per_week < 35 ~ "<35 (part-time)",
    hours_per_week == 40 ~ "exactly 40",
    hours_per_week > 40 & hours_per_week < 80 ~ "41-79",
    hours_per_week >= 80 ~ "80+ (extreme)",
    TRUE ~ "35-39"
  )) %>%
  mutate(hours_band = factor(hours_band, levels = c("<35 (part-time)","35-39","exactly 40","41-79","80+ (extreme)"))) %>%
  group_by(hours_band) %>%
  summarise(n = n(), pct_over50k = round(100*mean(income==">50K"),1), .groups="drop")
print(hours_band)
saveRDS(hours_band, "../reports/data/processed/hours_band_income.rds")

# ============================================================
# Q5 — structural missingness (workclass/occupation) demographics
# ============================================================
cat("\n=== Q5: demographics of workclass-missing rows ===\n")
missing_workclass_summary <- clean %>%
  mutate(workclass_missing = is.na(workclass)) %>%
  group_by(workclass_missing) %>%
  summarise(n = n(), pct_over50k = round(100*mean(income==">50K"),1),
            mean_age = round(mean(age),1), mean_hours = round(mean(hours_per_week),1),
            .groups = "drop")
print(missing_workclass_summary)
saveRDS(missing_workclass_summary, "../reports/data/processed/missing_workclass_summary.rds")

# age distribution of missing-workclass group vs rest (check if concentrated at retirement age)
age_by_missing <- clean %>%
  mutate(workclass_missing = is.na(workclass)) %>%
  group_by(workclass_missing) %>%
  summarise(p25 = quantile(age,.25), median = median(age), p75 = quantile(age,.75), .groups="drop")
print(age_by_missing)

cat("\nPhase 3 targeted follow-ups complete.\n")
