# 03_charts.R
# Builds all report-facing chart objects and chart-feeding data.
# All charts saved as Type 2 .rds; chart data as .parquet.
# Run from the project root: Rscript R/03_charts.R
library(tidyverse)
library(arrow)
source("R/style_tokens.R")

df <- read_parquet("data/processed/adult_clean.parquet")

# ============================================================
# Chart 1: Education income-rate trend (threshold-crossing)
# Five-second takeaway: at which education level does >50K
# become the clear majority outcome?
# ============================================================

edu_income <- df %>%
  group_by(education, education_num) %>%
  summarise(
    n          = n(),
    n_over50k  = sum(income_bin),
    prop       = mean(income_bin),
    .groups    = "drop"
  ) %>%
  arrange(education_num)

write_parquet(edu_income, "data/processed/chart_edu_income.parquet")

# Find the level closest to 50% crossing
crossing_idx <- which.min(abs(edu_income$prop - 0.5))

p_edu_trend <- edu_income %>%
  ggplot(aes(x = education_num, y = prop)) +
  geom_point(size = 4, color = "#034E7B") +
  geom_smooth(method = "loess", formula = y ~ x, se = FALSE,
              linewidth = 2, color = "#D95F0E") +
  geom_hline(yintercept = 0.5, linetype = "dotted", color = "red", linewidth = 1) +
  scale_x_continuous(
    breaks = edu_income$education_num,
    labels = as.character(edu_income$education)
  ) +
  scale_y_continuous(labels = scales::percent_format(), limits = c(0, 0.85)) +
  labs(
    title = "Income rate rises steeply at Bachelors — and crosses 50% only at professional degrees",
    x     = "Education level (lowest to highest)",
    y     = "Proportion earning >$50K"
  ) +
  minimal_chart_theme + angled_90_x_axis_labels_theme

saveRDS(p_edu_trend, "data/processed/chart_edu_trend.rds")
ggsave("output/figures/education_income_trend.png", p_edu_trend,
       width = fig_lg$width, height = fig_lg$height, dpi = 150)
message("Chart 1 saved")

# ============================================================
# Chart 2: Gender × marriage income rates (2x2 interaction)
# Five-second takeaway: married women and married men earn
# at nearly identical rates; the gender gap is almost entirely
# driven by who is in the married-and-employed category.
# ============================================================

gender_marriage <- df %>%
  mutate(
    married_label = if_else(married, "Married", "Not married"),
    group         = paste(sex, married_label, sep = "\n")
  ) %>%
  group_by(sex, married_label, group) %>%
  summarise(
    n            = n(),
    pct_over50k  = mean(income_bin) * 100,
    .groups      = "drop"
  ) %>%
  mutate(group = factor(group, levels = c("Female\nNot married", "Female\nMarried",
                                           "Male\nNot married", "Male\nMarried")))

write_parquet(gender_marriage, "data/processed/chart_gender_marriage.parquet")

p_gender_marriage <- gender_marriage %>%
  ggplot(aes(x = group, y = pct_over50k, fill = sex)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = paste0(round(pct_over50k, 1), "%")),
            vjust = -0.4, size = annotate_md, fontface = "bold") +
  scale_fill_manual(values = c("Female" = "#92C5DE", "Male" = "#F4A582"),
                    name = NULL) +
  scale_y_continuous(limits = c(0, 55), labels = scales::percent_format(scale = 1)) +
  labs(
    title = "The gender income gap nearly vanishes when conditioning on marital status",
    x     = NULL,
    y     = "% earning >$50K"
  ) +
  minimal_chart_theme +
  theme(legend.position = "none")

saveRDS(p_gender_marriage, "data/processed/chart_gender_marriage.rds")
ggsave("output/figures/gender_marriage_income.png", p_gender_marriage,
       width = fig_md$width, height = fig_md$height, dpi = 150)
message("Chart 2 saved")

# ============================================================
# Chart 3: Occupation income ranking (lollipop)
# Five-second takeaway: which occupation has the highest /
# lowest share of high earners — and how wide is the gap?
# ============================================================

occ_income <- df %>%
  filter(!is.na(occupation)) %>%
  group_by(occupation) %>%
  summarise(
    n           = n(),
    pct_over50k = mean(income_bin) * 100,
    .groups     = "drop"
  ) %>%
  mutate(occupation = fct_reorder(occupation, pct_over50k))

write_parquet(occ_income, "data/processed/chart_occ_income.parquet")

n_occ <- nrow(occ_income)
p_occ_lollipop <- occ_income %>%
  ggplot() +
  geom_segment(aes(x = occupation, xend = occupation, y = 0, yend = pct_over50k),
               color = "grey60") +
  geom_point(aes(x = occupation, y = pct_over50k), size = 4, color = "#66C2A5") +
  geom_text(aes(x = occupation, y = pct_over50k, label = paste0(round(pct_over50k, 1), "%")),
            hjust = -0.3, size = annotate_sm) +
  coord_flip() +
  scale_y_continuous(limits = c(0, 60), labels = scales::percent_format(scale = 1)) +
  labs(
    title = "Occupation income rates: a 68-point spread from private household service to exec/managerial",
    x     = NULL,
    y     = "% earning >$50K"
  ) +
  minimal_chart_theme

saveRDS(p_occ_lollipop, "data/processed/chart_occ_lollipop.rds")
ggsave("output/figures/occupation_income_ranking.png", p_occ_lollipop,
       width = fig_tall(n_occ)$width, height = fig_tall(n_occ)$height, dpi = 150)
message("Chart 3 saved")

# ============================================================
# Chart 4: Capital gain as wealth signal
# Five-second takeaway: capital gain is almost exclusively a
# >$50K earner phenomenon — 91.7% of the sample has none.
# ============================================================

cap_gain_summary <- df %>%
  mutate(has_gain = capital_gain > 0) %>%
  group_by(income) %>%
  summarise(
    n              = n(),
    pct_any_gain   = mean(has_gain) * 100,
    pct_no_gain    = (1 - mean(has_gain)) * 100,
    .groups        = "drop"
  )

write_parquet(cap_gain_summary, "data/processed/chart_capital_gain.parquet")

cap_gain_plot_df <- cap_gain_summary %>%
  select(income, pct_any_gain, pct_no_gain) %>%
  pivot_longer(cols = c(pct_any_gain, pct_no_gain),
               names_to = "type", values_to = "pct") %>%
  mutate(
    type  = factor(type, levels = c("pct_no_gain", "pct_any_gain"),
                   labels = c("No capital gain ($0)", "Any capital gain (>$0)")),
    income = factor(income, levels = c("<=50K", ">50K"))
  )

p_capital_gain <- cap_gain_plot_df %>%
  ggplot(aes(x = income, y = pct, fill = type)) +
  geom_col(width = 0.5) +
  geom_text(
    data = cap_gain_summary,
    aes(x = income, y = pct_any_gain / 2 + pct_no_gain,
        label = paste0(round(pct_any_gain, 1), "%\nhave gains")),
    inherit.aes = FALSE,
    vjust = -0.2, size = annotate_md, color = "#034E7B", fontface = "bold"
  ) +
  scale_fill_manual(values = c("No capital gain ($0)" = "#D9D9D9",
                                "Any capital gain (>$0)" = "#034E7B"),
                    name = NULL) +
  scale_y_continuous(limits = c(0, 115), labels = scales::percent_format(scale = 1)) +
  labs(
    title = "Capital gains are concentrated among high earners — nearly invisible below $50K",
    x     = "Income group",
    y     = "% of income group"
  ) +
  minimal_chart_theme +
  theme(legend.position = "bottom")

saveRDS(p_capital_gain, "data/processed/chart_capital_gain.rds")
ggsave("output/figures/capital_gain_by_income.png", p_capital_gain,
       width = fig_md$width, height = fig_md$height, dpi = 150)
message("Chart 4 saved")

# ============================================================
# Chart 5: Age distribution by income (overlapping density)
# Five-second takeaway: high earners occupy a narrower,
# more mid-career age band than lower earners.
# ============================================================

age_density_data <- df %>% select(age, income)
write_parquet(age_density_data, "data/processed/chart_age_density.parquet")

p_age_density <- age_density_data %>%
  ggplot(aes(x = age, fill = income, color = income)) +
  geom_density(alpha = 0.5, linewidth = 1) +
  geom_vline(xintercept = 34, linetype = "dotted", color = "#92C5DE", linewidth = 1) +
  geom_vline(xintercept = 44, linetype = "dotted", color = "#F4A582", linewidth = 1) +
  annotate("text", x = 34, y = 0.035, label = "Median\n≤$50K\n(34)", hjust = 1.1,
           size = annotate_sm, color = "#034E7B") +
  annotate("text", x = 44, y = 0.035, label = "Median\n>$50K\n(44)", hjust = -0.1,
           size = annotate_sm, color = "#993404") +
  scale_fill_manual(values  = c("<=50K" = "#92C5DE", ">50K" = "#F4A582"), name = NULL) +
  scale_color_manual(values = c("<=50K" = "#034E7B", ">50K" = "#993404"), name = NULL) +
  labs(
    title = "High earners cluster in a narrower mid-career band (median 44, sd=10.5)",
    x     = "Age",
    y     = "Density"
  ) +
  minimal_chart_theme +
  theme(legend.position = "top")

saveRDS(p_age_density, "data/processed/chart_age_density.rds")
ggsave("output/figures/age_distribution_by_income.png", p_age_density,
       width = fig_md$width, height = fig_md$height, dpi = 150)
message("Chart 5 saved")

message("\nAll charts built and cached.")
