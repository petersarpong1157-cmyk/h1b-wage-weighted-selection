# Full data coverage with explicit provenance

Original execution produced 15 settings × 500 replications = 7,500 datasets. `results/36_final_permutation_replications.csv` contains all 7,500 results.

An independent comparison was completed for 200 accessible original batch CSVs (5,000 records), and **zero mismatches** were detected. The remaining 100 original batch CSVs (2,500 records) were not accessible in this verification session.

For a locally downloadable archive, 100 **reconstructed** 25-row batch CSVs were generated from the final consolidated results. These reconstructed files are derived copies **not** independently observed originals; their agreement with the consolidated dataset is automatic and must never be reported as independent verification.

The GitHub main branch includes the original `analysis/H1B_Final_Permutation_Calibration.R`, all 7,500 consolidated results, final summary, measured sample audit reports, R plotting code, and vector figures. A separate local ZIP includes the 200 accessible original batch files, 100 derived copies, SHA-256 checksums and provenance notes.

The published `v3.8.9` tag and Zenodo DOI 10.5281/zenodo.23575464 precede the final results commits. Do not rewrite the published tag. A later `v3.8.10` version and DOI are needed to archive the corrected files. The full original batch audit is not complete, so avoid describing the package as independently validated in full.
