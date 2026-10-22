# Final simulation: administrative counting-unit sensitivity
# Synthetic data only. Does not estimate H-1B visa outcomes.
# Base R only. Run: Rscript H1B_Final_Permutation_Calibration.R
# Resumable batches; existing valid batches are preserved.

set.seed(20261021)
output_dir <- file.path(getwd(), 'permutation_calibration_final')
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
R <- 500L
B <- 999L
batch_size <- 25L
sample_sizes <- c(250L, 1000L, 4000L)
alpha <- 0.05
practical_cutoff_pp <- 5
w <- 1:4
p_category <- rep(0.25, 4)
normalize <- function(x) x / sum(x)
tv_pp <- function(a, b) 50 * sum(abs(a - b))
true_distance <- function(z, lambda) {
  A <- normalize(w * p_category)
  Q <- normalize(w * p_category * (1 - z) * (1 + lambda))
  tv_pp(A, Q)
}
# Target just below 5 pp, explicitly NOT a truly >5 pp discrepancy.
target <- uniroot(function(z4) true_distance(c(.30,.30,.30,z4), rep(2,4)) - 4.998778,
                  interval=c(.300001,.95))$root
scenarios <- list(
  Low_equal_zeros = list(z=rep(.10,4), lambda=rep(2,4)),
  High_equal_zeros = list(z=rep(.65,4), lambda=rep(2,4)),
  Near_5pp = list(z=c(.30,.30,.30,target), lambda=rep(2,4)),
  Category_dependent_zeros = list(z=c(.15,.35,.55,.75), lambda=rep(2,4)),
  Unequal_positive_counts = list(z=rep(.15,4), lambda=c(1,2,4,8))
)

# Fast four-category weighted distribution; all four categories retained.
dist4 <- function(group, counts) {
  # Tabulate category totals, including categories absent from a sample.
  sums <- vapply(1:4, function(k) sum(counts[group == k]), numeric(1))
  if (sum(sums) <= 0) stop('No positive quantity in sample')
  normalize(w * sums)
}
run_one <- function(s, n) {
  level <- sample.int(4L, size=n, replace=TRUE)
  zero <- rbinom(n, 1L, s$z[level]) == 1L
  count <- integer(n)
  positive <- !zero
  count[positive] <- 1L + rpois(sum(positive), s$lambda[level[positive]])
  A <- dist4(level, rep.int(1L,n))
  observed <- tv_pp(A, dist4(level,count))
  null_distances <- replicate(B, tv_pp(A, dist4(level, sample(count, replace=FALSE))))
  p_value <- (1 + sum(null_distances >= observed - 1e-12))/(B+1)
  c(distance_pp=observed, permutation_p=p_value,
    fixed_flag=as.integer(observed >= practical_cutoff_pp),
    permutation_reject=as.integer(p_value <= alpha))
}

# Per-setting fixed seeds ensure results do not change if other settings resume.
setting_id <- 0L
paths <- character()
for (scenario_name in names(scenarios)) {
  s <- scenarios[[scenario_name]]
  truth <- true_distance(s$z, s$lambda)
  for (n in sample_sizes) {
    setting_id <- setting_id + 1L
    for (first in seq(1L, R, by=batch_size)) {
      last <- min(first + batch_size - 1L, R)
      path <- file.path(output_dir,
        sprintf('batch_%02d_%05d_%05d.csv',setting_id,first,last))
      paths <- c(paths, path)
      if (file.exists(path)) {
        old <- read.csv(path, stringsAsFactors=FALSE)
        if (nrow(old) != last-first+1L ||
            !all(c('scenario','n','replicate','distance_pp','permutation_p') %in% names(old))) {
          stop('Existing batch is incomplete; inspect manually: ',path)
        }
        message('Preserved existing: ', basename(path))
        next
      }
      set.seed(20261021L + setting_id * 100000L + first)
      rows <- lapply(first:last, function(rep_no) {
        d <- run_one(s,n)
        data.frame(scenario=scenario_name,n=n,replicate=rep_no,
          true_distance_pp=truth,
          exchangeability_null=scenario_name %in% c('Low_equal_zeros','High_equal_zeros'),
          distance_pp=unname(d['distance_pp']),
          permutation_p=unname(d['permutation_p']),
          fixed_flag=as.integer(d['fixed_flag']),
          permutation_reject=as.integer(d['permutation_reject']))
      })
      result <- do.call(rbind, rows)
      tmp <- paste0(path,'.tmp')
      write.csv(result,tmp,row.names=FALSE)
      if (!file.rename(tmp,path)) stop('Could not save completed batch: ',path)
      message('Saved ', scenario_name, ' n=',n,' replications ',first,'–',last)
    }
  }
}
all_runs <- do.call(rbind, lapply(paths, read.csv, stringsAsFactors=FALSE))
stopifnot(nrow(all_runs)==length(scenarios)*length(sample_sizes)*R,
          !anyDuplicated(paste(all_runs$scenario,all_runs$n,all_runs$replicate)),
          all(is.finite(all_runs$distance_pp)),
          all(all_runs$permutation_p > 0 & all_runs$permutation_p <= 1))

# Wilson intervals are Monte Carlo intervals for simulation rejection rates.
wilson <- function(k,n,conf=0.95) {
  z <- qnorm(1-(1-conf)/2)
  ph <- k/n
  mid <- (ph+z*z/(2*n))/(1+z*z/n)
  half <- z*sqrt(ph*(1-ph)/n+z*z/(4*n*n))/(1+z*z/n)
  c(lower=mid-half,upper=mid+half)
}
groups <- split(all_runs,list(all_runs$scenario,all_runs$n),drop=TRUE)
summary_rows <- lapply(groups,function(x) {
  k <- sum(x$permutation_reject)
  ci <- wilson(k,nrow(x))
  truth <- x$true_distance_pp[1]
  data.frame(scenario=x$scenario[1],sample_size=x$n[1],replications=nrow(x),
    true_distance_pp=truth,mean_distance_pp=mean(x$distance_pp),
    bias_pp=mean(x$distance_pp-truth),
    rmse_pp=sqrt(mean((x$distance_pp-truth)^2)),
    fixed_flag_rate=mean(x$fixed_flag),
    permutation_reject_rate=mean(x$permutation_reject),
    perm_wilson_lower=ci['lower'],perm_wilson_upper=ci['upper'],
    exchangeability_null=x$exchangeability_null[1])
})
summary_table <- do.call(rbind,summary_rows)
rownames(summary_table) <- NULL
summary_table <- summary_table[order(summary_table$scenario,summary_table$sample_size),]
write.csv(all_runs,file.path(output_dir,'36_final_permutation_replications.csv'),row.names=FALSE)
write.csv(summary_table,file.path(output_dir,'37_final_permutation_summary.csv'),row.names=FALSE)
print(summary_table,row.names=FALSE)
message('FINAL SIMULATION COMPLETE; outputs at: ',normalizePath(output_dir))
message('WARNING: permutation inference concerns exchangeability, not the 5 pp practical threshold.')