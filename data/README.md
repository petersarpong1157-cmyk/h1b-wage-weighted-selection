# Data sources

This repository does not redistribute the original U.S. Department of Labor (DOL) Labor Condition Application disclosure workbooks.

## Primary matched-period analysis

The primary analysis compares two equivalent nine-month windows:

- **FY2025 Q1-Q3:** October 1, 2024 through June 30, 2025
- **FY2026 Q1-Q3:** October 1, 2025 through June 30, 2026

Place the official DOL workbooks in a local `data/raw/` directory using these filenames:

- `LCA_Disclosure_Data_FY2025_Q1.xlsx`
- `LCA_Disclosure_Data_FY2025_Q2.xlsx`
- `LCA_Disclosure_Data_FY2025_Q3.xlsx`
- `LCA_Disclosure_Data_FY2025_Q4.xlsx`
- `LCA_Disclosure_Data_FY2026_Q3.xlsx`

FY2025 Q4 is used only for the optional full-year FY2025 sensitivity analysis. It is not included in the primary matched-period FY2025 Q1-Q3 comparison.

## Case handling

The FY2025 Q1-Q3 quarterly files contain some `CASE_NUMBER` values that appear in more than one quarterly disclosure file following later case determinations. The reproducibility script combines Q1-Q3 and retains the latest `DECISION_DATE` for each `CASE_NUMBER` before applying the analytical filters.

The combined FY2025 Q1-Q3 source data contain 477,972 rows and 476,836 unique case numbers, so 1,136 duplicate case numbers are resolved in this step.

## Primary analytical filters

- `VISA_CLASS == "H-1B"`
- `CASE_STATUS == "Certified"`
- `PW_WAGE_LEVEL` in I, II, III, IV

The primary counterfactual quantity is `NEW_EMPLOYMENT`.

After cleaning and filtering:

- FY2025 Q1-Q3: **401,626 LCAs** and **235,613 new-employment positions**
- FY2026 Q1-Q3: **351,375 LCAs** and **241,528 new-employment positions**

These LCA positions are not unique beneficiaries, USCIS registrations, petitions, selections, or visa issuances.

## Occupation analysis

Occupations are grouped by valid two-digit SOC major groups. Six FY2025 records representing two new-employment positions and three FY2026 records representing two positions are excluded from the occupation-specific analysis because their extracted major-group prefixes are nonstandard.
