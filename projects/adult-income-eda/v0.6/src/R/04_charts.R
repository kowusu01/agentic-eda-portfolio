source("R/style_tokens.R")
library(tidyverse)
library(arrow)
library(scales)

clean <- read_parquet("../reports/data/processed/adult_clean.parquet")
out_dir <- "../reports/data/processed"

# ============================================================
# Chart 1 — Income prevalence (baseline orientation bar)
# Five-second Q: what fraction of this sample earns over $50K?
# ============================================================
income_prev <- clean %>% count(income) %>% mutate(pct = n / sum(n))

p_income_prev <- ggplot(income_prev, aes(x = income, y = pct, fill = income)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = percent(pct, accuracy = 0.1)), vjust = -0.5, size = annotate_lg, fontface = "bold") +
  scale_y_continuous(labels = percent, limits = c(0, 1), expand = expansion(mult = c(0, 0.08))) +
  scale_fill_manual(values = c("<=50K" = my_colors_8[2], ">50K" = my_colors_8[1]), guide = "none") +
  labs(title = "Income label prevalence (own-sample, unweighted)",
       x = NULL, y = "Share of the 32,561-row sample") +
  minimal_chart_theme
saveRDS(p_income_prev, file.path(out_dir, "chart_income_prevalence.rds"))

# ============================================================
# Chart 2 — Education -> income, threshold-crossing trend line
# Five-second Q: at what education level does earning >$50K become
# the majority outcome, not just more likely?
# ============================================================
edu_income <- readRDS(file.path(out_dir, "edu_income_trend.rds")) %>%
  arrange(education_num)

# linear interpolation for the exact crossing point between the two
# bracketing education levels (Bachelors 13 -> Masters 14 in this data)
below <- edu_income %>% filter(pct_over50k < 0.5) %>% slice_max(education_num, n = 1)
above <- edu_income %>% filter(pct_over50k >= 0.5) %>% slice_min(education_num, n = 1)
crossing_x <- below$education_num +
  (0.5 - below$pct_over50k) / (above$pct_over50k - below$pct_over50k) *
  (above$education_num - below$education_num)

edu_labels <- edu_income %>% select(education_num, education) %>% deframe()

p_edu_trend <- ggplot(edu_income, aes(x = education_num, y = pct_over50k)) +
  geom_smooth(method = "loess", formula = y ~ x, se = FALSE, linewidth = 1.6, color = my_colors_8[3]) +
  geom_point(size = 3.5, color = "#034E7B") +
  geom_hline(yintercept = 0.5, linetype = "dotted", color = "red", linewidth = 0.9) +
  geom_vline(xintercept = crossing_x, linetype = "dotted", color = "red", linewidth = 0.9) +
  annotate("text", x = crossing_x, y = 0.08, label = paste0("crosses 50% within\n", above$education, " tier"),
           size = annotate_sm, hjust = -0.05, color = "red") +
  scale_x_continuous(breaks = edu_income$education_num, labels = edu_labels) +
  scale_y_continuous(labels = percent, limits = c(0, 0.8)) +
  labs(title = "Share earning >$50K, by education level",
       x = NULL, y = "Share earning >$50K") +
  minimal_chart_theme + angled_45_x_axis_labels_theme
saveRDS(p_edu_trend, file.path(out_dir, "chart_education_trend.rds"))
saveRDS(crossing_x, file.path(out_dir, "edu_crossing_x.rds"))

# ============================================================
# Chart 3 — hours-per-week band -> income rate (heaping + extreme tail)
# Five-second Q: does working more hours keep paying off all the way
# up to the extreme end, or does it turn over?
# ============================================================
hours_band <- readRDS(file.path(out_dir, "hours_band_income.rds"))

p_hours_band <- ggplot(hours_band, aes(x = hours_band, y = pct_over50k/100, group = 1)) +
  geom_line(linewidth = 1.3, color = my_colors_8[3]) +
  geom_point(size = 3.5, color = "#034E7B") +
  geom_text(aes(label = percent(pct_over50k/100, accuracy = 0.1)), vjust = -1.1, size = annotate_md, fontface = "bold") +
  annotate("text", x = 5, y = (hours_band$pct_over50k[5]/100) - 0.07,
           label = "turns over at 80+\nhours/week", size = annotate_sm, color = "red", hjust = 0.9) +
  scale_y_continuous(labels = percent, limits = c(0, 0.5)) +
  labs(title = "Share earning >$50K, by weekly hours worked",
       x = "Weekly hours worked (self-reported)", y = "Share earning >$50K") +
  minimal_chart_theme + angled_30_x_axis_labels_theme
saveRDS(p_hours_band, file.path(out_dir, "chart_hours_band.rds"))

# ============================================================
# Chart 4 — capital-gain distribution among nonzero reporters,
# with the top-coding cap called out directly.
# Five-second Q: is that spike at the top a real value or an
# artifact, and what does it mean for the people who hit it?
# ============================================================
nonzero_cg <- clean %>% filter(capital_gain > 0)
n_at_cap <- sum(clean$capital_gain == 99999)

p_capgain <- ggplot(nonzero_cg, aes(x = capital_gain)) +
  geom_histogram(bins = 60, fill = my_colors_8[2], color = "white", linewidth = 0.15) +
  geom_vline(xintercept = 99999, linetype = "dotted", color = "red", linewidth = 1) +
  annotate("text", x = 99999, y = Inf, vjust = 1.5, hjust = 1.05,
           label = paste0(n_at_cap, " respondents capped at $99,999\n100% of them earn >$50K"),
           size = annotate_sm, color = "red") +
  scale_x_continuous(labels = label_dollar()) +
  labs(title = "Capital gains among the 8.4% of respondents reporting any (nonzero) value",
       x = "Capital gain ($)", y = "Count") +
  minimal_chart_theme
saveRDS(p_capgain, file.path(out_dir, "chart_capgain_topcode.rds"))

# ============================================================
# Chart 5 — occupation-level M/F >50K-rate gap, lollipop ranking
# Five-second Q: which occupations show the widest earnings gap
# between men and women in this sample?
# ============================================================
occ_gap <- readRDS(file.path(out_dir, "occ_sex_income_gap.rds")) %>%
  filter(!is.na(gap)) %>%
  mutate(occupation = fct_reorder(occupation, gap))

fig_h <- fig_tall(nrow(occ_gap))

p_occ_gap <- ggplot(occ_gap) +
  geom_segment(aes(x = occupation, y = 0, xend = occupation, yend = gap), color = "gray50") +
  geom_point(aes(x = occupation, y = gap), size = 4, color = "#66C2A5") +
  geom_text(aes(x = occupation, y = gap, label = paste0(round(gap,0), "pp")),
            hjust = ifelse(occ_gap$gap >= 0, -0.3, 1.3), size = annotate_sm) +
  geom_hline(yintercept = 0, color = "gray30") +
  coord_flip(clip = "off") +
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.12))) +
  labs(title = "Male minus female >$50K rate, by occupation (percentage points)",
       x = NULL, y = "Gap in percentage points (Male % − Female %)") +
  minimal_chart_theme
saveRDS(p_occ_gap, file.path(out_dir, "chart_occ_gap.rds"))

cat("Charts built and cached:\n")
cat(list.files(out_dir, pattern = "^chart_"), sep = "\n")
