library(tidyverse)
library(arrow)
df <- read_parquet("data/processed/adult_clean.parquet")

cat("=== Female subpopulation by relationship: age, education, income rate ===\n")
print(df %>% filter(sex == "Female") %>% group_by(relationship) %>%
  summarise(n=n(), mean_age=round(mean(age),1), mean_edu=round(mean(education_num),1),
            pct_above_50k=round(100*mean(income==">50K"),1)) %>% arrange(desc(pct_above_50k)))
cat("\n")

cat("=== Compare: prime-age (35-55) women by relationship ===\n")
print(df %>% filter(sex=="Female", age>=35, age<=55) %>% count(relationship))
cat("\n")

cat("=== Married-civ-spouse only, split by sex (apples to apples: same marital status) ===\n")
print(df %>% filter(marital_status == "Married-civ-spouse") %>% group_by(sex) %>%
  summarise(n=n(), mean_age=round(mean(age),1), mean_hours=round(mean(hours_per_week),1),
            mean_edu=round(mean(education_num),1), pct_above_50k=round(100*mean(income==">50K"),1)))
cat("\n")
cat("=== Never-married only, split by sex ===\n")
print(df %>% filter(marital_status == "Never-married") %>% group_by(sex) %>%
  summarise(n=n(), mean_age=round(mean(age),1), pct_above_50k=round(100*mean(income==">50K"),1)))
