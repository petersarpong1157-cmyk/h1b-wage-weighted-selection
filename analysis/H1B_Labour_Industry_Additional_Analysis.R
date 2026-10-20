# H-1B labour-market paper — extension to verified independent audit
# Run in the SAME R session immediately after H1B_Independent_Audit_Low_Memory.R.
# This extension does not reload the large Excel inputs.
# PW_WAGE_LEVEL is the reported DOL prevailing-wage level, NOT a verified
# USCIS offered-wage selection level. Descriptive; not causal or a visa simulation.

library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

if (!exists("a25") || !exists("a26") || !exists("output_dir")) {
  stop("Run H1B_Independent_Audit_Low_Memory.R first; a25, a26 and output_dir are required.")
}
phase_dir <- file.path(output_dir, "labour_industry_extension")
dir.create(phase_dir, recursive = TRUE, showWarnings = FALSE)
levels <- c("I", "II", "III", "IV")
weights <- c(I = 1, II = 2, III = 3, IV = 4)

prep <- function(x, period) {
  needed <- c("PW_WAGE_LEVEL", "NEW_EMPLOYMENT", "SOC_CODE", "EMPLOYER_NAME")
  if (length(setdiff(needed, names(x)))) stop("Missing input columns")
  x %>%
    transmute(
      period = period,
      level = as.character(PW_WAGE_LEVEL),
      applications = 1L,
      positions = as.numeric(NEW_EMPLOYMENT),
      soc2 = str_extract(as.character(SOC_CODE), "^[0-9]{2}"),
      employer = str_squish(str_to_upper(as.character(EMPLOYER_NAME)))
    ) %>%
    filter(level %in% levels) %>%
    mutate(
      positions = replace_na(positions, 0),
      soc2 = replace_na(soc2, "Missing SOC"),
      employer = if_else(is.na(employer) | employer == "", "Missing employer", employer),
      weight = unname(weights[level])
    )
}
combined <- bind_rows(prep(a25, "FY2025 Q1-Q3"), prep(a26, "FY2026 Q1-Q3"))
if (any(combined$positions < 0)) stop("Negative NEW_EMPLOYMENT counts detected. Review the source data.")

# 01. Decompose the sign reversal descriptively: average new positions per LCA.
# This is a diagnostic identity, NOT a causal attribution.
level_summary <- combined %>%
  group_by(period, level) %>%
  summarise(applications = sum(applications), positions = sum(positions),
            zero_position_lcas = sum(positions == 0), .groups = "drop") %>%
  group_by(period) %>%
  mutate(app_share = applications / sum(applications),
         position_share = positions / sum(positions),
         mean_positions_per_lca = positions / applications) %>%
  mutate(weight = unname(weights[level])) %>%
  group_by(period) %>%
  mutate(app_weighted_share = (applications * weight) / sum(applications * weight),
         positions_weighted_share = (positions * weight) / sum(positions * weight),
         app_change_pp = 100 * (app_weighted_share - app_share),
         position_change_pp = 100 * (positions_weighted_share - position_share),
         contrast_pp = position_change_pp - app_change_pp) %>% ungroup()
write.csv(level_summary, file.path(phase_dir, "01_level_measure_contrast.csv"), row.names = FALSE)

# 02. Describe requested-position counts across LCAs; do NOT interpret as actual hiring.
pos_quantiles <- combined %>%
  group_by(period, level) %>%
  summarise(applications = n(), zero_position_fraction = mean(positions == 0),
            median_positions = median(positions),
            p90_positions = unname(quantile(positions, .9)),
            p99_positions = unname(quantile(positions, .99)),
            maximum_positions = max(positions), .groups = "drop")
write.csv(pos_quantiles, file.path(phase_dir, "02_positions_per_application.csv"), row.names = FALSE)

# 03. SOC two-digit distribution; all SOC codes must be interpreted cautiously.
soc_table <- combined %>%
  group_by(period, soc2, level) %>%
  summarise(applications = sum(applications), positions = sum(positions),
            .groups = "drop") %>%
  group_by(period, soc2) %>%
  mutate(soc_positions = sum(positions), soc_applications = sum(applications),
         soc_weighted_positions = sum(positions * unname(weights[level])),
         soc_baseline_share = if_else(soc_positions > 0, positions / soc_positions, NA_real_),
         soc_weighted_share = if_else(soc_weighted_positions > 0,
                                      positions * unname(weights[level]) / soc_weighted_positions, NA_real_),
         soc_change_pp = 100 * (soc_weighted_share - soc_baseline_share)) %>% ungroup()
write.csv(soc_table, file.path(phase_dir, "03_soc2_wage_level_composition.csv"), row.names = FALSE)

# 04. Contribution of employers to requested Level II positions (concentration).
# Normalize whitespace/case only; subsidiary/name variants are NOT merged.
employer_table <- combined %>%
  group_by(period, employer, level) %>%
  summarise(applications = sum(applications), positions = sum(positions), .groups = "drop") %>%
  group_by(period, employer) %>%
  mutate(employer_positions = sum(positions),
         level_position_share = if_else(employer_positions > 0, positions / employer_positions, NA_real_)) %>%
  ungroup()
write.csv(employer_table, file.path(phase_dir, "04_employer_level_composition.csv"), row.names = FALSE)

concentration <- combined %>%
  group_by(period, employer) %>%
  summarise(positions = sum(positions), applications = n(), .groups = "drop") %>%
  group_by(period) %>%
  arrange(desc(positions), employer, .by_group = TRUE) %>%
  mutate(rank = row_number(),
         position_share = positions / sum(positions),
         top10_share = sum(head(positions, 10)) / sum(positions),
         hhi = sum((positions / sum(positions))^2)) %>% ungroup()
write.csv(concentration %>% filter(rank <= 25),
          file.path(phase_dir, "05_top25_employers_and_concentration.csv"), row.names = FALSE)

# 06. Recompute counterfactual changes by unit inside the same SOC group.
# Avoid confusing within-occupation with total employment shares.
soc_comparison <- soc_table %>%
  filter(!is.na(soc_change_pp)) %>%
  group_by(period, soc2) %>%
  summarise(positions = first(soc_positions),
            level_ii_change_pp = soc_change_pp[level == "II"][1],
            .groups = "drop") %>%
  arrange(period, desc(positions))
write.csv(soc_comparison, file.path(phase_dir, "06_soc2_level_ii_sensitivity.csv"), row.names = FALSE)

p <- level_summary %>%
  select(period, level, app_change_pp, position_change_pp) %>%
  pivot_longer(c(app_change_pp, position_change_pp), names_to = "unit", values_to = "change_pp") %>%
  mutate(unit = recode(unit, app_change_pp = "LCA applications",
                       position_change_pp = "Requested new-employment positions")) %>%
  ggplot(aes(level, change_pp, group = unit, linetype = unit, shape = unit)) +
  geom_hline(yintercept = 0, linewidth = .3) +
  geom_line() + geom_point(size = 2.5) + facet_wrap(~period) +
  labs(x = "DOL reported prevailing-wage level",
       y = "Weighted minus unweighted share (percentage points)",
       linetype = "Unit of analysis", shape = "Unit of analysis") +
  theme_minimal(base_size = 11)
ggsave(file.path(phase_dir, "07_analysis_unit_contrast.png"), p,
       width = 10, height = 5.5, dpi = 300)

# Assert key published totals. Fail, don't quietly write inconsistent new results.
check <- level_summary %>% group_by(period) %>%
  summarise(lcas = sum(applications), positions = sum(positions), .groups = "drop")
if (!identical(as.numeric(check$lcas), c(401626, 351375)) ||
    !identical(as.numeric(check$positions), c(235613, 241528))) {
  stop("Existing manuscript sample totals are not reproduced; inspect sources.")
}
writeLines(capture.output(sessionInfo()), file.path(phase_dir, "08_session_info.txt"))
message("Extension complete. Results in: ", phase_dir)
message("Do not write conclusions before inspecting exported CSVs and checking SOC/employer coverage.")
