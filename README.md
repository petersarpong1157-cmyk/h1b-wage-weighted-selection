# Wage-Weighted H-1B Selection and Employment Distribution

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23486897.svg)](https://doi.org/10.5281/zenodo.23486897)

Reproducibility materials for Peter Sarpong's study of how the FY2027 H-1B wage-level weighting structure changes the distribution of U.S. Department of Labor (DOL) Labor Condition Application (LCA) new-employment positions across wage levels, occupations, reported employer names, and worksite states.

> **Important update:** The analysis now uses matched nine-month periods rather than comparing FY2025 Q4 alone with the cumulative FY2026 Q3 file. FY2025 Q1-Q3 covers October 1, 2024 through June 30, 2025; FY2026 Q1-Q3 covers October 1, 2025 through June 30, 2026.


## October 19–20, 2026: measurement-sensitivity extension (Zenodo v3.7.0 published)

An additional labour-market measurement study investigates the difference between weighting LCA applications and weighting requested new-employment positions. **The positive-position-only check materially changes the original full-sample result**, so claims of invariance across population definitions are not supported.

- FY2025 Level II: full-sample application-versus-position discrepancy **+6.63 pp**; top-ten-standardized-name exclusion **+7.44 pp**; P99 position cap **+7.25 pp**; positive-position applications only **−1.35 pp**.
- FY2026 Level II: corresponding discrepancies **+4.59**, **+3.28**, **+4.53**, and **+0.589 pp**.
- Within-occupation components dominate the full-population symmetric decomposition (FY2025 **5.99 pp**; FY2026 **3.87 pp**). These are accounting decompositions, not causal effects.

Read the [October 19 verified console-results and limitations](results/2026-10-19-labour-measurement-extension.md). The optional sensitivity script is [here](analysis/H1B_Optional_Tail_Trim_Sensitivity.R).

**Archive status:** Zenodo v3.7.0 is published with version DOI [10.5281/zenodo.23486897](https://doi.org/10.5281/zenodo.23486897). All final CSVs 09–19 are under [`results/2026-10-19/`](results/2026-10-19/), the R extensions are under [`analysis/`](analysis/), and [Figure 5](H1B_figure5_decomposition.png) is in the repository root. Manuscripts and cover letters are intentionally excluded. **Note:** this README and `CITATION.cff` were updated on `main` *after* the v3.7.0 release; that published release snapshot remains immutable and may still contain the previous DOI in citation metadata.

## October 2026 independent audit and robustness update

The source-workbook audit reconciled both primary matched-period samples exactly to the manuscript: **401,626 LCAs / 235,613 new-employment positions** in FY2025 Q1–Q3 and **351,375 LCAs / 241,528 new-employment positions** in FY2026 Q1–Q3.

Sensitivity checks using one unit per LCA and excluding the ten largest reported employer names (in each period) retain the broad negative Level I and positive Level III–IV redistribution pattern. **Level II is sensitive to the unit:** in FY2025 Q1–Q3 its change is +1.00 percentage point when weighting new-employment positions, but −5.63 percentage points when weighting application counts.

The analyzed wage-level subset excludes **33,463 LCAs / 27,583 new positions** in FY2025 and **40,800 LCAs / 33,788 new positions** in FY2026 that lack an observed wage level I–IV.

**Interpretation caution:** `PW_WAGE_LEVEL` is the employer-reported *prevailing-wage* level in the DOL LCA file and is not necessarily the offered-wage-equivalent level governing USCIS FY2027 weighted selection. The findings are LCA-based distributional counterfactuals, **not** estimates of beneficiaries selected, visa outcomes, or causal effects.

See [the independent audit results](results/2026-10-13-independent-audit.md) for tabulated sensitivity findings, sample reconciliation, exclusions, and limitations.

**Archive status:** v3.6.7 (DOI `10.5281/zenodo.23353950`) is the prior Zenodo release. The October 19 measurement extension is newer than that release and has not yet been deposited as a complete reproducible Zenodo version.

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

To reproduce the **independent audit and robustness outputs**, download the DOL workbooks (see `data/README.md`), set `input_dir` in the low-memory script, then run in a clean R session:

```r
source("analysis/H1B_Independent_Audit_Low_Memory.R")
```

The resulting CSVs correspond to the checked-in `results/01_*.csv` through `results/08_*.csv` and the deduplication tie-count report. The script was executed by the researcher in R 4.5.2 on Windows 11. This update does not independently establish cross-platform reproducibility. For the original occupation, employer and state figure pipeline, use `analysis/h1b-wage-weighted-selection.R`.

The original figure-generation script:

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


## Administrative measurement sensitivity extension (21 October 2026)

The following verified analytical output files extend the LCA comparison across all four reported prevailing-wage levels (I–IV) for FY2025 Q1–Q3 and FY2026 Q1–Q3:

- [20_all_wage_levels_measurement.csv](results/2026-10-19/20_all_wage_levels_measurement.csv): application and requested-position shares, weighted shares, differences in percentage points, and zero-position fractions by level and period.
- [21_three_measurement_definitions.csv](results/2026-10-19/21_three_measurement_definitions.csv): distributions under all-application counts, positive-new-employment application counts, and requested-new-employment position counts.
- [22_zero_vs_positive_count_decomposition.csv](results/2026-10-19/22_zero_vs_positive_count_decomposition.csv): exact arithmetic decomposition of the application-versus-position distribution-change discrepancy into zero-position inclusion and positive-position count components.

Validation against prior sample totals: FY2025, 401,626 applications and 235,613 requested new-employment positions; FY2026, 351,375 applications and 241,528 positions. All eight wage-level decomposition identities reconcile (reported reconciliation error: zero). Differences are descriptive and must not be interpreted as causal effects, actual USCIS lottery probabilities, or proof that zero-position applications are erroneous. The complete source script is now committed at [analysis/H1B_Independent_Audit_Low_Memory_Complete_Through_22.R](analysis/H1B_Independent_Audit_Low_Memory_Complete_Through_22.R). It requires the original DOL Excel input workbooks and a locally configured `input_dir`; the outputs have been verified against the author's R console and uploaded CSVs, but a fresh end-to-end reproduction from the raw workbooks was not performed in this GitHub update.


To check the saved CSVs without downloading the source workbooks, run `Rscript analysis/Verify_Measurement_CSV_20_to_22.R` from the repository root. This base-R checker validates the sample totals, shares, and decomposition arithmetic in files 20–22; it is not a substitute for rerunning the raw-data pipeline.


## October 22, 2026 — Final Monte Carlo reproducibility files (post-v3.8.9 commit)

The 15-setting, 7,500-replication final simulation is now stored on the main branch, including:

- [Original R simulation generator](analysis/H1B_Final_Permutation_Calibration.R), with five data-generating scenarios, three sample sizes, 500 replications each, and 999 permutations per replication.
- [All 7,500 consolidated replication-level results](results/36_final_permutation_replications.csv).
- [Final 15-setting simulation summary](results/37_final_permutation_summary.csv).
- [Base R figure-generation script](analysis/H1B_Generate_Final_Figures.R).
- [Reconciliation summary](verification/H1B_Final_Verification_Report.csv) and [accessible batch-file audit](verification/H1B_Final_File_Audit.csv).
- [Reconciliation limitations and research interpretation](verification/MONTE_CARLO_2026-10-22_STATUS.md).

**Critical archival distinction:** GitHub/Zenodo `v3.8.9` (DOI [10.5281/zenodo.23575464](https://doi.org/10.5281/zenodo.23575464)) was published **before** the final consolidated CSV and original simulation R script were committed to `main`. Therefore that DOI **does not automatically archive these subsequent commits**. A new GitHub release/tag and confirmation of a new Zenodo version-specific DOI are required to archive the complete main-branch materials. Do not retag or overwrite the published `v3.8.9` archive.

### Run the archived figures

```sh
Rscript analysis/H1B_Generate_Final_Figures.R results/37_final_permutation_summary.csv figures
```

The original simulation generator can be rerun in a fresh R directory, producing `permutation_calibration_final/`. Existing batches are intentionally preserved on reruns. It is not necessary to rerun 7,500 simulations to redraw the published figures.

**Verification caveat:** The consolidated dataset has 7,500 unique records (15 × 500). The 200 accessible original batch CSVs (5,000 replications) reconciled with zero value mismatches. The remaining 2,500 original batch records were not independently reconciled because those batches were not accessible in the audited snapshot. This is a completeness limit of the batch-file audit, not proof of absent simulation runs.

The R permutation test assesses exchangeability of position counts across categories; it is **not** a test of whether a practical 5-percentage-point total-variation threshold is exceeded. The 1–4 wage-level weights are illustrative; DOL prevailing wage levels are not verified USCIS offered-wage selection categories.
