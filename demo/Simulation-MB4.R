
#------------------------------------
# Design parameters
#------------------------------------
iterations <- 20000
beta <- c(0,1,0,0)
phi <- seq(-7L, 7L, 2) / 10L
rho <- seq(0.0, 0.8, 0.2)
tau2_ratio <- c(0.1, 0.5)
tau_corr <- 0
p_const <- c(0,1,0,7)
m <- c(3,4,5,6,9,12)
n <- c(8, 16)

parms <- expand.grid(phi = phi, rho = rho, tau2_ratio = tau2_ratio, tau_corr = tau_corr, m = m, n=n)
print(lengths <- c(length(phi), length(rho), length(tau2_ratio), length(tau_corr), length(m), length(n)))
prod(lengths)
dim(parms)
head(parms)

#--------------------------------------
# run simulations in serial
#--------------------------------------

library(plyr)
library(scdhlm)
set.seed(19810112)
system.time(MB4results <- maply(parms, .fun = simulate_MB4, 
                                iterations = iterations, beta = beta, p_const = p_const,
                                .drop=FALSE, .progress = "text"))
attr(MB4results, "iterations") <- iterations
attr(MB4results, "beta") <- beta
attr(MB4results, "p_const") <- p_const
save(MB4results, file="data/MB4-results.RData")


#--------------------------------------------------------
# run simulations in parallel on Windows via SNOW
#--------------------------------------------------------

library(plyr)
library(snow)
library(foreach)
library(iterators)
library(doSNOW)
library(rlecuyer)

cluster <- makeCluster(8, type = "SOCK")
registerDoSNOW(cluster)

# set up parallel random number generator
clusterSetupRNGstream(cluster, 20131003)

# execute simulations
system.time(MB4results <- maply(parms, .fun = simulate_MB4, 
                                iterations = iterations, beta = beta, p_const = p_const,
                                .drop=FALSE, .parallel=TRUE,
                                .paropts = list(.packages="scdhlm")))
stopCluster(cluster)
attr(MB4results, "iterations") <- iterations
attr(MB4results, "beta") <- beta
attr(MB4results, "p_const") <- p_const
save(MB4results, file="data/MB4-results.RData")


#-------------------------------------------------------------
# run simulations in parallel on Mac via multicore
#-------------------------------------------------------------

# set up multicore
library(parallel)
library(foreach)
library(iterators)
library(doParallel)
registerDoParallel(cores=detectCores())

library(plyr)
library(scdhlm)

# execute simulations
system.time(MB4results <- maply(parms, .fun = simulate_MB4, 
                                iterations = iterations, beta = beta, p_const = p_const,
                                .drop=FALSE, .parallel=TRUE,
                                .paropts = list(.packages="scdhlm")))
attr(MB4results, "iterations") <- iterations
attr(MB4results, "beta") <- beta
attr(MB4results, "p_const") <- p_const
save(MB4results, file="data/MB4-results.RData")

#--------------------------------------
# Analyze results
#--------------------------------------