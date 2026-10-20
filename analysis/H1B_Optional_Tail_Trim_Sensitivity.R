# Optional zero-position and right-tail sensitivity for the matched-period
# H-1B LCA wage-weighted measurement analysis.
# Run AFTER analysis/H1B_Independent_Audit_Low_Memory.R and
# H1B_Labour_Industry_Additional_Analysis.R in SAME R session.
# Required objects: combined, phase_dir.
# CAUTION: descriptive population and weighting sensitivity, NOT USCIS selection.
library(dplyr)
stopifnot(exists("combined"), exists("phase_dir"))
stopifnot(all(c("period","level","positions","applications") %in% names(combined)))
x <- combined %>%
  mutate(
    positions = as.numeric(positions),
    app_unit = as.numeric(applications),
    wt = case_when(
      level == "I" ~ 1,
      level == "II" ~ 2,
      level == "III" ~ 3,
      level == "IV" ~ 4,
      TRUE ~ NA_real_
    )
  )
stopifnot(all(is.finite(x$positions)), all(x$positions >= 0),
          all(is.finite(x$wt)))
caps <- x %>% filter(positions > 0) %>% group_by(period) %>%
  summarise(cap99 = as.numeric(quantile(positions, .99)), .groups = "drop")
x <- x %>% left_join(caps, by = "period")
forms <- bind_rows(
  x %>% mutate(spec = "Full sample", pos_unit = positions),
  x %>% mutate(spec = "Capped at P99 positive positions",
               pos_unit = pmin(positions, cap99)),
  x %>% filter(positions > 0) %>%
    mutate(spec = "Positive new-position LCAs only", pos_unit = positions)
)
result <- forms %>% group_by(spec, period) %>%
  summarise(
    n_apps = sum(app_unit),
    n_positions = sum(pos_unit),
    aii = sum(app_unit * (level == "II")),
    pii = sum(pos_unit * (level == "II")),
    wa = sum(app_unit * wt),
    wp = sum(pos_unit * wt),
    waii = sum(app_unit * wt * (level == "II")),
    wpii = sum(pos_unit * wt * (level == "II")),
    .groups = "drop"
  ) %>% mutate(
    app_change_pp = 100 * (waii / wa - aii / n_apps),
    position_change_pp = 100 * (wpii / wp - pii / n_positions),
    discrepancy_pp = position_change_pp - app_change_pp
  )
stopifnot(nrow(result) == 6, all(is.finite(result$discrepancy_pp)))
write.csv(caps, file.path(phase_dir, "18_positive_position_p99_caps.csv"),
          row.names = FALSE)
write.csv(result, file.path(phase_dir, "19_tail_zero_sensitivity.csv"),
          row.names = FALSE)
print(result[, c("spec", "period", "n_apps", "n_positions",
                 "app_change_pp", "position_change_pp", "discrepancy_pp")],
      n = Inf, width = Inf)
message("Optional sensitivity completed; inspect findings before manuscript use.")
