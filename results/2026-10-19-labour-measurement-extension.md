# October 19, 2026: Labour-market measurement extension — verification record

**Status:** Verified against user-executed R checks and reported console outputs; full rerun from original DOL workbooks has **not** been conducted in this GitHub update. The original independently audited matched-period counts remain unchanged.

**Scope:** Certified H-1B Labor Condition Applications (LCAs) with reported prevailing-wage levels I–IV; FY2025 Q1–Q3 and FY2026 Q1–Q3. The study evaluates a **reported DOL prevailing-wage-level weighting counterfactual**, **not actual USCIS beneficiary selection** or any causal impact.

## Reconciled analysis populations

| Period | LCAs | Requested NEW_EMPLOYMENT positions |
|---|---:|---:|
| FY2025 Q1–Q3 | 401,626 | 235,613 |
| FY2026 Q1–Q3 | 351,375 | 241,528 |

## Level II counterfactual measurement sensitivity

All values are percentage points. Discrepancy = position-based weighted-minus-baseline change − application-based weighted-minus-baseline change.

| Population | Period | Applications change | Positions change | Discrepancy |
|---|---|---:|---:|---:|
| Full | FY2025 | −5.63 | +1.00 | +6.63 |
| Full | FY2026 | −6.97 | −2.38 | +4.59 |
| Excluding top ten standardized employer names | FY2025 | −5.56 | +1.88 | +7.44 |
| Excluding top ten standardized employer names | FY2026 | −7.05 | −3.77 | +3.28 |

**Employer-name handling matters:** This new exclusion standardizes case and whitespace only; earlier exact-name top-ten sensitivity used a different grouping. They should not be conflated.

### Symmetric occupational decomposition of discrepancy

| Sample | Period | Occupational composition (pp) | Within-occupation (pp) | Total (pp) |
|---|---|---:|---:|---:|
| Full | FY2025 | +0.642 | +5.99 | +6.63 |
| Full | FY2026 | +0.716 | +3.87 | +4.59 |
| Excluding top ten | FY2025 | +0.144 | +7.29 | +7.44 |
| Excluding top ten | FY2026 | +0.0580 | +3.23 | +3.28 |

R arithmetic identities and comparison with original audit passed, with residuals near machine precision. Components are **descriptive accounting decompositions**, not causal attributions.

## Zero new-employment positions and tail sensitivity

| Sensitivity | FY2025 discrepancy (pp) | FY2026 discrepancy (pp) |
|---|---:|---:|
| Full population | +6.63 | +4.59 |
| Position counts capped at period-specific 99th percentile of positive counts | +7.25 | +4.53 |
| LCAs with positive new-employment counts only | **−1.35** | **+0.589** |

The positive-position-only restriction changes the population and substantially attenuates / reverses the original result. An LCA with zero NEW_EMPLOYMENT can represent other work activity and is not invalid by definition. Hence claims of robustness **must be qualified**.

Zero-position counts by prevailing-wage level, FY2025: I 28,572; II 105,402; III 62,942; IV 52,761. FY2026: I 29,406; II 92,717; III 51,671; IV 52,124.

## Availability, reproduction, and outstanding materials

- Pre-existing independent audit scripts and source-workbook reconciliation outputs remain in the repository.
- The optional P99/positive-position sensitivity R script is in `analysis/H1B_Optional_Tail_Trim_Sensitivity.R`.
- The actual **final CSVs numbered 09–19 (especially 10–19)** remain on the researcher's Windows RStudio machine and **have not been deposited in this update**. The displayed tables above are a transparent record of the verified console outputs, not replacements for the exact downloadable CSVs.
- Do **not** create or cite a new Zenodo archive version as containing the complete updated outputs until those files are added and the repository release snapshot is verified.
- Public repository materials may reveal author identity during double-anonymous review; follow the target journal's policies.

**Source:** Results are from the researcher's executed R scripts and exported console validations in the October 2026 research workflow. No fictional raw DOL observations, employer names, or unsupported estimates have been added.
