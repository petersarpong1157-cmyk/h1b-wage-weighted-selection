# Monte Carlo final results — verification status (2026-10-22)

**Status: candidate archive, not a published release.** Preserve Zenodo v3.7.0 (DOI 10.5281/zenodo.23486897) unchanged.

## Data and validation

- Final consolidated `36_final_permutation_replications.csv`: 7,500 unique (scenario, n, replicate) records; 15 scenario-size settings with 500 replications per setting.
- Accessible batch files in the verification session: 200 files containing 5,000 records.
- Within accessible batches: zero duplicate keys, zero filename-versus-replication-range errors, and zero mismatches with consolidated data on `true_distance_pp`, `exchangeability_null`, `distance_pp`, `permutation_p`, `fixed_flag`, or `permutation_reject`.
- Remaining 2,500 batch records were not available in this verification snapshot. **The full batch archive is not independently reconciled**; do not describe the entire 7,500-run archive as verified.

## Study design

Five data-generating scenarios at n = 250, 1,000, and 4,000; 500 replications per setting, with 999 permutations per replication as specified by the original R study.

Under high equal-zero probabilities with population TVD = 0, the fixed 5-percentage-point flag frequencies were 68%, 14%, and 0% as n increased; permutation rejection rates were 4.2%, 4.0%, and 4.0%. In the near-5pp alternative (population TVD 4.997557 pp), fixed flag frequencies were 60.4%, 50.2%, and 49.8%, while exchangeability permutation rejection rates were 32.2%, 79.4%, and 100%. The permutation test targets exchangeability, **not** whether TVD exceeds 5 percentage points. Observed rates have Monte Carlo uncertainty (500 replications per setting).

## Release checklist

1. Archive the exact original `H1B_Final_Permutation_Calibration.R`, `36_final_permutation_replications.csv`, `37_final_permutation_summary.csv`, supporting measurement CSVs, and both figures.
2. Ensure **300** batch CSVs / **7,500** batch records are available, with no duplicate keys or range errors.
3. Match all batch values to the consolidated CSV and produce a zero-row discrepancy file.
4. Run original R code and regenerate the figures and tables in a clean environment.
5. Generate SHA-256 checksums, commit the full release snapshot, create a new GitHub release, and confirm a **new** Zenodo DOI. Do not assume that committing or tagging alone deposits a Zenodo version.

**Interpretation safeguards:** DOL prevailing-wage levels do not establish USCIS offered-wage categories; weights I=1 through IV=4 are illustrative. The simulations do not validate any causal visa-selection effect.
