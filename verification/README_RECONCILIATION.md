# Audit instructions and integrity expectations

The local verification scripts in the attached v3.8.10 candidate archive compare the original 25-row batch CSVs with `results/36_final_permutation_replications.csv` on the composite key `scenario,n,replicate`. Required result fields are true distance, null flag, estimated distance, permutation p-value, fixed flag, and permutation reject flag.

Expected full verification: 300 original batch files, 7,500 unique keys, exactly 500 replications in each of 15 settings, 0 duplicate keys, 0 missing records, 0 discrepancies.

Current source availability: 200 original batch files, 5,000 matching keys, zero mismatches; 2,500 records have not been independently verified against their original batch CSV files. Therefore the full audit does **not** pass its release gate.

To regenerate figures from the final summary:
```sh
Rscript analysis/H1B_Generate_Final_Figures.R results/37_final_permutation_summary.csv figures
```

The published GitHub tag `v3.8.9` was created before the consolidated 7,500-row CSV and the final R script were added to `main`. Do not rewrite this immutable published tag. Create a new versioned release from a later commit and confirm the newly minted Zenodo version DOI.
