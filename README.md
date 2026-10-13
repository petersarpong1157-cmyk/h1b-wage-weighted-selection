# Wage-Weighted H-1B Selection and Employment Distribution

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23282614.svg)](https://doi.org/10.5281/zenodo.23282614)

Reproducibility materials for Peter Sarpong's study of how the FY2027 H-1B wage-level weighting structure changes the distribution of U.S. Department of Labor (DOL) Labor Condition Application (LCA) new-employment positions across wage levels, occupations, reported employer names, and worksite states.

> **Important update:** The analysis now uses matched nine-month periods rather than comparing FY2025 Q4 alone with the cumulative FY2026 Q3 file. FY2025 Q1-Q3 covers October 1, 2024 through June 30, 2025; FY2026 Q1-Q3 covers October 1, 2025 through June 30, 2026.


## October 2026 independent audit and robustness update

The source-workbook audit reconciled both primary matched-period samples exactly to the manuscript: **401,626 LCAs / 235,613 new-employment positions** in FY2025 Q1–Q3 and **351,375 LCAs / 241,528 new-employment positions** in FY2026 Q1–Q3.

Sensitivity checks using one unit per LCA and excluding the ten largest reported employer names (in each period) retain the broad negative Level I and positive Level III–IV redistribution pattern. **Level II is sensitive to the unit:** in FY2025 Q1–Q3 its change is +1.00 percentage point when weighting new-employment positions, but −5.63 percentage points when weighting application counts.

The analyzed wage-level subset excludes **33,463 LCAs / 27,583 new positions** in FY2025 and **40,800 LCAs / 33,788 new positions** in FY2026 that lack an observed wage level I–IV.

**Interpretation caution:** `PW_WAGE_LEVEL` is the employer-reported *prevailing-wage* level in the DOL LCA file and is not necessarily the offered-wage-equivalent level governing USCIS FY2027 weighted selection. The findings are LCA-based distributional counterfactuals, **not** estimates of beneficiaries selected, visa outcomes, or causal effects.

See [the independent audit results](results/2026-10-13-independent-audit.md) for tabulated sensitivity findings, sample reconciliation, exclusions, and limitations.

**Archive status:** This GitHub documentation update does *not* update the existing Zenodo DOI. The revised standalone R audit script and its raw output CSVs are not yet archived in this commit, so do not treat the repository as a complete reproduction package for the new robustness tables until those are added and tested.

## Study design

This project is an **LCA-based distributional counterfactual**. It does not simulate USCIS beneficiary selection and does not estimate actual H-1B selection probabilities, selected beneficiaries, petitions, or visa issuances. DOL LCA records do not identify the universe of unique cap-subject beneficiaries or USCIS registrations.

The primary analytical population consists of certified H-1B LCAs with observed OEWS wage levels I-IV. The analysis uses `NEW_EMPLOYMENT` positions as a proxy for new H-1B employment demand.

The counterfactual applies wage-level weights:

- Level I: 1
- Level II: 2
- Level III: 3
- Level IV: 4

For each wage level or subgroup, the weighted quantity is `NEW_EMPLOYMENT × wage-level weight`. Weighted shares are then compared with baseline LCA-position shares.

## Corrected matched-period construction

### FY2025 Q1-Q3

The FY2025 Q1, Q2, and Q3 disclosure workbooks are combined. The combined file contains 477,972 rows and 476,836 unique `CASE_NUMBER` values. Because 1,136 case numbers appear more than once across quarterly files, the analysis retains the latest determination date for each case before applying the analytical filters.

The resulting analytical sample contains:

- **401,626** certified H-1B LCAs with observed Wage Levels I-IV
- **235,613** reported new-employment positions

### FY2026 Q1-Q3

The FY2026 Q3 disclosure workbook is cumulative from October 1, 2025 through June 30, 2026 and contains no duplicate case numbers in the matched-period construction used here.

The resulting analytical sample contains:

- **351,375** certified H-1B LCAs with observed Wage Levels I-IV
- **241,528** reported new-employment positions

## Main wage-level results

| Period | Wage level | New employment | Baseline % | Weighted % | Change (pp) |
|---|---:|---:|---:|---:|---:|
| FY2025 Q1-Q3 | I | 85,657 | 36.4 | 18.6 | -17.7 |
| FY2025 Q1-Q3 | II | 95,284 | 40.4 | 41.4 | +1.0 |
| FY2025 Q1-Q3 | III | 35,092 | 14.9 | 22.9 | +8.0 |
| FY2025 Q1-Q3 | IV | 19,580 | 8.3 | 17.0 | +8.7 |
| FY2026 Q1-Q3 | I | 74,940 | 31.0 | 14.5 | -16.5 |
| FY2026 Q1-Q3 | II | 89,128 | 36.9 | 34.5 | -2.4 |
| FY2026 Q1-Q3 | III | 46,618 | 19.3 | 27.1 | +7.8 |
| FY2026 Q1-Q3 | IV | 30,842 | 12.8 | 23.9 | +11.1 |

The matched-period analysis shows a consistent redistribution away from Wage Level I and toward Levels III and IV. Level II behaves differently across periods: it increases slightly in FY2025 Q1-Q3 and declines in FY2026 Q1-Q3.

## Distribution across occupations, employers, and states

Among occupational groups representing at least 1% of baseline new-employment positions in either matched period:

- Computer and Mathematical occupations increase by **2.65 pp** in FY2025 and **2.34 pp** in FY2026.
- Architecture and Engineering increases by **0.88 pp** and **1.63 pp**.
- Healthcare Practitioners and Technical declines by **3.14 pp** and **4.46 pp**.
- Educational Instruction and Library declines by **0.77 pp** and **0.44 pp**.

The employer and geographic analyses also show heterogeneous redistribution. Employer names are used as reported and are not manually consolidated across potentially affiliated entities or naming variants. Worksite-state results describe changes in LCA-position representation, not projected visa allocations.

## SOC cleaning

Occupation analysis is restricted to valid two-digit Standard Occupational Classification major groups. Six FY2025 records representing two new-employment positions and three FY2026 records representing two positions are excluded from the occupation-specific calculations because their extracted major-group prefixes are nonstandard.

## Data

The analysis uses public DOL Office of Foreign Labor Certification LCA disclosure data.

Place these workbooks in `data/raw/`:

- `LCA_Disclosure_Data_FY2025_Q1.xlsx`
- `LCA_Disclosure_Data_FY2025_Q2.xlsx`
- `LCA_Disclosure_Data_FY2025_Q3.xlsx`
- `LCA_Disclosure_Data_FY2025_Q4.xlsx`
- `LCA_Disclosure_Data_FY2026_Q3.xlsx`

FY2025 Q4 is not part of the primary matched-period comparison. It is used only for the optional FY2025 full-year sensitivity analysis.

The original DOL Excel files are not stored in this repository.

## Reproducibility

Run:

```r
source("analysis/h1b-wage-weighted-selection.R")
```

The script:

1. loads and harmonizes the quarterly DOL disclosure files;
2. constructs the matched nine-month periods;
3. resolves duplicate FY2025 case numbers by retaining the latest determination;
4. applies the H-1B / Certified / Wage Level I-IV filters;
5. calculates wage-level, occupation, employer, and state counterfactuals;
6. writes corrected tables to `results/`;
7. writes Figures 1-4 to `figures/`; and
8. produces an optional FY2025 full-year sensitivity output.

## Interpretation

The analysis evaluates redistribution in an LCA-based proxy for new H-1B employment demand. It should **not** be interpreted as a simulation of actual USCIS beneficiary-level selection, an estimate of individual selection probabilities, a forecast of visa allocations, or a causal estimate of policy effects.

## Author

Peter Sarpong  
Independent Researcher, United States

## Citation and archive status

Zenodo DOI: **10.5281/zenodo.23282614**

The corrected matched-period release is archived on Zenodo under the DOI above.

## License

The original code and documentation in this repository are licensed under the **MIT License**. See [LICENSE](LICENSE).

The U.S. Department of Labor source data are not redistributed with this repository and are not covered by the repository's MIT license.
