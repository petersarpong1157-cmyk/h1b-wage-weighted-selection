# Verification of administrative measurement outputs 20-22
# Run from the root directory of this repository:
#   Rscript analysis/Verify_Measurement_CSV_20_to_22.R
# Requires only base R; no original DOL workbooks needed.
# This validates archived CSV arithmetic, NOT raw-input reproduction.

base <- file.path("results", "2026-10-19")
read_output <- function(n) {
  path <- file.path(base, n)
  if (!file.exists(path)) stop("Missing file: ", path)
  read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
}
a <- read_output("20_all_wage_levels_measurement.csv")
b <- read_output("21_three_measurement_definitions.csv")
c <- read_output("22_zero_vs_positive_count_decomposition.csv")

levels <- c("I", "II", "III", "IV")
periods <- c("FY2025 Q1-Q3", "FY2026 Q1-Q3")
key <- function(d) paste(d$period, d$level, sep = "::")
expect <- as.vector(outer(periods, levels, paste, sep = "::"))
stopifnot(nrow(a) == 8L, nrow(b) == 24L, nrow(c) == 8L,
          !anyDuplicated(key(a)), !anyDuplicated(key(c)),
          setequal(key(a), expect), setequal(key(c), expect))
a <- a[match(expect, key(a)), , drop = FALSE]
c <- c[match(expect, key(c)), , drop = FALSE]

assert_close <- function(got, want, label, tolerance = 1e-8) {
  if (anyNA(got) || anyNA(want) || length(got) != length(want) ||
      any(!is.finite(got)) || any(!is.finite(want)) ||
      any(abs(got - want) > tolerance)) stop("Mismatch: ", label)
}
for (i in seq_along(periods)) {
  d <- a[a$period == periods[i], , drop = FALSE]
  target_apps <- c(401626, 351375)[i]
  target_positions <- c(235613, 241528)[i]
  stopifnot(sum(d$n_apps) == target_apps,
            sum(d$n_positions) == target_positions,
            all(d$n_zero >= 0), all(d$n_zero <= d$n_apps))
  assert_close(sum(d$discrepancy_pp), 0, "Discrepancy must sum to zero")
}
assert_close(a$zero_fraction, a$n_zero / a$n_apps, "Zero fractions")
assert_close(a$discrepancy_pp,
             a$position_change_pp - a$app_change_pp,
             "Direct discrepancy from file 20")

stopifnot(setequal(b$specification,
                   c("All applications", "Positive-position applications",
                     "Requested positions")),
          !anyDuplicated(paste(b$period, b$level, b$specification)))
get_change <- function(spec) {
  d <- b[b$specification == spec, , drop = FALSE]
  stopifnot(setequal(key(d), expect), nrow(d) == 8L)
  d$change_pp[match(expect, key(d))]
}
all_change <- get_change("All applications")
positive_change <- get_change("Positive-position applications")
positions_change <- get_change("Requested positions")

assert_close(a$app_change_pp, all_change, "All-application change")
assert_close(a$position_change_pp, positions_change,
             "Requested-position change")
assert_close(c$zero_inclusion_component_pp,
             positive_change - all_change,
             "Zero-position inclusion component")
assert_close(c$positive_count_component_pp,
             positions_change - positive_change,
             "Positive position-count component")
assert_close(c$direct_discrepancy_pp,
             positions_change - all_change,
             "Direct discrepancy")
assert_close(c$direct_discrepancy_pp, a$discrepancy_pp,
             "Files 20 and 22 agreement")
assert_close(c$reconstructed_discrepancy_pp,
             c$zero_inclusion_component_pp +
               c$positive_count_component_pp,
             "Reconstructed sum")
assert_close(c$reconciliation_error, 0,
             "Eight decomposition residuals")

message("PASS: all 8 wage-level comparisons and 3 measurement definitions reconcile.")
message("NOTE: This checks CSV arithmetic, not independent source-workbook reproduction.")
