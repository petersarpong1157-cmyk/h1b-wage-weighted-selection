# Reproducibility script
# Wage-Weighted H-1B Selection and the Distribution of New-Employment Positions
# Author: Peter Sarpong
#
# Data are not redistributed with this repository.
# Download the official DOL LCA disclosure workbooks and place them in data/raw/.

library(dplyr)
library(ggplot2)
library(tidyr)
library(readxl)

fy2025 <- read_excel("data/raw/LCA_Disclosure_Data_FY2025_Q4.xlsx")
fy2026 <- read_excel("data/raw/LCA_Disclosure_Data_FY2026_Q3.xlsx")

dim(fy2025)
dim(fy2026)

# Primary analytical sample
h1b_2025 <- fy2025 %>%
  filter(
    VISA_CLASS == "H-1B",
    CASE_STATUS == "Certified",
    PW_WAGE_LEVEL %in% c("I", "II", "III", "IV")
  )

h1b_2026 <- fy2026 %>%
  filter(
    VISA_CLASS == "H-1B",
    CASE_STATUS == "Certified",
    PW_WAGE_LEVEL %in% c("I", "II", "III", "IV")
  )

# Wage-level weights used in the distributional counterfactual
wage_weights <- tibble(
  PW_WAGE_LEVEL = c("I", "II", "III", "IV"),
  weight = c(1, 2, 3, 4)
)

make_counterfactual <- function(data) {
  data %>%
    group_by(PW_WAGE_LEVEL) %>%
    summarise(
      new_employment = sum(NEW_EMPLOYMENT, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    left_join(wage_weights, by = "PW_WAGE_LEVEL") %>%
    mutate(
      baseline_share = new_employment / sum(new_employment),
      weighted_count = new_employment * weight,
      weighted_share = weighted_count / sum(weighted_count),
      change_pp = (weighted_share - baseline_share) * 100
    )
}

cf_2025 <- make_counterfactual(h1b_2025)
cf_2026 <- make_counterfactual(h1b_2026)

main_table <- bind_rows(
  cf_2025 %>% mutate(period = "FY2025"),
  cf_2026 %>% mutate(period = "FY2026 Q3")
) %>%
  mutate(
    baseline_pct = round(baseline_share * 100, 1),
    weighted_pct = round(weighted_share * 100, 1),
    change_pp = round(change_pp, 1)
  ) %>%
  select(
    Period = period,
    Wage_Level = PW_WAGE_LEVEL,
    New_Employment = new_employment,
    Baseline_Pct = baseline_pct,
    Weighted_Pct = weighted_pct,
    Change_PP = change_pp
  ) %>%
  arrange(Period, factor(Wage_Level, levels = c("I", "II", "III", "IV")))

print(main_table)

# SOC major-group analysis
h1b_2025 <- h1b_2025 %>% mutate(SOC_MAJOR = substr(SOC_CODE, 1, 2))
h1b_2026 <- h1b_2026 %>% mutate(SOC_MAJOR = substr(SOC_CODE, 1, 2))

valid_soc_major <- c(
  "11", "13", "15", "17", "19", "21", "23", "25", "27", "29", "31",
  "33", "35", "37", "39", "41", "43", "45", "47", "49", "51", "53"
)

soc_names <- tibble(
  SOC_MAJOR = valid_soc_major,
  Occupation_Group = c(
    "Management", "Business and Financial Operations", "Computer and Mathematical",
    "Architecture and Engineering", "Life, Physical, and Social Science",
    "Community and Social Service", "Legal", "Educational Instruction and Library",
    "Arts, Design, Entertainment, Sports, and Media", "Healthcare Practitioners and Technical",
    "Healthcare Support", "Protective Service", "Food Preparation and Serving Related",
    "Building and Grounds Cleaning and Maintenance", "Personal Care and Service",
    "Sales and Related", "Office and Administrative Support", "Farming, Fishing, and Forestry",
    "Construction and Extraction", "Installation, Maintenance, and Repair", "Production",
    "Transportation and Material Moving"
  )
)

make_group_counterfactual <- function(data, group_var) {
  data %>%
    group_by({{ group_var }}, PW_WAGE_LEVEL) %>%
    summarise(new_employment = sum(NEW_EMPLOYMENT, na.rm = TRUE), .groups = "drop") %>%
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
      change_pp = (weighted_share - baseline_share) * 100
    )
}

soc_change_2025 <- h1b_2025 %>%
  filter(SOC_MAJOR %in% valid_soc_major) %>%
  make_group_counterfactual(SOC_MAJOR)

soc_change_2026 <- h1b_2026 %>%
  filter(SOC_MAJOR %in% valid_soc_major) %>%
  make_group_counterfactual(SOC_MAJOR)

occupation_table <- bind_rows(
  soc_change_2025 %>% mutate(Period = "FY2025"),
  soc_change_2026 %>% mutate(Period = "FY2026 Q3")
) %>%
  left_join(soc_names, by = "SOC_MAJOR") %>%
  mutate(
    Baseline_Pct = baseline_share * 100,
    Weighted_Pct = weighted_share * 100,
    Change_PP = change_pp
  )

occupation_main <- occupation_table %>%
  group_by(SOC_MAJOR, Occupation_Group) %>%
  filter(any(Baseline_Pct >= 1)) %>%
  ungroup()

# Reported employer-name analysis. Names are retained as reported in DOL data.
employer_change_2025 <- make_group_counterfactual(h1b_2025, EMPLOYER_NAME)
employer_change_2026 <- make_group_counterfactual(h1b_2026, EMPLOYER_NAME)

# Worksite-state analysis
state_change_2025 <- make_group_counterfactual(h1b_2025, WORKSITE_STATE)
state_change_2026 <- make_group_counterfactual(h1b_2026, WORKSITE_STATE)

# Figure 1: wage-level distributions
figure1_data <- main_table %>%
  select(Period, Wage_Level, Baseline_Pct, Weighted_Pct) %>%
  pivot_longer(
    cols = c(Baseline_Pct, Weighted_Pct),
    names_to = "Distribution",
    values_to = "Percent"
  ) %>%
  mutate(
    Distribution = recode(
      Distribution,
      Baseline_Pct = "Baseline",
      Weighted_Pct = "Wage-weighted"
    ),
    Wage_Level = factor(Wage_Level, levels = c("I", "II", "III", "IV"))
  )

ggplot(figure1_data, aes(x = Wage_Level, y = Percent, fill = Distribution)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  facet_wrap(~Period) +
  labs(
    title = "Distribution of New-Employment Positions by Wage Level",
    subtitle = "Baseline and wage-weighted LCA-based distributions",
    x = "OEWS Wage Level",
    y = "Share of New-Employment Positions (%)",
    fill = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom", panel.grid.minor = element_blank())

# Figure 2: occupation groups meeting the pre-specified 1% baseline threshold
occupation_figure_data <- occupation_main %>%
  mutate(Period = factor(Period, levels = c("FY2025", "FY2026 Q3")))

ggplot(
  occupation_figure_data,
  aes(x = Change_PP, y = reorder(Occupation_Group, Change_PP), fill = Period)
) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(
    title = "Change in Occupational Representation Under Wage Weighting",
    subtitle = "Occupation groups with at least 1% of baseline new-employment positions in either period",
    x = "Change in Share (Percentage Points)",
    y = NULL,
    fill = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom", panel.grid.minor = element_blank())

# Figure 3: top 10 reported employer names by baseline new-employment positions
employer_figure_data <- bind_rows(
  employer_change_2025 %>% arrange(desc(new_employment)) %>% slice_head(n = 10) %>% mutate(Period = "FY2025"),
  employer_change_2026 %>% arrange(desc(new_employment)) %>% slice_head(n = 10) %>% mutate(Period = "FY2026 Q3")
) %>%
  mutate(Change_PP = change_pp)

ggplot(employer_figure_data, aes(x = Change_PP, y = reorder(EMPLOYER_NAME, Change_PP))) +
  geom_col() +
  geom_vline(xintercept = 0, linetype = "dashed") +
  facet_wrap(~Period, scales = "free_y") +
  labs(
    title = "Change in Employer Representation Under Wage Weighting",
    subtitle = "Top 10 employer names by baseline new-employment positions in each period",
    x = "Change in Share (Percentage Points)",
    y = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(panel.grid.minor = element_blank(), strip.text = element_text(size = 11))

# Figure 4: top 10 worksite states by baseline new-employment positions
state_figure_data <- bind_rows(
  state_change_2025 %>% arrange(desc(new_employment)) %>% slice_head(n = 10) %>% mutate(Period = "FY2025"),
  state_change_2026 %>% arrange(desc(new_employment)) %>% slice_head(n = 10) %>% mutate(Period = "FY2026 Q3")
) %>%
  mutate(Change_PP = change_pp)

ggplot(state_figure_data, aes(x = Change_PP, y = reorder(WORKSITE_STATE, Change_PP))) +
  geom_col() +
  geom_vline(xintercept = 0, linetype = "dashed") +
  facet_wrap(~Period, scales = "free_y") +
  labs(
    title = "Change in State Representation Under Wage Weighting",
    subtitle = "Top 10 worksite states by baseline new-employment positions in each period",
    x = "Change in Share (Percentage Points)",
    y = "Worksite State"
  ) +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank())
