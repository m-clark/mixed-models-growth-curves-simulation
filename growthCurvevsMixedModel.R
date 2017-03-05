# Comparing performance of growth curve models in an SEM framework vs standard mixed models.

# 5 within cluster sample sizes
# 5 cluster sample sizes
# 5 correlation sizes
# balanced vs. not  # maybe in the future



source('functions.R')

# Data Generation ---------------------------------------------------------


# Data setup and generation
nclusters = c(10, 25, 50)    
withinSizes = c(5, 10, 25)
corrs = seq(-.5,.5,.25)  
grid = expand.grid(nclusters, withinSizes, corrs); colnames(grid) = c('nClusters', 'nWithinCluster', 'corRE')

# for parallel balance, do larger sizes first
library(tidyverse)
grid = grid %>% 
  arrange(desc(nClusters*nWithinCluster))

# Run Models --------------------------------------------------------------

library(parallel)
clus = makeCluster(20)
clusterEvalQ(clus, library(nlme))
clusterEvalQ(clus, library(lavaan))
clusterEvalQ(clus, library(brms))
clusterExport(clus, c('runNLME', 'runNLME_REML', 'runGC', 'runBayes_rstan', 'dataGen'))

dataList = parApply(clus, grid, 1, function(x) replicate(500, dataGen(nclusters=x[1], nwithin=x[2], corr=x[3]), simplify=F))
names(dataList) = unite(grid, data, nClusters, nWithinCluster, corRE)[,1]

save(dataList, file='data/growthvsMixedResults.RData')

# because nlme keeps having issues in parallel (possibly only due to when I included nclus=5)
mixedResults = vector('list', length(dataList))

p = proc.time()
for (i in 1:length(dataList)) {
  mixedResults[[i]] = parLapplyLB(clus, dataList[[i]], runNLME)
  names(mixedResults) = names(dataList)
}
proc.time() - p # with 20 core ~22+ min
# mixedResults = sapply(dataList, function(dat) parLapply(clus, dat, runNLME), simplify=F)

mixedResults_REML = vector('list', length(dataList))
p = proc.time()
for (i in 1:length(dataList)) {
  mixedResults_REML[[i]] = parLapplyLB(clus, dataList[[i]], runNLME_REML)
  names(mixedResults_REML) = names(dataList)
}
proc.time() - p # with 20 core ~22+ min
# mixedResults = sapply(dataList, function(dat) parLapply(clus, dat, runNLME), simplify=F)
save(dataList, mixedResults, file='data/growthvsMixedResults.RData')

p = proc.time()
growthResults = sapply(dataList, function(dat) parLapplyLB(clus, dat, runGC), simplify=F)
names(growthResults) = names(dataList)
proc.time() - p  # with 20 core ~3+ min

save(dataList, growthResults, mixedResults, mixedResults_REML, file='data/growthvsMixedResults.RData')


### Bayes Results
# modelcode = brms::make_stancode(y ~ time + (1 + time|clus), data=dataList[[1]][[1]], save_model = 'stan/growthStan_orig.stan')
# standatlist1 = brms::make_standata(y ~ time + (1 + time|clus), data=dataList[[1]][[1]])
# standatlist2 = brms::make_standata(y ~ time + (1 + time|clus), data=dataList[[45]][[1]])
# sm = stan_model(file = 'stan/growthStan_orig.stan')
# test1 = sampling(sm, data=standatlist1)
# test2 = sampling(sm, data=standatlist2)
# 

# 
# # bayesResults = vector('list', length(dataList))
# library(rstan)
# sm = stan_model(file = 'stan/growthStan_orig.stan')
# clusterExport(clus, 'sm')
# 
# for (i in 18:length(bayesResults)) { # finishing previous, BE SURE TO PUT BACK TO 1
#   bayesResults[[i]] = parLapply(clus, dataList[[i]], function(d) runBayes_rstan(compcode=sm, data=d))
#   save(dataList, bayesResults, growthResults, mixedResults, file='data/growthvsMixed_ModelResults.RData')
# }


# save(dataList, bayesResults, growthResults, mixedResults, file='data/growthvsMixed_ModelResults.RData')



# Summarize Results -------------------------------------------------------


# Summarize Growth --------------------------------------------------------

growthFE = summarize_growth_mixed(growthResults, whichpar='fixed')
# individual resvar for all time points not examined
growthvarRE = summarize_growth_mixed(growthResults, whichpar='varRE')
growthcorRE = summarize_growth_mixed(growthResults, whichpar='corRE')


# Summarize Growth Clean --------------------------------------------------

growthFE_clean = summarize_growth_mixed(growthResults, whichpar='fixed', clean = T)
# individual resvar for all time points not examined
growthvarRE_clean = summarize_growth_mixed(growthResults, whichpar='varRE', clean = T)
growthcorRE_clean = summarize_growth_mixed(growthResults, whichpar='corRE', clean = T)


# Summarize Mixed ML ---------------------------------------------------------

mixedFE = summarize_growth_mixed(mixedResults, growth=F, whichpar='fixed')
# individual resvar for all time points not examined
mixedvarRE = summarize_growth_mixed(mixedResults, growth=F, whichpar='varRE')
mixedcorRE = summarize_growth_mixed(mixedResults, growth=F, whichpar='corRE')


# Summarize Mixed ML Clean ---------------------------------------------------

mixedFE_clean = summarize_growth_mixed(mixedResults, growth=F, whichpar='fixed', clean = T)
# individual resvar for all time points not examined
mixedvarRE_clean = summarize_growth_mixed(mixedResults, growth=F, whichpar='varRE', clean = T)
mixedcorRE_clean = summarize_growth_mixed(mixedResults, growth=F, whichpar='corRE', clean = T)


# Summarize Mixed REML ---------------------------------------------------------

mixedFE_REML = summarize_growth_mixed(mixedResults_REML, growth=F, whichpar='fixed')
# individual resvar for all time points not examined
mixedvarRE_REML = summarize_growth_mixed(mixedResults_REML, growth=F, whichpar='varRE')
mixedcorRE_REML = summarize_growth_mixed(mixedResults_REML, growth=F, whichpar='corRE')


# Summarize Mixed REML Clean ---------------------------------------------------

mixedFE_REML_clean = summarize_growth_mixed(mixedResults_REML, growth=F, whichpar='fixed', clean = T)
# individual resvar for all time points not examined
mixedvarRE_REML_clean = summarize_growth_mixed(mixedResults_REML, growth=F, whichpar='varRE', clean = T)
mixedcorRE_REML_clean = summarize_growth_mixed(mixedResults_REML, growth=F, whichpar='corRE', clean = T)




# Summarize Bayes ---------------------------------------------------------

# summarize results bayes
# fixed effects
# bayesFE0 = parSapply(clus, bayesResults, function(x) sapply(x, function(res) res$fixed), simplify=F)
# bayesFE = lapply(bayesFE0, function(res) c(rowMeans(res), c(apply(res, 1, quantile, p=c(.025,.975)))))
# bayesFE = do.call('rbind', bayesFE); colnames(bayesFE) = c('Int','Time', 'LL_Int', 'UL_Int', 'LL_Time', 'UL_Time')
# bayesFE = data.frame(grid, round(bayesFE, 2))
# 
# # residual variance
# bayesvarRes0 = parSapply(clus, bayesResults, function(x) sapply(x, function(res) res$varRes), simplify=F)
# 
# # random effects variance
# bayesvarRE0 = parSapply(clus, bayesResults, function(x) sapply(x, function(res) res$varRE), simplify=F)
# bayesvarRE = lapply(bayesvarRE0, function(res) c(rowMeans(res), c(apply(res, 1, quantile, p=c(.025,.975)))))
# bayesvarRE = do.call('rbind', bayesvarRE); colnames(bayesvarRE) = c('Int','Time', 'LL_Int', 'UL_Int', 'LL_Time', 'UL_Time')
# bayesvarRE = data.frame(grid, round(bayesvarRE, 2))
# 
# # cor random effects
# bayescorRE0 = parSapply(clus, bayesResults, function(x) sapply(x, function(res) res$corRE), simplify=F)
# bayescorRE = lapply(bayescorRE0, function(res) c(mean(res), quantile(res, p=c(.025,.975))))
# bayescorRE = do.call('rbind', bayescorRE); colnames(bayescorRE) = c('corRE_est', 'LL_corRE', 'UL_corRE')
# bayescorRE = data.frame(grid, round(bayescorRE, 2))


stopCluster(clus)

# Comparison of results ---------------------------------------------------
library(dplyr)


# LGC vs. Mixed ML --------------------------------------------------------

### Fixed effects
fixedEffects_ML = summary_df(growthFE, mixedFE,  whichpar = 'fixed')

### random effects
randomEffects_ML = summary_df(growthvarRE, mixedvarRE, whichpar = 'varRE')

### cor of random effects
randomEffectsCor_ML = summary_df(growthcorRE, mixedcorRE, whichpar = 'corRE')

feEst = fixedEffects_ML %>% select(one_of('nClusters', 'nWithinCluster', 'corRE'), Int.x, Time.x, Int.y, Time.y)
reEst = randomEffects_ML %>% select(one_of('nClusters', 'nWithinCluster', 'corRE'), Int.x, Time.x, Int.y, Time.y)
corEst = randomEffectsCor_ML %>% select(one_of('nClusters', 'nWithinCluster', 'corRE'),  corRE_est.x,  corRE_est.y)

biasFE_ML = bias(feEst, whichpar='fixed')
biasRE_ML = bias(reEst, whichpar = 'varRE')
biasREcor_ML = bias(corEst, whichpar = 'corRE')


# LGC vs. Mixed REML --------------------------------------------------------

### Fixed effects
fixedEffects_REML = summary_df(growthFE, mixedFE_REML,  whichpar = 'fixed')

### random effects
randomEffects_REML = summary_df(growthvarRE, mixedvarRE_REML, whichpar = 'varRE')

### cor of random effects
randomEffectsCor_REML = summary_df(growthcorRE, mixedcorRE_REML, whichpar = 'corRE')

feEst = fixedEffects_REML %>% select(one_of('nClusters', 'nWithinCluster', 'corRE'), Int.x, Time.x, Int.y, Time.y)
reEst = randomEffects_REML %>% select(one_of('nClusters', 'nWithinCluster', 'corRE'), Int.x, Time.x, Int.y, Time.y)
corEst = randomEffectsCor_REML %>% select(one_of('nClusters', 'nWithinCluster', 'corRE'),  corRE_est.x,  corRE_est.y)

biasFE_REML = bias(feEst, whichpar='fixed')
biasRE_REML = bias(reEst, whichpar = 'varRE')
biasREcor_REML = bias(corEst, whichpar = 'corRE')



# Comparison of results clean ---------------------------------------------


# LGC vs ML ---------------------------------------------------------------

### Fixed effects
fixedEffects_ML_clean = summary_df(growthFE_clean, mixedFE_clean,  whichpar = 'fixed')

### random effects
randomEffects_ML_clean = summary_df(growthvarRE_clean, mixedvarRE_clean, whichpar = 'varRE')

### cor of random effects
randomEffectsCor_ML_clean = summary_df(growthcorRE_clean, mixedcorRE_clean, whichpar = 'corRE')

feEst = fixedEffects_ML_clean %>% select(one_of('nClusters', 'nWithinCluster', 'corRE'), Int.x, Time.x, Int.y, Time.y)
reEst = randomEffects_ML_clean %>% select(one_of('nClusters', 'nWithinCluster', 'corRE'), Int.x, Time.x, Int.y, Time.y)
corEst = randomEffectsCor_ML_clean %>% select(one_of('nClusters', 'nWithinCluster', 'corRE'),  corRE_est.x,  corRE_est.y)

biasFE_ML_clean = bias(feEst, whichpar='fixed')
biasRE_ML_clean = bias(reEst, whichpar = 'varRE')
biasREcor_ML_clean = bias(corEst, whichpar = 'corRE')


# LGC vs. Mixed REML --------------------------------------------------------

### Fixed effects
fixedEffects_REML_clean = summary_df(growthFE_clean, mixedFE_REML_clean,  whichpar = 'fixed')

### random effects
randomEffects_REML_clean = summary_df(growthvarRE_clean, mixedvarRE_REML_clean, whichpar = 'varRE')

### cor of random effects
randomEffectsCor_REML_clean = summary_df(growthcorRE_clean, mixedcorRE_REML_clean, whichpar = 'corRE')

feEst = fixedEffects_REML_clean %>% select(one_of('nClusters', 'nWithinCluster', 'corRE'), Int.x, Time.x, Int.y, Time.y)
reEst = randomEffects_REML_clean %>% select(one_of('nClusters', 'nWithinCluster', 'corRE'), Int.x, Time.x, Int.y, Time.y)
corEst = randomEffectsCor_REML_clean %>% select(one_of('nClusters', 'nWithinCluster', 'corRE'),  corRE_est.x,  corRE_est.y)

biasFE_REML_clean = bias(feEst, whichpar='fixed')
biasRE_REML_clean = bias(reEst, whichpar = 'varRE')
biasREcor_REML_clean = bias(corEst, whichpar = 'corRE')




# Failures ----------------------------------------------------------------

growthFailures = sapply(growthResults, function(x) 
  sapply(x, function(res) any(is.nan(unlist(res)))), simplify=F)
mixedMLFailures = sapply(mixedResults, function(x) 
  sapply(x, function(res) any(res$corRE==1 | res$corRE==-1)), simplify=F)
mixedREMLFailures = sapply(mixedResults_REML, function(x) 
  sapply(x, function(res) any(res$corRE==1 | res$corRE==-1)), simplify=F)



save(grid, 
     fixedEffects_ML, randomEffects_ML, randomEffectsCor_ML, 
     biasFE_ML, biasRE_ML, biasREcor_ML,
     fixedEffects_ML_clean, randomEffects_ML_clean, randomEffectsCor_ML_clean, 
     biasFE_ML_clean, biasRE_ML_clean, biasREcor_ML_clean,
     fixedEffects_REML, randomEffects_REML, randomEffectsCor_REML, 
     biasFE_REML, biasRE_REML, biasREcor_REML,
     fixedEffects_REML_clean, randomEffects_REML_clean, randomEffectsCor_REML_clean, 
     biasFE_REML_clean, biasRE_REML_clean, biasREcor_REML_clean,
     growthFailures, mixedMLFailures, mixedREMLFailures,
     file='data/growthvsMixed_EstResults.RData')


