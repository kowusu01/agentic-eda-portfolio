# style_tokens.R
# Materialized from the design tokens in references/visual-style.md (kwaku-eda skill).
# Copy this file into a project's src/ directory — do not leave the project
# depending on the skill being present at render time.

library(ggplot2)
library(scales) # cached chart objects in this project use percent()/label_dollar() inside aes(), so this must be loaded wherever a cached .rds chart gets printed, not just where it was built

# --- Font tokens (points) -----------------------------------------------
# Used for both theme text (element_text(size=...)) and in-plot annotations.
font_sm <- 8    # dense annotations, footnote-level text
font_md <- 10   # default — axis text, axis titles, chart title
font_lg <- 12   # emphasis, a single callout number
font_xl <- 16   # rare — a chart that IS one big number

# annotate()/geom_text() use mm-based `size`, not points — convert so a token
# looks the same size whether it's theme text or an in-plot annotation.
pt_to_ggplot_size <- function(pt) pt / 2.845276
annotate_sm <- pt_to_ggplot_size(font_sm)
annotate_md <- pt_to_ggplot_size(font_md)
annotate_lg <- pt_to_ggplot_size(font_lg)
annotate_xl <- pt_to_ggplot_size(font_xl)

# --- Figure-size tokens (inches: width, height) --------------------------
fig_sm   <- list(width = 5, height = 3)     # compact, single small distribution
fig_md   <- list(width = 6, height = 4)     # default — most single charts
fig_lg   <- list(width = 7, height = 6)     # detailed/dense single chart
fig_wide <- list(width = 7, height = 1.5)   # short-and-wide: swatch strips, spectrum keys

# Height scales with content — a ranking's needed height depends on how many
# categories it has, so this is a function, not a fixed preset.
fig_tall <- function(n_categories, width = 6, max_height = 10) {
  list(width = width, height = min(max_height, 2 + 0.3 * n_categories))
}

# --- Base theme pieces -----------------------------------------------------
chart_main_title_theme <- theme(plot.title = element_text(size = font_md))

chart_axis_theme <- theme(axis.title = element_text(face = "bold"),
                           axis.text = element_text(size = font_md))

angled_30_x_axis_labels_theme <- theme(axis.text.x = element_text(angle = 30, vjust = .8, hjust = 0.8))
angled_45_x_axis_labels_theme <- theme(axis.text.x = element_text(angle = 45, vjust = .8, hjust = 0.8))
angled_90_x_axis_labels_theme <- theme(axis.text.x = element_text(angle = 90))

classic_chart_theme <- theme_classic() + chart_main_title_theme + chart_axis_theme
gray_chart_theme    <- theme_gray()   + chart_main_title_theme + chart_axis_theme
minimal_chart_theme <- theme_minimal() + chart_main_title_theme + chart_axis_theme

# --- Palettes ---------------------------------------------------------------
# Hand-curated, colorblind-friendly, for unordered categorical variables.
# Use scale_fill_discrete_sequential() (colorspace package) instead for
# ordinal variables (see the swatch-strip pattern in visual-style.md).
my_colors_20 <- c("#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072", "#80B1D3", "#FDB462", "#B3DE69",
                   "#FCCDE5", "#FEE0D2", "#D9D9D9", "#BC80BD", "#CCEBC5", "#FFED6F", "#31A354",
                   "#034E7B", "#006837", "#D95F0E", "#993404", "#3690C0", "#0570B0")

my_colors_8 <- c("#F4A582", "#92C5DE", "#66C2A5", "#A6D854", "#FFD92F", "#66BD63", "#1A9850", "#FDAE61", "#D9EF8B")
