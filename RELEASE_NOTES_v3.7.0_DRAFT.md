# v3.7.0 — release notes draft (not published)

**Scope:** Reproducibility-only update to the H-1B LCA prevailing-wage-level counterfactual. Original DOL disclosure spreadsheets are not redistributed. Manuscripts and cover letters are intentionally excluded.

## Added and corrected

- Eleven final CSV exports numbered 09–19 under `results/2026-10-19/`; obsolete/error-containing temporary CSV files omitted.
- `analysis/H1B_Labour_Industry_Additional_Analysis.R`, with corrected zero-new-employment LCA counting and checks against eight observed wage-level-period totals.
- `analysis/H1B_Optional_Tail_Trim_Sensitivity.R` for period-specific P99 caps and positive-new-position-only comparisons.
- `H1B_figure5_decomposition.png` showing the exact symmetric occupational accounting decomposition.
- Updated README and results methodology record.

## Findings (percentage-point discrepancies for Level II)

| Period | Full sample | Exclude ten largest standardized employer names | Cap positive position counts at P99 | Positive-new-position LCAs only |
|---|---:|---:|---:|---:|
| FY2025 Q1–Q3 | +6.63 | +7.44 | +7.25 | −1.35 |
| FY2026 Q1–Q3 | +4.59 | +3.28 | +4.53 | +0.589 |

The full-population discrepancy decomposes into occupational-composition (FY2025 +0.642 pp; FY2026 +0.716 pp) and within-occupation (FY2025 +5.99 pp; FY2026 +3.87 pp) components. The identity reconciles to numerical precision in the researcher-executed R outputs. Excluding zero-new-position LCAs changes the estimand/population and substantially changes the finding; these records are not inherently invalid.

**Interpretation:** These calculations compare the DOL-reported prevailing-wage-level weighting of administrative LCAs and requested new-employment positions. They do **not** simulate actual USCIS cap registrations, predict beneficiaries selected, or identify causal effects.

**Verification status:** User-executed R calculations and reconciled CSV exports were inspected. The full DOL raw-data pipeline has not been independently rerun for this release. The new `01_level_measure_contrast.csv` script correction has been reviewed but still requires execution in RStudio to test that all eight observed zero-position counts pass the new assertions.

**Publication status:** This is a draft; no new Zenodo DOI or version has been published. The prior Zenodo v3.6.7 DOI remains 10.5281/zenodo.23353950. Update version metadata only when a release and its DOI are actually confirmed.
