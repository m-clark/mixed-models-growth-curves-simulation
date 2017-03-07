# Functions ---------------------------------------------------------------


# ints and Times
dataGen <- function(nclusters, nwithin, corr=0, balanced=T) {
  # setup
  nclus = nclusters                                                       # number of groups
  clus = factor(rep(1:nclus, each=nwithin))                               # cluster variable
  n = length(clus)                                                        # total n

  # parameters
  sigma = 1                                                               # residual sd
  psi = matrix(c(1,corr,corr,1), 2, 2)                                    # re covar
  gamma_ = MASS::mvrnorm(nclus, mu=c(0,0), Sigma=psi, empirical=TRUE)     # random effects
  e = rnorm(n, mean=0, sd=sigma)                                          # residual error
  intercept = 3                                                           # fixed effects
  b1 = .75

  # data
  x = rep(1:nwithin-1, times=nclus)                                       # covariate
  y = intercept+gamma_[clus,1] + (b1+gamma_[clus,2])*x  + e               # target
  d = data.frame(time=x, y, clus=clus)
}

# nlme control msMaxIter, msMaxEval, abs.tol set to lavaan defaults
runNLME <- function(data) {
  nlmemod = lme(y ~ time, data=data, random =  ~time|clus,
                control=list(maxIter=1000, msMaxIter=10000, msMaxEval=20000, returnObject=T, abs.tol=2.220446e-15),
                weights=varIdent(form = ~1|time), method='ML')
  varRes = coef(nlmemod$modelStruct$varStruct, unconstrained =FALSE,allCoef=T)*nlmemod$sigma
  varRE  = as.numeric(VarCorr(nlmemod)[1:2,1])
  corRE = as.numeric(VarCorr(nlmemod)['time','Corr'])
  fixed = fixef(nlmemod)
  list(varRes=varRes, varRE=varRE, corRE=corRE, fixed=fixed)
}

runNLME_REML <- function(data) {
  nlmemod = lme(y ~ time, data=data, random =  ~time|clus,
                control=list(maxIter=1000, msMaxIter=10000, msMaxEval=20000, returnObject=T, abs.tol=2.220446e-15),
                weights=varIdent(form = ~1|time), method='REML')
  varRes = coef(nlmemod$modelStruct$varStruct, unconstrained =FALSE,allCoef=T)*nlmemod$sigma
  varRE  = as.numeric(VarCorr(nlmemod)[1:2,1])
  corRE = as.numeric(VarCorr(nlmemod)['time','Corr'])
  fixed = fixef(nlmemod)
  list(varRes=varRes, varRE=varRE, corRE=corRE, fixed=fixed)
}

runGAM <- function(data) {
  gammod = gam(y ~ time + s(clus, bs='re') + s(time, clus, bs='re'), data=data,
                method='REML')
  varRes = gammod$sig2
  varRE  = gam.vcomp(gammod)[1:2,1]^2
  # corRE = as.numeric(VarCorr(nlmemod)['time','Corr'])
  fixed = coef(gammod)[1:2]
  list(varRes=varRes, varRE=varRE, corRE=NULL, fixed=fixed)
}

runBayes_brm = function(data, ...){
  # variance heterogeneity coming in next release
  bayesmod = brm(y ~ time + (1 + time|clus), data = data,
                 iter = 6000, warmup=1000, thin=20,
                 prior = set_prior("normal(0,10)", class = "b"),
                 ...)
  vc = VarCorr(bayesmod)
  varRes = VarCorr(bayesmod)[[2]][['cov']][['mean']]
  varRE = diag(VarCorr(bayesmod)[[1]][['cov']][['mean']])
  corRE = VarCorr(bayesmod)[[1]][['cor']][['mean']][2]
  fixed = fixef(bayesmod)[,'mean']
  list(varRes=varRes, varRE=varRE, corRE=corRE, fixed=fixed)
}

runBayes_rstan = function(compcode, data, ...){
  standat = brms::make_standata(y ~ time + (1 + time|clus), data=data)
  bayesmod = sampling(sm, data = standat,
                      iter = 6000, warmup=1000, thin=20,...)
  varRes = get_posterior_mean(bayesmod, 'sigma')[,'mean-all chains']
  varRE = get_posterior_mean(bayesmod, 'sd_1')[,'mean-all chains']
  corRE = get_posterior_mean(bayesmod, 'cor_1')[,'mean-all chains']
  fixed = get_posterior_mean(bayesmod, pars=c('b_Intercept', 'b'))[,'mean-all chains']
  list(varRes=varRes, varRE=varRE, corRE=corRE, fixed=fixed)
}


runGC <- function(data) {
  ntime = unique(data$time)
  data$time = factor(data$time)
  dataWide = tidyr::spread(data, time, y)
  colnames(dataWide)[-1] = paste0('y', colnames(dataWide)[-1])

  IModel = paste0('I =~ 1*y0 ', paste0('+ 1*', colnames(dataWide)[-c(1:2)], collapse=''), '\n')
  SModel = paste0('S =~ 0*y0 ', paste0('+ ', 1:dplyr::last(ntime), '*', colnames(dataWide)[-c(1:2)], collapse=''), '\n')
  CenterY = paste0('y0', paste0(' + ', colnames(dataWide)[-c(1:2)], collapse=''), ' ~ 0*1')
  LVmodel = paste0(IModel, SModel, CenterY)

  suppressWarnings({semres = growth(LVmodel, data=dataWide)})
  varRes = sqrt(coef(semres)[ntime+1])
  varRE = coef(semres)[c('I~~I','S~~S')]
  covRE = coef(semres)[c('I~~S')]
  corRE = covRE/prod(sqrt(varRE))
  fixed = coef(semres)[c('I~1', 'S~1')]
  list(varRes=varRes, varRE=varRE, corRE=corRE, fixed=fixed)
}


summarize_growth_mixed <- function(results, growth=T, whichpar='fixed', clean=F, settings=grid) {

  if (!clean) fail_idx = replicate(45, rep(FALSE, 500), simplify = F)
  if (clean) {
    if (growth){
     fail_idx =  sapply(results, function(x)
      sapply(x, function(res) any(is.nan(unlist(res)))), simplify=F)  # | abs(res$corRE)>1
    }
    else {
     fail_idx =  sapply(results, function(x)
      sapply(x, function(res) any(res$corRE==1 | res$corRE==-1)), simplify=F)
    }
  }

  if(whichpar=='fixed'){
    # fixed effects
    resultFE0 = sapply(1:length(results), function(x)
      sapply(results[[x]][!fail_idx[[x]]], function(res) res$fixed), simplify=F)
    resultFE = lapply(resultFE0, function(res) c(rowMeans(res), c(apply(res, 1, quantile, p=c(.025,.975)))))
    resultFE = do.call('rbind', resultFE); colnames(resultFE) = c('Int','Time', 'LL_Int', 'UL_Int', 'LL_Time', 'UL_Time')
    resultFE = data.frame(settings,  resultFE)
    return(resultFE)
  }

  if(whichpar=='varRes'){
    stop('Not wanting to parse residual variance for 5 to 25 scores at present. :P')
    # residual variance
    # resultvarRes0 = sapply(1:length(results), function(x)
    #   sapply(results[[x]][!fail_idx[[x]]], function(res) res$varRes), simplify=F)
    # resultvarRes = lapply(resultvarRes0, function(res) c(rowMeans(res), c(apply(res, 1, quantile, p=c(.025,.975)))))
    # resultvarRes = do.call('rbind', resultvarRes); colnames(resultFE) = c('Int','Time', 'LL_Int', 'UL_Int', 'LL_Time', 'UL_Time')
    # resultvarRes = data.frame(settings, round(resultvarRes, 2))
    # return(resultvarRes)
  }

  if (whichpar=='varRE'){
    # random effects variance
    resultvarRE0 = sapply(1:length(results), function(x)
      sapply(results[[x]][!fail_idx[[x]]], function(res) res$varRE), simplify=F)
    resultvarRE = lapply(resultvarRE0, function(res) c(rowMeans(res), c(apply(res, 1, quantile, p=c(.025,.975)))))
    resultvarRE = do.call('rbind', resultvarRE); colnames(resultvarRE) = c('Int','Time', 'LL_Int', 'UL_Int', 'LL_Time', 'UL_Time')
    resultvarRE = data.frame(settings, resultvarRE)
    return(resultvarRE)
  }

  if (whichpar=='corRE'){
    # cor random effects
    resultcorRE0 = sapply(1:length(results), function(x)
      sapply(results[[x]][!fail_idx[[x]]], function(res) res$corRE), simplify=F)
    resultcorRE = lapply(resultcorRE0, function(res) c(mean(res, na.rm=T), quantile(res, p=c(.025,.975), na.rm=T)))
    resultcorRE = do.call('rbind', resultcorRE); colnames(resultcorRE) = c('corRE_est', 'LL_corRE', 'UL_corRE')
    resultcorRE = data.frame(settings, resultcorRE)
    return(resultcorRE)
    }
}

summary_df <- function(g, m, whichpar='fixed') {
  require(dplyr)

  if(whichpar=='fixed'){
    # fixed effects
    res = left_join(g, m, by=c('nClusters', 'nWithinCluster', 'corRE')) %>%
      arrange(nClusters, nWithinCluster, corRE) %>%
      mutate(widthGrowth_Int = UL_Int.x-LL_Int.x,
             widthMixed_Int =  UL_Int.y-LL_Int.y,
             mixedWidthMinusgrowthWidth_Int = widthMixed_Int-widthGrowth_Int,
             widthGrowth_Time = UL_Time.x-LL_Time.x,
             widthMixed_Time =  UL_Time.y-LL_Time.y,
             mixedWidthMinusgrowthWidth_Time = widthMixed_Time-widthGrowth_Time)
    return(res)
  }

  if(whichpar=='varRes'){
    stop('Not wanting to parse residual variance for 5 to 25 scores at present. :P')
    # residual variance
    # growthvarRes0 = sapply(1:length(results), function(x)
    #   sapply(results[[x]][!fail_idx[[x]]], function(res) res$varRes), simplify=F)
    # growthvarRes = lapply(growthvarRes0, function(res) c(rowMeans(res), c(apply(res, 1, quantile, p=c(.025,.975)))))
    # growthvarRes = do.call('rbind', growthvarRes); colnames(growthFE) = c('Int','Time', 'LL_Int', 'UL_Int', 'LL_Time', 'UL_Time')
    # growthvarRes = data.frame(grid, round(growthvarRes, 2))
    # return(growthvarRes)
  }

  if (whichpar=='varRE'){
    # random effects variance
    res = left_join(g, m, by=c('nClusters', 'nWithinCluster', 'corRE')) %>%
      arrange(nClusters, nWithinCluster, corRE) %>%
      mutate(widthGrowth_Int = UL_Int.x-LL_Int.x,
             widthMixed_Int =  UL_Int.y-LL_Int.y,
             mixedWidthMinusgrowthWidth_Int = widthMixed_Int-widthGrowth_Int,
             widthGrowth_Time = UL_Time.x-LL_Time.x,
             widthMixed_Time =  UL_Time.y-LL_Time.y,
             mixedWidthMinusgrowthWidth_Time = widthMixed_Time-widthGrowth_Time)
    return(res)
  }

  if (whichpar=='corRE'){
    # cor random effects
    res = left_join(g, m, by=c('nClusters', 'nWithinCluster', 'corRE')) %>%
      arrange(nClusters, nWithinCluster, corRE) %>%
      mutate(widthGrowth = UL_corRE.x-LL_corRE.x,
             widthMixed =  UL_corRE.y-LL_corRE.y,
             mixedWidthMinusgrowthWidth = widthMixed-widthGrowth)
    return(res)
    }
}


bias <- function(res, whichpar='fixed') {
  require(dplyr)
  if (whichpar=='fixed') {
    out = res %>%
      arrange(nClusters, nWithinCluster, corRE) %>%
      mutate(biasLGC_Int = Int.x-3,
             biasLGC_Time = Time.x-.75,
             biasMM_Int = Int.y-3,
             biasMM_Time = Time.y-.75)
    return(out)
  }

  else if (whichpar=='varRE') {
    out = res %>%
      arrange(nClusters, nWithinCluster, corRE) %>%
      mutate(biasLGC_Int = Int.x-1,
             biasLGC_Time = Time.x-1,
             biasMM_Int = Int.y-1,
             biasMM_Time = Time.y-1)
  }

  else if (whichpar=='corRE'){
    out = corEst %>%
      arrange(nClusters, nWithinCluster, corRE) %>%
      mutate(biasLGC_corRE = corRE_est.x-corRE,
             biasMM_corRE = corRE_est.y-corRE)
  }

  return(out)

}