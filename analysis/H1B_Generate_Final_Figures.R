# Regenerate Figures 1 and 2 from the archived final 15-setting summary.
# Base R only; no fabricated or manually transcribed simulation outcomes.
args <- commandArgs(trailingOnly=TRUE)
summary_path <- if(length(args)) args[1] else file.path("results","37_final_permutation_summary.csv")
out_dir <- if(length(args)>1) args[2] else "figures"
stopifnot(file.exists(summary_path))
dir.create(out_dir, showWarnings=FALSE, recursive=TRUE)
d <- read.csv(summary_path, stringsAsFactors=FALSE)
required <- c("scenario","sample_size","replications","rmse_pp","bias_pp",
              "permutation_reject_rate","perm_wilson_lower","perm_wilson_upper",
              "exchangeability_null")
stopifnot(!length(setdiff(required,names(d))), nrow(d)==15L,
          length(unique(d$scenario))==5L, all(d$replications==500L))
sc <- c("Low_equal_zeros","High_equal_zeros","Near_5pp",
        "Category_dependent_zeros","Unequal_positive_counts")
n_sizes <- c(250,1000,4000)
d <- d[order(match(d$scenario,sc),match(d$sample_size,n_sizes)),]
stopifnot(all(!is.na(d$sample_size)))
cols <- c("#243D75","#137C70","#CB703D")
names(cols) <- as.character(n_sizes)
x <- seq_len(nrow(d)) + rep(seq(0,4)*0.65,each=3L)
labels <- rep(c("250","1k","4k"),5)
group_locations <- vapply(seq_len(5),function(i) mean(x[((i-1)*3+1):(i*3)]),numeric(1))
short <- c("Low equal zeros","High equal zeros","Near 5 pp",
           "Category-dependent zeros","Unequal positive counts")

png(file.path(out_dir,"H1B_Figure1_Simulation_RMSE.png"),
    width=3200,height=1900,res=320,bg="white")
par(mar=c(9,5,4,2),mgp=c(2.7,0.8,0))
plot(x,d$rmse_pp,pch=19,col=cols[as.character(d$sample_size)],
     xlim=range(x)+c(-0.7,0.7),ylim=c(0,max(d$rmse_pp)*1.12),
     xaxt="n",xlab="",ylab="RMSE (percentage points)",
     main="Monte Carlo estimator accuracy across 15 settings",cex.main=1.15)
axis(1,at=x,labels=labels,cex.axis=0.75)
mtext(short,at=group_locations,side=1,line=3.0,cex=0.67)
mtext("Sample size (n)",side=1,line=5.4,cex=0.85)
abline(h=0,col="grey70")
segments(x,0,x,d$rmse_pp,col=adjustcolor(cols[as.character(d$sample_size)],alpha.f=0.6),lwd=3)
points(x,d$rmse_pp,pch=19,col=cols[as.character(d$sample_size)],cex=1.25)
legend("topright",legend=paste0("n = ",n_sizes),col=cols,pch=19,bty="n",cex=0.83)
dev.off()

png(file.path(out_dir,"H1B_Figure2_Permutation_Rejection.png"),
    width=3200,height=1900,res=320,bg="white")
par(mar=c(9,5,4,2),mgp=c(2.7,0.8,0))
plot(x,100*d$permutation_reject_rate,pch=19,col=cols[as.character(d$sample_size)],
     ylim=c(0,103),xaxt="n",xlab="",ylab="Permutation rejection (%)",
     main="Exchangeability test: null rejection and alternative power",cex.main=1.12)
axis(1,at=x,labels=labels,cex.axis=0.75)
mtext(short,at=group_locations,side=1,line=3.0,cex=0.67)
mtext("Sample size (n)",side=1,line=5.4,cex=0.85)
abline(h=5,lty=2,col="grey50")
segments(x,100*d$perm_wilson_lower,x,100*d$perm_wilson_upper,
         col=cols[as.character(d$sample_size)],lwd=2)
points(x,100*d$permutation_reject_rate,pch=19,
       col=cols[as.character(d$sample_size)],cex=1.2)
legend("right",legend=paste0("n = ",n_sizes),col=cols,pch=19,bty="n",cex=0.83)
mtext("95% Wilson intervals reflect Monte Carlo variability, not H-1B uncertainty",
      side=3,line=0.25,cex=0.67)
dev.off()
cat("Saved figures in",normalizePath(out_dir),"\n")
