# Wage-Weighted H-1B Selection and New-Employment Positions

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.22803293.svg)](https://doi.org/10.5281/zenodo.22803293)

Reproducibility materials for Peter Sarpong's study of how applying the FY2027 H-1B wage-level weighting structure to historical U.S. Department of Labor (DOL) Labor Condition Application (LCA) new-employment positions changes their distribution across wage levels, occupations, reported employer names, and worksite states.

## Study design

This project is an **LCA-based distributional counterfactual**. It does not simulate USCIS beneficiary selection and does not estimate actual H-1B selection probabilities, selected beneficiaries, petitions, or visa issuances. DOL LCA records do not identify unique cap-subject beneficiaries or USCIS registrations.

The primary analytical population consists of certified H-1B LCAs with observed OEWS wage levels I-IV. The analysis uses `NEW_EMPLOYMENT` positions as a proxy for new H-1B employment demand.

The counterfactual applies wage-level weights:

- Level I: 1
- Level II: 2
- Level III: 3
- Level IV: 4

For each group, the weighted quantity is `NEW_EMPLOYMENT × wage-level weight`, and weighted shares are compared with baseline shares.

## Data

The analysis uses public DOL Office of Foreign Labor Certification LCA disclosure data:

- FY2025 Q4 disclosure data (full FY2025)
- FY2026 Q3 disclosure data (October 1, 2025 through June 30, 2026)

The original DOL Excel files are not stored in this repository. Download the official disclosure files and corresponding record layouts from the U.S. Department of Labor Foreign Labor Certification performance-data pages.

Expected source filenames used during the analysis:

- `LCA_Disclosure_Data_FY2025_Q4.xlsx`
- `LCA_Disclosure_Data_FY2026_Q3.xlsx`

## Reproducibility

Analysis scripts and documentation in this repository are intended to reproduce the reported distributional calculations from the official DOL source files. FY2026 Q3 is a partial fiscal-year file and should not be interpreted as a full-year count comparison with FY2025.

## Author

Peter Sarpong  
Independent Researcher  
Gaithersburg, Maryland, USA

## Citation

Version 2.0.3 is archived on Zenodo with DOI: **10.5281/zenodo.22803293**.

## License

No license has yet been assigned to this repository. The underlying DOL data are public federal data and are not authored by the repository owner.
