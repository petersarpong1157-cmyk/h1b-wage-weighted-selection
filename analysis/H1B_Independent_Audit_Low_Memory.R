# H-1B LCA wage-level counterfactual: independent audit + sensitivity analyses
# Inputs: five original DOL .xlsx files in a chosen folder
# IMPORTANT: PW_WAGE_LEVEL is the DOL prevailing-wage level, NOT a verified
# equivalent of the USCIS rule's offered-wage-based selection level.
# This is a descriptive LCA-position counterfactual, NOT a visa lottery simulation.

library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

input_dir <- "C:/Users/peter/Downloads/fy2025"  # CHANGE ONLY THIS PATH
output_dir <- file.path(input_dir, "h1b_audit_outputs")
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

file_names <- c(
  q1_2025 = "LCA_Disclosure_Data_FY2025_Q1.xlsx",
  q2_2025 = "LCA_Disclosure_Data_FY2025_Q2.xlsx",
  q3_2025 = "LCA_Disclosure_Data_FY2025_Q3.xlsx",
  q4_2025 = "LCA_Disclosure_Data_FY2025_Q4.xlsx",
  q3_2026 = "LCA_Disclosure_Data_FY2026_Q3.xlsx"
)
paths <- setNames(file.path(input_dir, unname(file_names)), names(file_names))
# Preserve the lookup names (q1_2025, q2_2025, etc.) for paths[[...]].
stopifnot(all(c("q1_2025", "q2_2025", "q3_2025", "q3_2026") %in% names(paths)))
core_paths <- paths[names(paths) != "q4_2025"]
if (any(!file.exists(core_paths))) {
  stop("Missing input files: ", paste(basename(core_paths[!file.exists(core_paths)]), collapse = ", "),
       "\nRename files or adjust file_names at the beginning of the script.")
}

required <- c("CASE_NUMBER", "DECISION_DATE", "CASE_STATUS", "VISA_CLASS",
              "PW_WAGE_LEVEL", "NEW_EMPLOYMENT", "SOC_CODE",
              "EMPLOYER_NAME", "WORKSITE_STATE", "WAGE_RATE_OF_PAY_FROM",
              "WAGE_UNIT_OF_PAY", "PW_UNIT_OF_PAY", "PW_OTHER_SOURCE")

# Keep memory usage controlled by reading only the required columns, in batches.
# Set CHUNK_SIZE to 10000 if R still reports std::bad_alloc.
CHUNK_SIZE <- 25000L

load_lca <- function(path, source_id) {
  message("Reading in chunks: ", basename(path))
  header <- names(readxl::read_excel(path, n_max = 0, .name_repair = "unique"))
  absent <- setdiff(required, header)
  if (length(absent)) stop("Missing columns in ", basename(path), ": ", paste(absent, collapse = ", "))

  # Type all retained columns explicitly to avoid readxl guessing warnings.
  # Dates are read as Excel dates; employment/wages converted to numeric below.
  type_map <- rep("skip", length(header))
  names(type_map) <- header
  type_map[required] <- "text"
  type_map["DECISION_DATE"] <- "date"
  type_map <- unname(type_map)

  pieces <- list()
  start <- 0L
  repeat {
    # skip skips the column-heading row plus previously consumed data rows.
    chunk <- readxl::read_excel(
      path, skip = start + 1L, n_max = CHUNK_SIZE,
      col_names = FALSE, col_types = type_map,
      .name_repair = "minimal"
    )
    got <- nrow(chunk)
    if (got == 0L) break
    names(chunk) <- header[type_map != "skip"]
    pieces[[length(pieces) + 1L]] <- chunk %>%
      transmute(
        CASE_NUMBER = as.character(CASE_NUMBER),
        DECISION_DATE = as.Date(DECISION_DATE),
        CASE_STATUS = stringr::str_trim(as.character(CASE_STATUS)),
        VISA_CLASS = stringr::str_trim(as.character(VISA_CLASS)),
        PW_WAGE_LEVEL = stringr::str_trim(as.character(PW_WAGE_LEVEL)),
        NEW_EMPLOYMENT = suppressWarnings(as.numeric(NEW_EMPLOYMENT)),
        SOC_CODE = as.character(SOC_CODE),
        EMPLOYER_NAME = as.character(EMPLOYER_NAME),
        WORKSITE_STATE = as.character(WORKSITE_STATE),
        WAGE_RATE_OF_PAY_FROM = suppressWarnings(as.numeric(WAGE_RATE_OF_PAY_FROM)),
        WAGE_UNIT_OF_PAY = as.character(WAGE_UNIT_OF_PAY),
        PW_UNIT_OF_PAY = as.character(PW_UNIT_OF_PAY),
        PW_OTHER_SOURCE = as.character(PW_OTHER_SOURCE),
        source_file = source_id
      )
    start <- start + got
    rm(chunk)
    gc(verbose = FALSE)
    message("  ", format(start, big.mark = ","), " rows read")
    if (got < CHUNK_SIZE) break
  }
  result <- dplyr::bind_rows(pieces)
  rm(pieces)
  gc(verbose = FALSE)
  result
}

# Read the largest file first in a clean R session, then the FY2025 files.
q26 <- load_lca(paths[["q3_2026"]], "FY2026 Q3 cumulative")
gc(verbose = FALSE)
q1 <- load_lca(paths[["q1_2025"]], "FY2025 Q1")
q2 <- load_lca(paths[["q2_2025"]], "FY2025 Q2")
q3 <- load_lca(paths[["q3_2025"]], "FY2025 Q3")

raw25 <- bind_rows(q1, q2, q3)
raw26 <- q26

# Explicitly reject unknown or missing dates; files should cover the stated periods.
assert_period <- function(x, lower, upper, label) {
  bad <- sum(is.na(x$DECISION_DATE) | x$DECISION_DATE < as.Date(lower) |
               x$DECISION_DATE > as.Date(upper))
  if (bad) stop(label, ": ", bad, " records have missing/out-of-window decision dates")
}
assert_period(raw25, "2024-10-01", "2025-06-30", "FY2025 Q1-Q3")
assert_period(raw26, "2025-10-01", "2026-06-30", "FY2026 Q1-Q3")

# Stable latest-decision deduplication; tie priority is later quarter.
# A tie audit is also exported, since the same case may have multiple records.
raw25 <- raw25 %>% mutate(source_rank = match(source_file, c("FY2025 Q1", "FY2025 Q2", "FY2025 Q3")))
ties25 <- raw25 %>% group_by(CASE_NUMBER, DECISION_DATE) %>%
  filter(n() > 1) %>% ungroup()
write.csv(ties25 %>% count(source_file, name = "rows"),
          file.path(output_dir, "fy2025_same_date_duplicate_source_counts.csv"), row.names = FALSE)
clean25 <- raw25 %>% arrange(CASE_NUMBER, desc(DECISION_DATE), desc(source_rank)) %>%
  distinct(CASE_NUMBER, .keep_all = TRUE)
clean26 <- raw26 %>% arrange(CASE_NUMBER, desc(DECISION_DATE)) %>%
  distinct(CASE_NUMBER, .keep_all = TRUE)

# Keep certified H-1B LCAs with observed OES prevailing-wage levels.
base_filter <- function(x) x %>% filter(VISA_CLASS == "H-1B", CASE_STATUS == "Certified")
cert25 <- base_filter(clean25)
cert26 <- base_filter(clean26)
levels <- c("I", "II", "III", "IV")
keep_levels <- function(x) x %>% filter(PW_WAGE_LEVEL %in% levels)
a25 <- keep_levels(cert25)
a26 <- keep_levels(cert26)

summary_rows <- bind_rows(
  tibble(period = "FY2025 Q1-Q3", raw_rows = nrow(raw25), unique_cases = nrow(clean25),
         certified_h1b = nrow(cert25), analyzed_lcas = nrow(a25),
         analyzed_new_positions = sum(a25$NEW_EMPLOYMENT, na.rm = TRUE)),
  tibble(period = "FY2026 Q1-Q3", raw_rows = nrow(raw26), unique_cases = nrow(clean26),
         certified_h1b = nrow(cert26), analyzed_lcas = nrow(a26),
         analyzed_new_positions = sum(a26$NEW_EMPLOYMENT, na.rm = TRUE))
)
write.csv(summary_rows, file.path(output_dir, "01_sample_reconciliation.csv"), row.names = FALSE)

# Manuscript assertions: fail visibly rather than silently repeat mismatched numbers.
expected <- tibble(period = c("FY2025 Q1-Q3", "FY2026 Q1-Q3"),
                   analyzed_lcas = c(401626L, 351375L),
                   analyzed_new_positions = c(235613, 241528))
verification <- summary_rows %>%
  left_join(expected, by = "period", suffix = c("_recomputed", "_manuscript")) %>%
  mutate(counts_match = analyzed_lcas_recomputed == analyzed_lcas_manuscript,
         positions_match = analyzed_new_positions_recomputed == analyzed_new_positions_manuscript)
write.csv(verification, file.path(output_dir, "02_manuscript_reconciliation.csv"), row.names = FALSE)
print(verification)

# Quantify excluded wage-level cases; do not assign missing levels artificially.
excluded <- bind_rows(
  cert25 %>% mutate(period = "FY2025 Q1-Q3"),
  cert26 %>% mutate(period = "FY2026 Q1-Q3")
) %>% mutate(in_analysis = PW_WAGE_LEVEL %in% levels,
             wage_level = if_else(in_analysis, PW_WAGE_LEVEL, "Missing/Other")) %>%
  group_by(period, wage_level, in_analysis) %>%
  summarise(applications = n(), new_positions = sum(NEW_EMPLOYMENT, na.rm = TRUE), .groups = "drop")
write.csv(excluded, file.path(output_dir, "03_wage_level_coverage.csv"), row.names = FALSE)

weights <- c(I = 1, II = 2, III = 3, IV = 4)
weighted_summary <- function(x, measure = c("positions", "applications")) {
  measure <- match.arg(measure)
  x %>% mutate(unit = if (measure == "positions") replace_na(NEW_EMPLOYMENT, 0) else 1) %>%
    group_by(PW_WAGE_LEVEL) %>% summarise(n = sum(unit), applications = n(), .groups = "drop") %>%
    complete(PW_WAGE_LEVEL = levels, fill = list(n = 0, applications = 0)) %>%
    mutate(weight = unname(weights[PW_WAGE_LEVEL]), weighted_n = n * weight,
           baseline_pct = 100 * n / sum(n),
           weighted_pct = 100 * weighted_n / sum(weighted_n),
           change_pp = weighted_pct - baseline_pct)
}

by_period <- bind_rows(
  weighted_summary(a25) %>% mutate(period = "FY2025 Q1-Q3"),
  weighted_summary(a26) %>% mutate(period = "FY2026 Q1-Q3")
)
write.csv(by_period, file.path(output_dir, "04_primary_wage_counterfactual.csv"), row.names = FALSE)

application_check <- bind_rows(
  weighted_summary(a25, "applications") %>% mutate(period = "FY2025 Q1-Q3"),
  weighted_summary(a26, "applications") %>% mutate(period = "FY2026 Q1-Q3")
)
write.csv(application_check, file.path(output_dir, "05_application_count_robustness.csv"), row.names = FALSE)

# Employer concentration sensitivity: exclude largest 10 names by baseline NEW_EMPLOYMENT.
exclude_top10 <- function(x) {
  top <- x %>% group_by(EMPLOYER_NAME) %>%
    summarise(n = sum(NEW_EMPLOYMENT, na.rm = TRUE), .groups = "drop") %>%
    arrange(desc(n), EMPLOYER_NAME) %>% slice_head(n = 10)
  list(data = x %>% filter(!(EMPLOYER_NAME %in% top$EMPLOYER_NAME)), top = top)
}
e25 <- exclude_top10(a25);e26 <- exclude_top10(a26)
write.csv(bind_rows(e25$top %>% mutate(period = "FY2025 Q1-Q3"),
                    e26$top %>% mutate(period = "FY2026 Q1-Q3")),
          file.path(output_dir, "06_top10_employers_removed.csv"), row.names = FALSE)
top10_robust <- bind_rows(
  weighted_summary(e25$data) %>% mutate(period = "FY2025 Q1-Q3"),
  weighted_summary(e26$data) %>% mutate(period = "FY2026 Q1-Q3")
)
write.csv(top10_robust, file.path(output_dir, "07_excluding_top10_employers.csv"), row.names = FALSE)

# Wages in the LCA can be in different pay units. Coverage here only, not a
# rule-equivalent selection-level measure; constructing one requires occupation,
# geographic, time-specific OEWS Level I-IV thresholds and regulatory details.
rate_coverage <- bind_rows(a25 %>% mutate(period = "FY2025 Q1-Q3"),
                           a26 %>% mutate(period = "FY2026 Q1-Q3")) %>%
  group_by(period, WAGE_UNIT_OF_PAY, PW_UNIT_OF_PAY) %>%
  summarise(applications = n(), positions = sum(NEW_EMPLOYMENT, na.rm = TRUE),
            missing_offered_wage = sum(is.na(WAGE_RATE_OF_PAY_FROM)), .groups = "drop")
write.csv(rate_coverage, file.path(output_dir, "08_wage_pay_unit_coverage.csv"), row.names = FALSE)

# Optional full-FY2025 check (separate from matched-period primary design).
# Run this after the main audit to avoid loading an unnecessary large workbook.
RUN_FY2025_FULL_YEAR <- FALSE
if (RUN_FY2025_FULL_YEAR) {
  if (!file.exists(paths[["q4_2025"]])) stop("FY2025 Q4 file is required for optional full-year analysis")
  q4 <- load_lca(paths[["q4_2025"]], "FY2025 Q4")
  all25 <- bind_rows(raw25 %>% select(-source_rank), q4) %>%
    arrange(CASE_NUMBER, desc(DECISION_DATE)) %>% distinct(CASE_NUMBER, .keep_all = TRUE)
  full25 <- keep_levels(base_filter(all25))
  write.csv(weighted_summary(full25), file.path(output_dir, "09_FY2025_full_year_sensitivity.csv"), row.names = FALSE)
}

p <- ggplot(by_period, aes(x = PW_WAGE_LEVEL)) +
  geom_col(aes(y = baseline_pct, fill = "Baseline"), width = .36, position = position_nudge(x = -.18)) +
  geom_col(aes(y = weighted_pct, fill = "Weighted"), width = .36, position = position_nudge(x = .18)) +
  facet_wrap(~period) + labs(x = "Reported prevailing-wage level", y = "Share of LCA new-employment positions (%)",
                             fill = "Distribution") + theme_minimal(base_size = 12)
ggsave(file.path(output_dir, "10_primary_distribution.png"), p, width = 10, height = 5, dpi = 300)
writeLines(capture.output(sessionInfo()), file.path(output_dir, "11_R_session_info.txt"))
message("Audit output folder: ", output_dir)
message("WARNING: This is a reported prevailing-wage-level LCA counterfactual, NOT actual USCIS beneficiary selection.")