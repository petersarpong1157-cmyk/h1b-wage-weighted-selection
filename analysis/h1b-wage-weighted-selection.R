# Reproducibility script
# Wage-Weighted H-1B Selection and Employment Distribution
# Corrected matched-period analysis
# Author: Peter Sarpong
#
# Primary comparison:
#   FY2025 Q1-Q3: October 1, 2024 through June 30, 2025
#   FY2026 Q1-Q3: October 1, 2025 through June 30, 2026
#
# Data are not redistributed with this repository.
# Download the official DOL LCA disclosure workbooks and place them in data/raw/.

library(dplyr)
library(ggplot2)
library(tidyr)
library(readxl)
library(stringr)

dir.create("results", showWarnings = FALSE, recursive = TRUE)
dir.create("figures", showWarnings = FALSE, recursive = TRUE)

# -------------------------------------------------------------------
# 1. Source files
# -------------------------------------------------------------------

f25_q1 <- "data/raw/LCA_Disclosure_Data_FY2025_Q1.xlsx"
f25_q2 <- "data/raw/LCA_Disclosure_Data_FY2025_Q2.xlsx"
f25_q3 <- "data/raw/LCA_Disclosure_Data_FY2025_Q3.xlsx"
f25_q4 <- "data/raw/LCA_Disclosure_Data_FY2025_Q4.xlsx"
f26_q3 <- "data/raw/LCA_Disclosure_Data_FY2026_Q3.xlsx"

required_files <- c(f25_q1, f25_q2, f25_q3, f25_q4, f26_q3)

if (!all(file.exists(required_files))) {
  stop(
    "Missing source file(s): ",
    paste(required_files[!file.exists(required_files)], collapse = ", ")
  )
}

q1_2025 <- read_excel(f25_q1)
q2_2025 <- read_excel(f25_q2)
q3_2025 <- read_excel(f25_q3)
q4_2025 <- read_excel(f25_q4)
fy2026_q3 <- read_excel(f26_q3)

# -------------------------------------------------------------------
# 2. Harmonize variables
# -------------------------------------------------------------------

prepare_lca <- function(df) {
  df %>%
    transmute(
      CASE_NUMBER = as.character(CASE_NUMBER),
      DECISION_DATE = as.Date(DECISION_DATE),
      CASE_STATUS = trimws(as.character(CASE_STATUS)),
      VISA_CLASS = trimws(as.character(VISA_CLASS)),
      PW_WAGE_LEVEL = trimws(as.character(PW_WAGE_LEVEL)),
      NEW_EMPLOYMENT = suppressWarnings(as.numeric(NEW_EMPLOYMENT)),
      SOC_CODE = as.character(SOC_CODE),
      SOC_TITLE = as.character(SOC_TITLE),
      EMPLOYER_NAME = as.character(EMPLOYER_NAME),
      WORKSITE_STATE = as.character(WORKSITE_STATE)
    )
}

dedupe_latest_case <- function(df) {
  df %>%
    arrange(CASE_NUMBER, DECISION_DATE) %>%
    group_by(CASE_NUMBER) %>%
    slice_max(order_by = DECISION_DATE, n = 1, with_ties = FALSE) %>%
    ungroup()
}

# -------------------------------------------------------------------
# 3. Matched nine-month periods
# -------------------------------------------------------------------

fy2025_9m_raw <- bind_rows(
  prepare_lca(q1_2025),
  prepare_lca(q2_2025),
  prepare_lca(q3_2025)
)

fy2025_9m <- dedupe_latest_case(fy2025_9m_raw)
fy2026_9m <- prepare_lca(fy2026_q3)

# Verify the intended decision-date windows.
stopifnot(
  min(fy2025_9m$DECISION_DATE, na.rm = TRUE) == as.Date("2024-10-01"),
  max(fy2025_9m$DECISION_DATE, na.rm = TRUE) == as.Date("2025-06-30"),
  min(fy2026_9m$DECISION_DATE, na.rm = TRUE) == as.Date("2025-10-01"),
  max(fy2026_9m$DECISION_DATE, na.rm = TRUE) == as.Date("2026-06-30")
)

sample_audit <- tibble(
  Period = c("FY2025 Q1-Q3 before deduplication",
             "FY2025 Q1-Q3 after deduplication",
             "FY2026 Q1-Q3"),
  Rows = c(nrow(fy2025_9m_raw), nrow(fy2025_9m), nrow(fy2026_9m)),
  Unique_Cases = c(
    n_distinct(fy2025_9m_raw$CASE_NUMBER),
    n_distinct(fy2025_9m$CASE_NUMBER),
    n_distinct(fy2026_9m$CASE_NUMBER)
  )
)

print(sample_audit)
write.csv(sample_audit, "results/sample_audit.csv", row.names = FALSE)

# -------------------------------------------------------------------
# 4. Analytical samples
# -------------------------------------------------------------------

make_h1b_sample <- function(df) {
  df %>%
    filter(
      VISA_CLASS == "H-1B",
      CASE_STATUS == "Certified",
      PW_WAGE_LEVEL %in% c("I", "II", "III", "IV")
    )
}

h1b_2025 <- make_h1b_sample(fy2025_9m)
h1b_2026 <- make_h1b_sample(fy2026_9m)

analytical_sample_summary <- tibble(
  Period = c("FY2025 Q1-Q3", "FY2026 Q1-Q3"),
  Certified_H1B_LCAs = c(nrow(h1b_2025), nrow(h1b_2026)),
  New_Employment_Positions = c(
    sum(h1b_2025$NEW_EMPLOYMENT, na.rm = TRUE),
    sum(h1b_2026$NEW_EMPLOYMENT, na.rm = TRUE)
  )
)

print(analytical_sample_summary)
write.csv(
  analytical_sample_summary,
  "results/analytical_sample_summary.csv",
  row.names = FALSE
)

# -------------------------------------------------------------------
# 5. Wage-level counterfactual
# -------------------------------------------------------------------

wage_weights <- tibble(
  PW_WAGE_LEVEL = c("I", "II", "III", "IV"),
  weight = c(1, 2, 3, 4)
)

make_counterfactual <- function(data) {
  data %>%
    group_by(PW_WAGE_LEVEL) %>%
    summarise(
      applications = n(),
      new_employment = sum(NEW_EMPLOYMENT, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    left_join(wage_weights, by = "PW_WAGE_LEVEL") %>%
    mutate(
      baseline_share = new_employment / sum(new_employment),
      weighted_count = new_employment * weight,
      weighted_share = weighted_count / sum(weighted_count),
      change_pp = 100 * (weighted_share - baseline_share)
    )
}

cf_2025 <- make_counterfactual(h1b_2025)
cf_2026 <- make_counterfactual(h1b_2026)

table1_final <- bind_rows(
  cf_2025 %>% mutate(Period = "FY2025 Q1-Q3"),
  cf_2026 %>% mutate(Period = "FY2026 Q1-Q3")
) %>%
  transmute(
    Period,
    Level = PW_WAGE_LEVEL,
    New_Employment = new_employment,
    Baseline_Percent = round(100 * baseline_share, 1),
    Weighted_Percent = round(100 * weighted_share, 1),
    Change_pp = round(change_pp, 1)
  )

print(table1_final)
write.csv(table1_final, "results/Table_1_Final.csv", row.names = FALSE)

# -------------------------------------------------------------------
# 6. SOC major-group analysis
# -------------------------------------------------------------------

h1b_2025 <- h1b_2025 %>%
  mutate(SOC_MAJOR = str_extract(SOC_CODE, "^[0-9]{2}"))

h1b_2026 <- h1b_2026 %>%
  mutate(SOC_MAJOR = str_extract(SOC_CODE, "^[0-9]{2}"))

valid_soc_major <- c(
  "11", "13", "15", "17", "19", "21", "23", "25", "27", "29", "31",
  "33", "35", "37", "39", "41", "43", "45", "47", "49", "51", "53"
)

soc_names <- tibble(
  SOC_MAJOR = valid_soc_major,
  Occupation_Group = c(
    "Management",
    "Business and Financial Operations",
    "Computer and Mathematical",
    "Architecture and Engineering",
    "Life, Physical, and Social Science",
    "Community and Social Service",
    "Legal",
    "Educational Instruction and Library",
    "Arts, Design, Entertainment, Sports, and Media",
    "Healthcare Practitioners and Technical",
    "Healthcare Support",
    "Protective Service",
    "Food Preparation and Serving Related",
    "Building and Grounds Cleaning and Maintenance",
    "Personal Care and Service",
    "Sales and Related",
    "Office and Administrative Support",
    "Farming, Fishing, and Forestry",
    "Construction and Extraction",
    "Installation, Maintenance, and Repair",
    "Production",
    "Transportation and Material Moving"
  )
)

soc_exclusions <- bind_rows(
  h1b_2025 %>%
    filter(!SOC_MAJOR %in% valid_soc_major) %>%
    summarise(
      Period = "FY2025 Q1-Q3",
      Excluded_Records = n(),
      Excluded_New_Employment = sum(NEW_EMPLOYMENT, na.rm = TRUE)
    ),
  h1b_2026 %>%
    filter(!SOC_MAJOR %in% valid_soc_major) %>%
    summarise(
      Period = "FY2026 Q1-Q3",
      Excluded_Records = n(),
      Excluded_New_Employment = sum(NEW_EMPLOYMENT, na.rm = TRUE)
    )
)

print(soc_exclusions)
write.csv(soc_exclusions, "results/soc_exclusions.csv", row.names = FALSE)

make_group_counterfactual <- function(data, group_var) {
  data %>%
    group_by({{ group_var }}, PW_WAGE_LEVEL) %>%
    summarise(
      new_employment = sum(NEW_EMPLOYMENT, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    left_join(wage_weights, by = "PW_WAGE_LEVEL") %>%
    mutate(weighted_count = new_employment * weight) %>%
    group_by({{ group_var }}) %>%
    summarise(
      new_employment = sum(new_employment),
      weighted_count = sum(weighted_count),
      .groups = "drop"
    ) %>%
    mutate(
      baseline_share = new_employment / sum(new_employment),
      weighted_share = weighted_count / sum(weighted_count),
      change_pp = 100 * (weighted_share - baseline_share)
    )
}

soc_change_2025 <- h1b_2025 %>%
  filter(SOC_MAJOR %in% valid_soc_major) %>%
  make_group_counterfactual(SOC_MAJOR)

soc_change_2026 <- h1b_2026 %>%
  filter(SOC_MAJOR %in% valid_soc_major) %>%
  make_group_counterfactual(SOC_MAJOR)

major_occ_final <- full_join(
  soc_change_2025 %>%
    select(
      SOC_MAJOR,
      baseline_2025 = baseline_share,
      change_2025 = change_pp
    ),
  soc_change_2026 %>%
    select(
      SOC_MAJOR,
      baseline_2026 = baseline_share,
      change_2026 = change_pp
    ),
  by = "SOC_MAJOR"
) %>%
  filter(
    baseline_2025 >= 0.01 |
      baseline_2026 >= 0.01
  ) %>%
  left_join(soc_names, by = "SOC_MAJOR") %>%
  mutate(
    baseline_2025 = round(100 * baseline_2025, 2),
    baseline_2026 = round(100 * baseline_2026, 2),
    change_2025 = round(change_2025, 2),
    change_2026 = round(change_2026, 2)
  )

print(major_occ_final)
write.csv(
  major_occ_final,
  "results/Occupation_Results_Final.csv",
  row.names = FALSE
)

# -------------------------------------------------------------------
# 7. Employer and state analyses
# -------------------------------------------------------------------

employer_change_2025 <- make_group_counterfactual(h1b_2025, EMPLOYER_NAME)
employer_change_2026 <- make_group_counterfactual(h1b_2026, EMPLOYER_NAME)

state_change_2025 <- make_group_counterfactual(h1b_2025, WORKSITE_STATE)
state_change_2026 <- make_group_counterfactual(h1b_2026, WORKSITE_STATE)

write.csv(
  employer_change_2025,
  "results/Employer_FY2025_Final.csv",
  row.names = FALSE
)
write.csv(
  employer_change_2026,
  "results/Employer_FY2026_Final.csv",
  row.names = FALSE
)
write.csv(
  state_change_2025,
  "results/State_FY2025_Final.csv",
  row.names = FALSE
)
write.csv(
  state_change_2026,
  "results/State_FY2026_Final.csv",
  row.names = FALSE
)

# -------------------------------------------------------------------
# 8. Figure 1: wage-level distributions
# -------------------------------------------------------------------

figure1_data <- bind_rows(
  cf_2025 %>% mutate(Period = "FY2025 Q1-Q3"),
  cf_2026 %>% mutate(Period = "FY2026 Q1-Q3")
) %>%
  select(Period, PW_WAGE_LEVEL, baseline_share, weighted_share) %>%
  pivot_longer(
    cols = c(baseline_share, weighted_share),
    names_to = "Distribution",
    values_to = "Share"
  ) %>%
  mutate(
    Distribution = recode(
      Distribution,
      baseline_share = "Baseline",
      weighted_share = "Wage-weighted"
    ),
    Share = 100 * Share,
    PW_WAGE_LEVEL = factor(
      PW_WAGE_LEVEL,
      levels = c("I", "II", "III", "IV")
    )
  )

fig1 <- ggplot(
  figure1_data,
  aes(x = PW_WAGE_LEVEL, y = Share, fill = Distribution)
) +
  geom_col(
    position = position_dodge(width = 0.8),
    width = 0.7
  ) +
  geom_text(
    aes(label = sprintf("%.1f%%", Share)),
    position = position_dodge(width = 0.8),
    vjust = -0.4,
    size = 3
  ) +
  facet_wrap(~Period) +
  scale_y_continuous(
    labels = function(x) paste0(x, "%"),
    expand = expansion(mult = c(0, 0.12))
  ) +
  labs(
    x = "OEWS Wage Level",
    y = "Share of New-Employment Positions",
    fill = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "top")

ggsave(
  "figures/Figure_1.png",
  fig1,
  width = 9,
  height = 5.5,
  dpi = 300
)

# -------------------------------------------------------------------
# 9. Figure 2: occupation-group redistribution
# -------------------------------------------------------------------

figure2_data <- major_occ_final %>%
  transmute(
    Occupation_Group,
    `FY2025 Q1-Q3` = change_2025,
    `FY2026 Q1-Q3` = change_2026
  ) %>%
  pivot_longer(
    cols = starts_with("FY"),
    names_to = "Period",
    values_to = "Change_pp"
  )

fig2 <- ggplot(
  figure2_data,
  aes(
    x = Change_pp,
    y = reorder(Occupation_Group, Change_pp),
    fill = Period
  )
) +
  geom_col(
    position = position_dodge(width = 0.8),
    width = 0.7
  ) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    x = "Change in Representation (percentage points)",
    y = NULL,
    fill = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "top")

ggsave(
  "figures/Figure_2.png",
  fig2,
  width = 10,
  height = 6.5,
  dpi = 300
)

# -------------------------------------------------------------------
# 10. Figure 3: employer redistribution
# -------------------------------------------------------------------

employer_figure_data <- bind_rows(
  employer_change_2025 %>%
    arrange(desc(new_employment)) %>%
    slice_head(n = 10) %>%
    mutate(Period = "FY2025 Q1-Q3"),
  employer_change_2026 %>%
    arrange(desc(new_employment)) %>%
    slice_head(n = 10) %>%
    mutate(Period = "FY2026 Q1-Q3")
)

fig3 <- ggplot(
  employer_figure_data,
  aes(x = change_pp, y = reorder(EMPLOYER_NAME, change_pp))
) +
  geom_col() +
  geom_vline(xintercept = 0, linetype = "dashed") +
  facet_wrap(~Period, scales = "free_y") +
  labs(
    x = "Change in Representation (percentage points)",
    y = NULL
  ) +
  theme_minimal(base_size = 10)

ggsave(
  "figures/Figure_3.png",
  fig3,
  width = 11,
  height = 7,
  dpi = 300
)

# -------------------------------------------------------------------
# 11. Figure 4: worksite-state redistribution
# -------------------------------------------------------------------

state_figure_data <- bind_rows(
  state_change_2025 %>%
    arrange(desc(new_employment)) %>%
    slice_head(n = 10) %>%
    mutate(Period = "FY2025 Q1-Q3"),
  state_change_2026 %>%
    arrange(desc(new_employment)) %>%
    slice_head(n = 10) %>%
    mutate(Period = "FY2026 Q1-Q3")
)

fig4 <- ggplot(
  state_figure_data,
  aes(x = change_pp, y = reorder(WORKSITE_STATE, change_pp))
) +
  geom_col() +
  geom_vline(xintercept = 0, linetype = "dashed") +
  facet_wrap(~Period, scales = "free_y") +
  labs(
    x = "Change in Representation (percentage points)",
    y = "Worksite State"
  ) +
  theme_minimal(base_size = 11)

ggsave(
  "figures/Figure_4.png",
  fig4,
  width = 9,
  height = 6.5,
  dpi = 300
)

# -------------------------------------------------------------------
# 12. Optional FY2025 full-year sensitivity analysis
# -------------------------------------------------------------------

fy2025_full <- bind_rows(
  prepare_lca(q1_2025),
  prepare_lca(q2_2025),
  prepare_lca(q3_2025),
  prepare_lca(q4_2025)
) %>%
  dedupe_latest_case()

h1b_2025_full <- make_h1b_sample(fy2025_full)
cf_2025_full <- make_counterfactual(h1b_2025_full)

write.csv(
  cf_2025_full,
  "results/FY2025_Full_Year_Sensitivity.csv",
  row.names = FALSE
)

cat("\nAnalysis complete.\n")
cat("Primary matched periods: FY2025 Q1-Q3 vs FY2026 Q1-Q3.\n")
cat("Results written to results/ and figures/.\n")
