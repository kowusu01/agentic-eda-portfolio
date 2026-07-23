library(tidyverse)
library(arrow)
df <- read_parquet("data/processed/adult_clean.parquet")

cat("=== Occupation ranked by pct >50K (lollipop candidate) ===\n")
print(df %>% filter(!is.na(occupation)) %>% group_by(occupation) %>%
        summarise(n=n(), pct_above_50k = round(100*mean(income==">50K"),1)) %>% arrange(desc(pct_above_50k)))
cat("\n")

cat("=== Is marital_status's link to income actually an age confound? ===\n")
print(df %>% group_by(marital_status) %>% summarise(n=n(), mean_age=round(mean(age),1), pct_above_50k=round(100*mean(income==">50K"),1)) %>% arrange(desc(pct_above_50k)))
cat("Married-civ-spouse vs Never-married, controlling loosely for age 30-50 band:\n")
print(df %>% filter(age >= 30, age <= 50, marital_status %in% c("Married-civ-spouse","Never-married")) %>%
  group_by(marital_status) %>% summarise(n=n(), pct_above_50k=round(100*mean(income==">50K"),1)))
cat("\n")

cat("=== capital_gain topcode (==99999) rows: what's their income label? ===\n")
print(df %>% mutate(topcoded = capital_gain == 99999) %>% filter(topcoded) %>% count(income))
cat("\n")

cat("=== sex x occupation: top 3 occupations per sex by share ===\n")
print(df %>% filter(!is.na(occupation)) %>% count(sex, occupation) %>% group_by(sex) %>%
  mutate(pct_of_sex = round(100*n/sum(n),1)) %>% arrange(sex, desc(pct_of_sex)) %>% group_modify(~head(.x,4)))
cat("\n")

cat("=== workclass==NA rows: what does 'not currently working' look like? ===\n")
print(df %>% filter(is.na(workclass)) %>% summarise(n=n(), mean_age=mean(age), mean_hours=mean(hours_per_week), pct_above_50k=round(100*mean(income==">50K"),1)))
print(df %>% filter(is.na(workclass)) %>% count(hours_per_week==0))
cat("hours_per_week among workclass==NA -- distribution:\n")
print(summary(df$hours_per_week[is.na(df$workclass)]))
cat("\n")

cat("=== relationship x sex (check relationship encodes sex-adjacent role, e.g. Wife/Husband) ===\n")
print(df %>% count(relationship, sex) %>% arrange(relationship))
cat("\n")

cat("=== Wife vs Husband income rate (same 'married present' role, opposite sex label) ===\n")
print(df %>% filter(relationship %in% c("Wife","Husband")) %>% group_by(relationship) %>%
  summarise(n=n(), mean_hours=round(mean(hours_per_week),1), pct_above_50k=round(100*mean(income==">50K"),1)))
