# Data sources

This repository does not redistribute the original DOL LCA disclosure workbooks.

The study uses the U.S. Department of Labor, Office of Foreign Labor Certification LCA disclosure data and corresponding record layouts for:

1. FY2025 Q4 (full FY2025)
2. FY2026 Q3 (partial FY2026 through June 30, 2026)

Place the downloaded source workbooks in a local `data/raw/` directory using these filenames:

- `LCA_Disclosure_Data_FY2025_Q4.xlsx`
- `LCA_Disclosure_Data_FY2026_Q3.xlsx`

Primary filters used in the analysis:

- `VISA_CLASS == "H-1B"`
- `CASE_STATUS == "Certified"`
- `PW_WAGE_LEVEL` in I, II, III, IV

The primary counterfactual quantity is `NEW_EMPLOYMENT` positions. These positions are not unique beneficiaries, USCIS registrations, petitions, selections, or visa issuances.
