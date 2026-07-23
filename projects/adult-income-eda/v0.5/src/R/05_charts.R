library(tidyverse)
library(arrow)
source("R/style_tokens.R")
dir.create("data/processed", showWarnings = FALSE)

df <- read_parquet("data/processed/adult_clean.parquet")

# ---------------------------------------------------------------------------
# Chart 1: Education -> income, threshold-crossing trend line
# ---------------------------------------------------------------------------
edu_levels <- df %>% distinct(education, education_num) %>% arrange(education_num) %>% pull(education)
edu_tab <- df %>% group_by(education, education_num) %>%
  summarise(n = n(), prop = mean(income == ">50K"), .groups = "drop") %>%
  mutate(education = factor(education, levels = edu_levels)) %>%
  arrange(education_num)

# crossing point via linear interpolation between the two education_num values
# that straddle prop == 0.5
crossing_x <- approx(x = edu_tab$prop, y = edu_tab$education_num, xout = 0.5)$y

write_parquet(edu_tab, "data/processed/education_income_trend.parquet")
saveRDS(crossing_x, "data/processed/education_crossing_x.rds")

p_edu_trend <- edu_tab %>%
  ggplot(aes(x = education_num, y = prop, group = 1)) +
  geom_smooth(method = "loess", formula = y ~ x, se = FALSE, linewidth = 2, color = "#FDB462") +
  geom_point(size = 4, color = "#3690C0") +
  geom_hline(yintercept = 0.5, linetype = "dotted", color = "red", linewidth = 1) +
  geom_vline(xintercept = crossing_x, linetype = "dotted", color = "red", linewidth = 1) +
  scale_x_continuous(breaks = edu_tab$education_num, labels = edu_tab$education) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Share earning >$50K rises sharply after a Bachelor's degree",
       x = "Education level (ordered)", y = "Share earning >$50K") +
  minimal_chart_theme + angled_45_x_axis_labels_theme
saveRDS(p_edu_trend, "data/processed/chart_education_trend.rds")
cat("Education crossing_x (education_num scale):", crossing_x, "-> between",
    edu_tab$education[floor(crossing_x)], "and", edu_tab$education[ceiling(crossing_x)], "\n")

# ---------------------------------------------------------------------------
# Chart 2: Occupation lollipop ranking (raw levels; reclassified version added
# after Phase 0 occupation-scheme research returns)
# ---------------------------------------------------------------------------
occ_tab <- df %>% filter(!is.na(occupation)) %>% group_by(occupation) %>%
  summarise(n = n(), pct_above_50k = 100 * mean(income == ">50K"), .groups = "drop") %>%
  arrange(pct_above_50k)
write_parquet(occ_tab, "data/processed/occupation_income_rank.parquet")

p_occ_lollipop <- occ_tab %>%
  mutate(occupation = fct_reorder(occupation, pct_above_50k)) %>%
  ggplot() +
  geom_segment(aes(x = occupation, y = pct_above_50k, xend = occupation, yend = 0), color = "gray50") +
  geom_point(aes(x = occupation, y = pct_above_50k), size = 4, color = "#66C2A5") +
  coord_flip() +
  labs(title = "Share earning >$50K by occupation, raw 14-level coding",
       x = NULL, y = "Share earning >$50K (%)") +
  minimal_chart_theme
h <- fig_tall(nrow(occ_tab))
saveRDS(p_occ_lollipop, "data/processed/chart_occupation_lollipop.rds")

# ---------------------------------------------------------------------------
# Chart 3: The sex gap that closes within marriage (dumbbell-style)
# ---------------------------------------------------------------------------
gap_tab <- bind_rows(
  df %>% mutate(scope = "All respondents") %>% group_by(scope, sex) %>%
    summarise(pct_above_50k = 100*mean(income==">50K"), .groups="drop"),
  df %>% filter(marital_status == "Married-civ-spouse") %>% mutate(scope = "Married, spouse present") %>%
    group_by(scope, sex) %>% summarise(pct_above_50k = 100*mean(income==">50K"), .groups="drop")
) %>% mutate(scope = factor(scope, levels = c("Married, spouse present", "All respondents")))
write_parquet(gap_tab, "data/processed/sex_gap_by_marriage.parquet")

p_sex_gap <- gap_tab %>%
  ggplot(aes(x = pct_above_50k, y = scope)) +
  geom_line(aes(group = scope), color = "gray60", linewidth = 3) +
  geom_point(aes(color = sex), size = 6) +
  scale_color_manual(values = c(Female = "#FB8072", Male = "#80B1D3")) +
  labs(title = "The aggregate sex gap in >$50K rate nearly vanishes among married couples",
       x = "Share earning >$50K (%)", y = NULL, color = "Sex") +
  minimal_chart_theme
saveRDS(p_sex_gap, "data/processed/chart_sex_gap.rds")

# ---------------------------------------------------------------------------
# Chart 4: workclass income ranking, with the NA/unreported group highlighted
# ---------------------------------------------------------------------------
wc_tab <- df %>% mutate(workclass_lbl = ifelse(is.na(workclass), "(unreported)", workclass)) %>%
  filter(!workclass_lbl %in% c("Never-worked","Without-pay")) %>%  # tiny n, would dominate axis noise
  group_by(workclass_lbl) %>%
  summarise(n = n(), pct_above_50k = 100*mean(income==">50K"), .groups="drop") %>%
  mutate(is_unreported = workclass_lbl == "(unreported)")
write_parquet(wc_tab, "data/processed/workclass_income_rank.parquet")

p_workclass <- wc_tab %>%
  mutate(workclass_lbl = fct_reorder(workclass_lbl, pct_above_50k)) %>%
  ggplot() +
  geom_segment(aes(x = workclass_lbl, y = pct_above_50k, xend = workclass_lbl, yend = 0), color = "gray50") +
  geom_point(aes(x = workclass_lbl, y = pct_above_50k, color = is_unreported), size = 4) +
  scale_color_manual(values = c(`TRUE` = "#D95F0E", `FALSE` = "#66C2A5"), guide = "none") +
  coord_flip() +
  labs(title = "Employer type left unreported, not unemployment, marks the lowest-earning working group",
       x = NULL, y = "Share earning >$50K (%)") +
  minimal_chart_theme
saveRDS(p_workclass, "data/processed/chart_workclass_rank.rds")

# ---------------------------------------------------------------------------
# Chart 5: capital_gain topcoding
# ---------------------------------------------------------------------------
cg_nonzero <- df %>% filter(capital_gain > 0)
write_parquet(cg_nonzero %>% select(capital_gain, income), "data/processed/capital_gain_nonzero.parquet")

p_capgain <- cg_nonzero %>%
  ggplot(aes(x = capital_gain)) +
  geom_histogram(bins = 60, fill = "#3690C0") +
  geom_vline(xintercept = 99999, linetype = "dotted", color = "red", linewidth = 1) +
  annotate("text", x = 99999, y = Inf, label = "topcoded at 99,999\n(159 rows, all >$50K)",
           hjust = 1.05, vjust = 1.5, size = annotate_sm, color = "red") +
  scale_x_continuous(labels = scales::comma) +
  labs(title = "Non-zero capital gains: a hard ceiling at 99,999, not a natural tail",
       x = "Capital gain ($)", y = "Count") +
  minimal_chart_theme
saveRDS(p_capgain, "data/processed/chart_capital_gain.rds")

# ---------------------------------------------------------------------------
# Chart 6: hours_per_week distribution (plain, to counter the inflated IQR read)
# ---------------------------------------------------------------------------
write_parquet(df %>% select(hours_per_week), "data/processed/hours_dist.parquet")
p_hours <- df %>% ggplot(aes(x = hours_per_week)) +
  geom_histogram(binwidth = 2, fill = "#8DD3C7", color = "white") +
  geom_vline(xintercept = 40, linetype = "dashed", color = "gray30") +
  annotate("text", x = 40, y = Inf, label = "40 hrs/week", hjust = -0.1, vjust = 1.5, size = annotate_sm) +
  labs(title = "Hours worked: a sharp spike at 40, with a long but plausible tail either side",
       x = "Hours per week", y = "Count") +
  minimal_chart_theme
saveRDS(p_hours, "data/processed/chart_hours_dist.rds")

cat("\nAll charts cached to data/processed/. Done.\n")
