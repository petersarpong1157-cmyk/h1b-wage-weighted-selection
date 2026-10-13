# Independent R audit — 13 October 2026

This document summarizes the results obtained by running a low-memory R audit on the U.S. Department of Labor LCA disclosure workbooks. These are **LCA prevailing-wage-level counterfactuals**, not simulations of USCIS beneficiary-level weighted selection.

## Reconciliation of the primary analytical samples

| Measure | FY2025 Q1–Q3 | FY2026 Q1–Q3 |
|---|---:|---:|
| Original records | 477,972 | 437,496 |
| Unique case numbers | 476,836 | 437,496 |
| Certified H-1B records after case deduplication | 435,089 | 392,175 |
| Certified H-1B LCAs with Wage Levels I–IV | 401,626 | 351,375 |
| Reported NEW_EMPLOYMENT positions in those LCAs | 235,613 | 241,528 |
| Match to manuscript sample counts | Yes | Yes |

FY2025 comprises the Q1, Q2 and Q3 disclosure files, with duplicate case numbers resolved by keeping the latest determination. FY2026 uses the cumulative Q3 file.

## Sensitivity of wage-level redistribution

Values are *percentage-point changes* in representation, calculated as weighted share minus baseline share. The alternative unit analysis assigns each included LCA one unit instead of counting reported new-employment positions. Top-ten employer sensitivity excludes the ten employer **names** with the highest baseline NEW_EMPLOYMENT positions, separately for each period.

| Period | Wage level | Positions (main) | Equal application counts | Excluding top-ten employer names |
|---|---|---:|---:|---:|
| FY2025 Q1–Q3 | I | -17.73 | -12.18 | -17.58 |
| FY2025 Q1–Q3 | II | +1.00 | -5.63 | +1.88 |
| FY2025 Q1–Q3 | III | +8.00 | +6.12 | +7.90 |
| FY2025 Q1–Q3 | IV | +8.72 | +11.68 | +7.80 |
| FY2026 Q1–Q3 | I | -16.52 | -11.14 | -15.60 |
| FY2026 Q1–Q3 | II | -2.38 | -6.97 | -3.49 |
| FY2026 Q1–Q3 | III | +7.78 | +4.97 | +6.44 |
| FY2026 Q1–Q3 | IV | +11.12 | +13.14 | +12.66 |

Values rounded to two decimals; figures can differ slightly from one-decimal manuscript tables due to rounding. The broad direction for Levels I, III, IV is stable in these specifications. The FY2025 Level II change reverses sign between position and application units.

## Excluded wage-level observations

| Measure | FY2025 Q1–Q3 | FY2026 Q1–Q3 |
|---|---:|---:|
| Certified H-1B LCAs missing observed level I–IV | 33,463 | 40,800 |
| NEW_EMPLOYMENT positions in these excluded LCAs | 27,583 | 33,788 |
| Excluded positions as percentage of all certified H-1B new positions | 10.5% | 12.3% |

No wage-level values were imputed. These exclusions limit generalizability.

## Policy interpretation and limitations

The DOL field `PW_WAGE_LEVEL` reports an OES prevailing-wage level, where available. It is **not necessarily the offered-wage-equivalent level** used by DHS for the FY2027 USCIS weighted H-1B selection mechanism. The workbooks do not establish beneficiary-level cap eligibility, registrations, unique beneficiaries, or actual selections. These calculations are normalized redistributions of historical LCA position or application counts and are not causal estimates or forecasts of visa allocations.

## Reproducibility status

These results were computed from DOL source workbooks in an R session and reconciled to manuscript totals. The updated R audit program and its machine-readable CSV output should be deposited together in the repository before describing this GitHub commit as a complete reproduction package. Previously archived Zenodo versions should not be described as containing the new audit without separately updating that archive.
