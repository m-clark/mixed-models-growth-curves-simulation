# Growth Curve and Mixed Models
Michael Clark  
`r Sys.Date()`  



# Intro

I wanted to compare latent growth curve (LGC) and mixed models for settings with low(ish) numbers of clusters.  As an example, having 50 individuals with measured at 4 time points each wouldn't cause many to think twice in the mixed model setting, while running a structural equation model with 50 individuals has never been recommended. However, growth curve models are a notably constrained type of SEM, as many parameters are fixed, which helps matters, but I wanted to investigate this further. 

# Setup

I put together some code for simulation. The parameters are as follows:

- Number of clusters (3): 10, 25, 50 
- Time points within cluster (3): 5, 10, 25
- Correlation of random effects (5): -.5 to .5 

Thus sample sizes range from the ridiculously small (10\*5 = 50 total observations) to fairly healthy (50\*25 = 1250 total). Random effects were drawn from a multivariate normal and had that exact correlation (i.e. there was no distribution for the correlation; using the <span class="pack">MASS</span> package with `empirical = TRUE`).  Fixed effects are 3 and .75 for the intercept and effect of 'time'. Variances of the random effects and residuals were set to `1.0`.  Note that the mixed model estimated residual variance separately for each time point as would be the default in the LGC model, however due to the number of estimates they won't we shown in what follows. Number of simulated data sets for each of the 45 settings is 500.

Growth curve models were estimated with the R package <span class="pack">lavaan</span>, the mixed models were estimated with <span class="pack">nlme</span> with `varIdent` weights argument.  Both use the <span class="func">nlminb</span> optimizer that comes with base R by default.  I had to change some of the default optimizer settings with nlme to be more in keeping with lavaan's default[^nlminb].  With enough data, estimates should be identical, but the point here is to investigate performance in the low N setting.

# Results

The initial set of results compares the Latent Growth Curve and mixed model, both estimated via maximum likelihood. First bias in parameter estimates is noted, then interval widths compared. Note that this takes all results as they are, even if there were potential problems in the estimation process.


## Parameter estimates

Bias here refers to the difference in the mean estimated parameter value vs. the true.

### Fixed effects


Maybe slight issues with the smallest samples sizes for the intercept, but nothing worrisome.

<!--html_preserve--><div id="htmlwidget-10fc762abc65bc796e32" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-10fc762abc65bc796e32">{"x":{"filter":"none","data":[[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50],[5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25],[-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5],[-0.011,-0.001,0.002,-0.028,-0.007,-0.007,0.006,-0.009,-0.005,0.01,0.004,0.002,0,0.005,-0.009,0.005,-0,0.009,0.005,-0.002,-0.003,-0.002,0.003,-0.005,-0.012,-0.005,0.001,0.002,-0.003,-0.001,-0.007,0.002,-0.002,0.002,-0.009,0.005,-0.003,0.003,-0.004,0,0.006,-0,-0.001,-0.003,0.002],[-0.002,-0.004,-0.003,-0.023,-0.005,-0.009,0.008,-0.009,-0.005,0.009,0.004,0.002,0,0.005,-0.009,0.005,-0.001,0.009,0.005,-0.002,-0.003,-0.002,0.003,-0.005,-0.012,-0.005,0.001,0.002,-0.003,-0.001,-0.007,0.002,-0.002,0.002,-0.009,0.005,-0.003,0.003,-0.004,0,0.006,-0,-0.001,-0.003,0.002],[0.007,0.004,0,0.012,0.007,0,-0.001,0.002,0,-0.001,-0,-0,0,-0,0,-0.003,0.002,-0.002,-0.002,-0.001,0.002,0.001,-0,0.001,0.002,0,-0,-0,0,-0,0.004,-0.001,0.002,-0,0.003,-0,0,-0,0.001,0.001,-0,0,-0,0,-0],[0,0.004,0.002,0.011,0.004,0.001,-0.001,0.002,0,-0.001,-0,-0,0,-0,0,-0.003,0.002,-0.002,-0.002,-0.001,0.002,0.001,-0,0.001,0.002,0,-0,-0,0,-0,0.004,-0.001,0.002,-0,0.003,-0,0,-0,0.001,0.001,-0,0,-0,0,-0]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>nClusters<\/th>\n      <th>nWithinCluster<\/th>\n      <th>corRE<\/th>\n      <th>biasLGC_Int<\/th>\n      <th>biasMM_Int<\/th>\n      <th>biasLGC_Time<\/th>\n      <th>biasMM_Time<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":45,"width":250,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4,5,6]}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,25,45,50,100]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


### Random effect variance

Both underestimate random effects variance at these settings, and more so with smaller overall sample sizes, perhaps a little less with the LGC in the smallest N setting.

<!--html_preserve--><div id="htmlwidget-0eb6e1e118f0f3449215" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-0eb6e1e118f0f3449215">{"x":{"filter":"none","data":[[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50],[5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25],[-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5],[-0.077,-0.114,-0.062,-0.077,-0.068,-0.107,-0.097,-0.128,-0.098,-0.09,-0.114,-0.112,-0.117,-0.118,-0.117,-0.088,-0.055,-0.08,-0.038,-0.075,-0.045,-0.059,-0.041,-0.032,-0.029,-0.057,-0.045,-0.057,-0.049,-0.049,-0.038,-0.022,-0.035,-0.041,-0.027,-0.011,-0.033,-0.027,-0.025,-0.037,-0.03,-0.019,-0.035,-0.028,-0.026],[-0.113,-0.137,-0.104,-0.091,-0.055,-0.121,-0.106,-0.142,-0.118,-0.087,-0.114,-0.113,-0.117,-0.118,-0.118,-0.09,-0.059,-0.081,-0.037,-0.067,-0.045,-0.059,-0.041,-0.032,-0.029,-0.057,-0.045,-0.057,-0.049,-0.049,-0.038,-0.022,-0.036,-0.041,-0.026,-0.011,-0.033,-0.027,-0.025,-0.037,-0.03,-0.019,-0.035,-0.028,-0.026],[-0.07,-0.095,-0.086,-0.087,-0.09,-0.1,-0.104,-0.094,-0.098,-0.099,-0.102,-0.1,-0.099,-0.101,-0.1,-0.043,-0.044,-0.044,-0.052,-0.028,-0.039,-0.04,-0.039,-0.044,-0.048,-0.04,-0.041,-0.041,-0.039,-0.04,-0.015,-0.023,-0.02,-0.025,-0.017,-0.018,-0.018,-0.02,-0.019,-0.018,-0.02,-0.02,-0.02,-0.02,-0.02],[-0.107,-0.116,-0.105,-0.107,-0.109,-0.101,-0.104,-0.095,-0.098,-0.099,-0.101,-0.1,-0.099,-0.101,-0.1,-0.046,-0.048,-0.046,-0.054,-0.028,-0.039,-0.04,-0.039,-0.044,-0.048,-0.04,-0.041,-0.041,-0.039,-0.04,-0.015,-0.023,-0.02,-0.025,-0.017,-0.018,-0.018,-0.02,-0.019,-0.018,-0.02,-0.02,-0.02,-0.02,-0.02]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>nClusters<\/th>\n      <th>nWithinCluster<\/th>\n      <th>corRE<\/th>\n      <th>biasLGC_Int<\/th>\n      <th>biasMM_Int<\/th>\n      <th>biasLGC_Time<\/th>\n      <th>biasMM_Time<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":45,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4,5,6]}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,25,45,50,100]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


### Random effect correlation

With few time points (5, 10) and/or smaller number of clusters (10, 25), both generally seem to exhibit positive bias, maybe more so with LGC, and both have a tendency to have more problem with positive correlation.

<!--html_preserve--><div id="htmlwidget-ad2131499c3ca38848c8" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-ad2131499c3ca38848c8">{"x":{"filter":"none","data":[[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50],[5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25],[-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5],[-0.003,0.076,0.09,0.137,0.164,-0.023,0.024,0.026,0.038,0.065,0.002,0.003,-0,0.018,0.023,-0.006,0.033,0.046,0.067,0.07,-0.01,0.002,0.004,0.023,0.035,-0.005,0.003,0.001,-0.003,0.006,-0.002,0.008,0.023,0.038,0.031,-0.003,-0.004,0.005,0.003,0.004,0,0.002,-0,0.006,0.002],[0.017,0.116,0.139,0.13,0.091,-0.018,0.023,0.016,0.04,0.044,0.002,0.001,-0.001,0.019,0.023,0.002,0.037,0.049,0.069,0.05,-0.01,0.002,0.004,0.023,0.035,-0.005,0.003,0.001,-0.003,0.006,-0.002,0.009,0.023,0.038,0.025,-0.003,-0.004,0.005,0.003,0.004,0,0.002,-0,0.006,0.002]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>nClusters<\/th>\n      <th>nWithinCluster<\/th>\n      <th>corRE<\/th>\n      <th>biasLGC_corRE<\/th>\n      <th>biasMM_corRE<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":45,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4]}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,25,45,50,100]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


## Interval width

95% confidence intervals were taken as the .025 and .975 quantiles of the simulation estimates.

### Fixed effects

General trend of narrower interval estimates for mixed models with smaller sample settings, and low number of clusters generally. The LGC and Mixed Model come together fairly quickly though. We'll discuss the issues involved in the next section.

<!--html_preserve--><div id="htmlwidget-ff424b7719b96fd3a617" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-ff424b7719b96fd3a617">{"x":{"filter":"none","data":[[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50],[5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25],[-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5],[1.194,1.211,1.165,1.272,1.24,0.91,0.854,0.92,0.859,0.843,0.577,0.538,0.529,0.582,0.57,0.626,0.674,0.715,0.629,0.663,0.497,0.463,0.449,0.495,0.48,0.286,0.332,0.301,0.333,0.3,0.439,0.423,0.462,0.451,0.437,0.345,0.331,0.322,0.345,0.332,0.21,0.215,0.224,0.212,0.217],[1.068,1.16,1.107,1.137,1.153,0.906,0.818,0.89,0.842,0.834,0.578,0.538,0.529,0.582,0.57,0.623,0.67,0.708,0.629,0.664,0.497,0.463,0.449,0.495,0.48,0.286,0.332,0.301,0.333,0.3,0.439,0.423,0.462,0.451,0.437,0.345,0.331,0.322,0.345,0.332,0.21,0.215,0.224,0.212,0.217],[0.574,0.566,0.531,0.525,0.58,0.169,0.165,0.185,0.168,0.166,0.042,0.038,0.039,0.04,0.038,0.27,0.266,0.3,0.27,0.262,0.09,0.087,0.086,0.09,0.084,0.02,0.023,0.021,0.024,0.02,0.198,0.17,0.183,0.174,0.174,0.063,0.065,0.06,0.067,0.061,0.016,0.016,0.016,0.015,0.015],[0.44,0.491,0.454,0.444,0.489,0.165,0.154,0.176,0.155,0.16,0.042,0.038,0.039,0.04,0.038,0.269,0.262,0.293,0.265,0.262,0.09,0.087,0.086,0.09,0.084,0.02,0.023,0.021,0.024,0.02,0.196,0.17,0.183,0.174,0.174,0.063,0.065,0.06,0.067,0.061,0.016,0.016,0.016,0.015,0.015],[-0.126,-0.051,-0.058,-0.136,-0.087,-0.004,-0.035,-0.03,-0.017,-0.009,0,0,0,-0,0,-0.003,-0.004,-0.007,-0,0.001,0,0,0,0,-0,-0,0,-0,0,0,0,-0,-0,0,0,-0,-0,-0,-0,0,-0,-0,-0,0,-0],[-0.134,-0.076,-0.077,-0.081,-0.091,-0.005,-0.011,-0.008,-0.013,-0.006,-0,-0,0,-0,-0,-0.001,-0.004,-0.007,-0.005,-0,-0,-0,-0,-0,0,-0,0,-0,-0,0,-0.002,-0,0,0,0,-0,-0,-0,-0,0,-0,0,-0,0,0]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>nClusters<\/th>\n      <th>nWithinCluster<\/th>\n      <th>corRE<\/th>\n      <th>widthGrowth_Int<\/th>\n      <th>widthMixed_Int<\/th>\n      <th>widthGrowth_Time<\/th>\n      <th>widthMixed_Time<\/th>\n      <th>mixedWidthMinusgrowthWidth_Int<\/th>\n      <th>mixedWidthMinusgrowthWidth_Time<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":45,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4,5,6,7,8]}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,25,45,50,100]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

### Random effect variance

General trend of narrower interval estimates for mixed models with smaller sample settings, and low number of clusters generally.

<!--html_preserve--><div id="htmlwidget-3c2d28dfb234e1802e27" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-3c2d28dfb234e1802e27">{"x":{"filter":"none","data":[[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50],[5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25],[-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5],[3.002,3.017,3.243,3.181,3.057,1.889,1.84,1.84,1.722,1.924,1.141,1.138,1.146,1.024,1.07,1.609,1.737,1.56,1.504,1.394,1.055,1.032,1.083,1.065,1.082,0.66,0.627,0.636,0.639,0.64,1.227,1.077,0.986,1.146,1.149,0.767,0.72,0.724,0.777,0.701,0.458,0.475,0.455,0.488,0.446],[2.299,2.305,2.388,2.34,2.363,1.712,1.784,1.815,1.646,1.749,1.141,1.138,1.143,1.024,1.067,1.592,1.737,1.551,1.488,1.352,1.055,1.032,1.083,1.065,1.082,0.661,0.627,0.636,0.639,0.64,1.227,1.077,0.986,1.146,1.137,0.767,0.72,0.724,0.777,0.701,0.458,0.475,0.455,0.488,0.446],[1.12,1.038,1.037,1.034,1.021,0.304,0.333,0.326,0.283,0.3,0.077,0.074,0.076,0.081,0.078,0.531,0.55,0.519,0.578,0.526,0.183,0.185,0.177,0.174,0.17,0.043,0.048,0.045,0.042,0.046,0.354,0.369,0.375,0.357,0.369,0.133,0.123,0.127,0.124,0.125,0.029,0.031,0.032,0.031,0.031],[0.89,0.923,0.907,0.957,0.905,0.29,0.322,0.314,0.275,0.296,0.077,0.073,0.075,0.08,0.078,0.528,0.529,0.519,0.564,0.488,0.183,0.185,0.177,0.174,0.17,0.043,0.048,0.045,0.042,0.046,0.352,0.369,0.373,0.357,0.369,0.133,0.123,0.127,0.124,0.125,0.029,0.031,0.032,0.031,0.031],[-0.703,-0.712,-0.855,-0.841,-0.694,-0.176,-0.057,-0.026,-0.076,-0.175,0,-0,-0.003,-0,-0.003,-0.017,0,-0.009,-0.017,-0.041,-0,0,-0,0,0,0,0,0,-0,0,-0,-0,0,-0,-0.012,0,-0,0,-0,0,-0,0,0,0,-0],[-0.231,-0.115,-0.129,-0.077,-0.116,-0.013,-0.011,-0.012,-0.008,-0.004,-0,-0.001,-0.001,-0.001,0,-0.003,-0.021,0,-0.014,-0.038,0,-0,0,0,-0,0,-0,0,0,0,-0.002,-0,-0.002,0,-0,0,-0,-0,-0,-0,-0,0,-0,-0,0]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>nClusters<\/th>\n      <th>nWithinCluster<\/th>\n      <th>corRE<\/th>\n      <th>widthGrowth_Int<\/th>\n      <th>widthMixed_Int<\/th>\n      <th>widthGrowth_Time<\/th>\n      <th>widthMixed_Time<\/th>\n      <th>mixedWidthMinusgrowthWidth_Int<\/th>\n      <th>mixedWidthMinusgrowthWidth_Time<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":45,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4,5,6,7,8]}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,25,45,50,100]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


### Random effect correlation

The actual interval estimates for LGC were not confined to [-1,1], and both struggle in the small N setting. At about a total N observed of 100 they begin to be consistent.

<!--html_preserve--><div id="htmlwidget-0e1802210780317cc136" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-0e1802210780317cc136">{"x":{"filter":"none","data":[[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50],[5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25],[-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5],[1.409,1.754,1.783,2.455,2.43,0.887,1.034,1.195,1.057,1.166,0.527,0.574,0.647,0.634,0.578,0.635,0.772,0.948,1.095,1.199,0.429,0.478,0.5,0.53,0.551,0.269,0.339,0.325,0.317,0.282,0.372,0.476,0.602,0.606,0.724,0.296,0.314,0.347,0.356,0.341,0.194,0.22,0.221,0.216,0.208],[1.912,2,1.666,1.391,1.123,0.958,1.032,1.248,1.042,0.958,0.527,0.58,0.639,0.635,0.578,0.644,0.778,0.972,1.096,0.924,0.429,0.478,0.501,0.53,0.55,0.269,0.339,0.325,0.317,0.282,0.37,0.476,0.602,0.606,0.723,0.295,0.314,0.347,0.355,0.342,0.194,0.219,0.222,0.216,0.208],[0.503,0.246,-0.117,-1.064,-1.307,0.071,-0.002,0.053,-0.014,-0.208,0,0.006,-0.009,0,-0,0.008,0.007,0.024,0.001,-0.275,-0,-0,0.001,0,-0,0,0,0,-0,0,-0.002,-0,-0,-0,-0,-0,-0,0,-0,0.001,0,-0.001,0,-0,-0]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>nClusters<\/th>\n      <th>nWithinCluster<\/th>\n      <th>corRE<\/th>\n      <th>widthGrowth<\/th>\n      <th>widthMixed<\/th>\n      <th>mixedWidthMinusgrowthWidth<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":45,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4,5]}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,25,45,50,100]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

# Estimation issues

With the smaller sample sizes we run into numerous issues in estimation.  In typical SEM settings this may result in negative variance estimates or other problems.  With mixed models, estimation of a perfect correlation of random intercepts and slopes might similarly call for further diagnostic inspection.  In addition, we know mixed models are biased for variance estimates when using maximum likelihood with small samples. As such, most mixed models packages will default to restricted maximum likelihood (REML) which serves to counter this bias.

I've defined 'failure' as any run that resulted in a `NaN` for <span class="pack">lavaan</span>, or a perfect positive/negative correlation for <span class="pack">nlme</span>, i.e., where the correlation equaled 1.0 with no rounding. The following shows the proportion of such failures, which are quite dramatic for the growth curve approach. We also see REML performs better than ML for the mixed model approach.

<!--html_preserve--><div id="htmlwidget-f205c7f88f39ec02e7cf" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-f205c7f88f39ec02e7cf">{"x":{"filter":"none","data":[[10,10,10,10,10,10,10,10,10,10,25,25,25,25,25,50,50,50,10,10,50,10,10,10,25,50,25,25,50,50,50,50,50,25,25,25,25,25,50,50,50,50,50,25,25],[5,5,5,5,5,10,10,10,10,10,5,5,5,5,5,5,5,5,25,25,5,25,25,25,10,5,10,10,25,25,25,25,25,25,25,25,25,25,10,10,10,10,10,10,10],[-0.5,-0.25,0,0.25,0.5,-0.25,0,-0.5,0.5,0.25,0.25,-0.25,-0.5,0.5,0,0,-0.25,-0.5,-0.25,-0.5,0.25,0.5,0,0.25,0,0.5,0.5,-0.25,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,0.25],[0.504,0.5,0.456,0.44,0.424,0.162,0.138,0.136,0.13,0.128,0.11,0.108,0.1,0.082,0.076,0.02,0.018,0.016,0.016,0.014,0.014,0.012,0.008,0.008,0.004,0.004,0.004,0.002,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0.064,0.072,0.082,0.12,0.196,0.01,0.01,0.03,0.07,0.008,0.028,0.006,0.006,0.076,0.012,0.002,0,0,0.002,0,0,0.004,0,0,0,0.016,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0.048,0.058,0.062,0.096,0.162,0.006,0.008,0.016,0.052,0.006,0.028,0.004,0.006,0.068,0.006,0,0,0,0.002,0,0,0.002,0,0,0,0.016,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>nClusters<\/th>\n      <th>nWithinCluster<\/th>\n      <th>corRE<\/th>\n      <th>growthFailures<\/th>\n      <th>mixedFailures<\/th>\n      <th>mixedREMLFailures<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":45,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4,5]}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,25,45,50,100]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->



# Results Clean

Given the estimation issues, here are results for situations in which those did not exist. This perhaps puts the estimation approaches on unequal footing since the criterion is different, but it still may be informative.  In addition, I've chosen the REML estimates for mixed model results.  However, the differences become negligible with more observations, as we have already seen and would expect from the outset.


## Parameter estimates

### Fixed effects


<!--html_preserve--><div id="htmlwidget-ffc83e72a869e8280c9a" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-ffc83e72a869e8280c9a">{"x":{"filter":"none","data":[[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50],[5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25],[-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5],[0.011,-0.012,0.02,-0.013,0.001,-0.009,0.007,-0.003,-0.004,0.005,0.003,0.003,-0,0.004,-0.01,0.002,-0.003,0.01,0.003,-0.001,-0.003,-0.001,0.003,-0.005,-0.012,-0.005,0.001,0.002,-0.003,-0.001,-0.007,0.001,-0.001,0.003,-0.009,0.005,-0.003,0.003,-0.004,0,0.006,-0,-0.001,-0.003,0.002],[0.002,-0.005,-0.003,-0.026,-0.01,-0.008,0.008,-0.007,-0.006,0.011,0.004,0.002,0,0.005,-0.008,0.005,-0,0.008,0.002,0,-0.003,-0.002,0.003,-0.005,-0.012,-0.005,0.001,0.002,-0.003,-0.001,-0.007,0.002,-0.002,0.002,-0.009,0.005,-0.003,0.003,-0.004,0,0.006,-0,-0.001,-0.003,0.002],[-0.008,0.006,-0.009,0.007,0.002,0.001,0.001,0.001,-0,0,-0,-0,0,-0,0,-0.001,0.003,-0.003,-0.002,-0.001,0.002,0,-0,0.001,0.002,0,-0,-0,0,-0,0.004,-0,0.001,-0,0.003,-0,0,-0,0.001,0.001,-0,0,-0,0,-0],[-0.001,0.004,0.002,0.012,0.006,0.001,-0.001,0.002,0,-0.001,-0,-0,0,-0,0,-0.003,0.002,-0.002,-0.002,-0.001,0.002,0.001,-0,0.001,0.002,0,-0,-0,0,-0,0.004,-0.001,0.002,-0,0.003,-0,0,-0,0.001,0.001,-0,0,-0,0,-0]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>nClusters<\/th>\n      <th>nWithinCluster<\/th>\n      <th>corRE<\/th>\n      <th>biasLGC_Int<\/th>\n      <th>biasMM_Int<\/th>\n      <th>biasLGC_Time<\/th>\n      <th>biasMM_Time<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":45,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4,5,6]}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,25,45,50,100]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


### Random effect variance

At the lowest sample/cluster sizes, LGC underestimates random effects variance at these settings, while REML overestimates. For the slope variance, LGC continues to struggle while REML shows no issues.  Interestingly, LGC continues to underestimate the variances at even the larger sample sizes with these 'clean' results.

<!--html_preserve--><div id="htmlwidget-4c0a7f1aa7837aa18c82" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-4c0a7f1aa7837aa18c82">{"x":{"filter":"none","data":[[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50],[5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25],[-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5],[-0.16,-0.143,-0.092,-0.129,-0.116,-0.117,-0.107,-0.159,-0.118,-0.087,-0.117,-0.114,-0.12,-0.118,-0.118,-0.087,-0.062,-0.087,-0.036,-0.084,-0.045,-0.058,-0.041,-0.032,-0.029,-0.057,-0.045,-0.057,-0.049,-0.049,-0.036,-0.024,-0.034,-0.043,-0.028,-0.011,-0.033,-0.027,-0.025,-0.037,-0.03,-0.019,-0.035,-0.028,-0.026],[0.09,0.073,0.106,0.121,0.184,0.037,0.045,0.006,0.033,0.094,0.006,0.008,0.002,0.001,0.002,-0.021,0.008,-0.013,0.048,0.027,0.01,-0.004,0.015,0.024,0.026,-0.011,0.001,-0.011,-0.003,-0.002,-0.007,0.01,-0.004,-0.009,0.016,0.016,-0.006,-0,0.002,-0.01,-0.007,0.004,-0.012,-0.005,-0.003],[-0.109,-0.138,-0.117,-0.124,-0.119,-0.1,-0.104,-0.096,-0.097,-0.1,-0.101,-0.1,-0.099,-0.101,-0.1,-0.049,-0.05,-0.048,-0.059,-0.034,-0.039,-0.041,-0.039,-0.044,-0.048,-0.04,-0.041,-0.041,-0.039,-0.04,-0.015,-0.024,-0.021,-0.025,-0.017,-0.018,-0.018,-0.02,-0.019,-0.018,-0.02,-0.02,-0.02,-0.02,-0.02],[0.008,-0.002,0.01,0.015,0.014,0.001,-0.002,0.007,0.005,0.002,-0.002,-0,0.001,-0.001,0,-0.001,-0.002,-0.001,-0.008,0.023,0.002,0,0.001,-0.003,-0.007,-0,-0.001,-0.001,0.001,0,0.007,-0.001,0.002,-0.003,0.005,0.002,0.002,0,0.001,0.002,-0,-0,0,-0,0]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>nClusters<\/th>\n      <th>nWithinCluster<\/th>\n      <th>corRE<\/th>\n      <th>biasLGC_Int<\/th>\n      <th>biasMM_Int<\/th>\n      <th>biasLGC_Time<\/th>\n      <th>biasMM_Time<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":45,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4,5,6]}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,25,45,50,100]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


### Random effect correlation

REML struggles with the RE correlation in the case of fewest time points. LGC struggles when the number of clusters or time points is small.

<!--html_preserve--><div id="htmlwidget-676ce63bae77e03a818d" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-676ce63bae77e03a818d">{"x":{"filter":"none","data":[[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50],[5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25],[-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5],[0.03,0.158,0.166,0.236,0.291,-0.028,0.026,0.032,0.041,0.066,0.002,0.002,-0.001,0.019,0.023,0.001,0.038,0.055,0.079,0.083,-0.01,0.002,0.004,0.023,0.034,-0.005,0.003,0.001,-0.003,0.006,-0.002,0.01,0.023,0.039,0.032,-0.003,-0.004,0.005,0.003,0.004,0,0.002,-0,0.006,0.002],[0.018,0.069,0.064,0.029,-0.02,-0.006,0.016,0.004,0.017,-0.004,0.007,0.004,-0.002,0.014,0.014,0,0.025,0.031,0.034,-0,-0.008,0.002,0.001,0.017,0.027,-0.004,0.004,0,-0.004,0.004,-0.002,0.006,0.018,0.031,0.009,-0.002,-0.004,0.004,0.001,0.001,0.001,0.002,-0,0.005,0.001]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>nClusters<\/th>\n      <th>nWithinCluster<\/th>\n      <th>corRE<\/th>\n      <th>biasLGC_corRE<\/th>\n      <th>biasMM_corRE<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":45,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4]}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,25,45,50,100]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


## Interval width

As before, 95% confidence intervals were taken as the quantiles of the simulation estimates. 

### Fixed effects

Little difference here except at the smallest N settings.

<!--html_preserve--><div id="htmlwidget-4e7e61887b91c81eb422" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-4e7e61887b91c81eb422">{"x":{"filter":"none","data":[[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50],[5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25],[-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5],[1.087,1.146,1.022,1.119,1.2,0.899,0.815,0.879,0.804,0.817,0.578,0.536,0.53,0.58,0.572,0.62,0.675,0.714,0.594,0.667,0.497,0.458,0.45,0.495,0.48,0.286,0.332,0.301,0.333,0.3,0.444,0.423,0.466,0.451,0.437,0.345,0.331,0.322,0.345,0.332,0.21,0.215,0.224,0.212,0.217],[1.053,1.148,1.095,1.137,1.172,0.903,0.815,0.889,0.85,0.817,0.573,0.539,0.526,0.581,0.569,0.622,0.67,0.712,0.623,0.666,0.497,0.462,0.449,0.493,0.479,0.285,0.332,0.301,0.333,0.3,0.439,0.423,0.462,0.451,0.438,0.345,0.331,0.322,0.345,0.332,0.21,0.214,0.224,0.212,0.217],[0.456,0.462,0.465,0.436,0.471,0.161,0.153,0.169,0.15,0.155,0.042,0.037,0.039,0.04,0.038,0.269,0.251,0.289,0.261,0.262,0.09,0.087,0.086,0.09,0.084,0.02,0.023,0.021,0.024,0.02,0.195,0.17,0.184,0.174,0.174,0.063,0.065,0.06,0.067,0.061,0.016,0.016,0.016,0.015,0.015],[0.444,0.474,0.447,0.45,0.494,0.163,0.155,0.176,0.153,0.158,0.042,0.038,0.039,0.04,0.038,0.269,0.262,0.293,0.268,0.262,0.09,0.087,0.085,0.089,0.084,0.02,0.023,0.021,0.024,0.02,0.196,0.17,0.183,0.173,0.173,0.063,0.065,0.06,0.067,0.061,0.016,0.016,0.016,0.015,0.015],[-0.034,0.002,0.073,0.018,-0.029,0.005,0,0.01,0.046,0,-0.005,0.003,-0.004,0.001,-0.003,0.001,-0.005,-0.002,0.03,-0,-0.001,0.004,-0.001,-0.001,-0.001,-0,-0,-0,0,-0,-0.005,0,-0.003,-0,0.001,-0,-0,0,-0,0,-0,-0,-0,-0,0],[-0.013,0.012,-0.018,0.014,0.023,0.002,0.002,0.007,0.003,0.002,-0,0.001,0,0,-0,0,0.011,0.004,0.007,0.001,0,0,-0,-0,-0,-0,0,-0,0,0,0.001,-0,-0.001,-0.001,-0.001,-0,-0,0,-0,0,0,0,0,0,0]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>nClusters<\/th>\n      <th>nWithinCluster<\/th>\n      <th>corRE<\/th>\n      <th>widthGrowth_Int<\/th>\n      <th>widthMixed_Int<\/th>\n      <th>widthGrowth_Time<\/th>\n      <th>widthMixed_Time<\/th>\n      <th>mixedWidthMinusgrowthWidth_Int<\/th>\n      <th>mixedWidthMinusgrowthWidth_Time<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":45,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4,5,6,7,8]}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,25,45,50,100]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


### Random effect variance

We now see that the width seen in LGC were due to the problematic situations where some parameters were not even estimated.

<!--html_preserve--><div id="htmlwidget-69db8131ac5b2a06704e" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-69db8131ac5b2a06704e">{"x":{"filter":"none","data":[[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50],[5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25],[-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5],[2.167,2.081,2.218,2.356,2.104,1.654,1.771,1.739,1.66,1.722,1.135,1.121,1.145,1.02,1.055,1.59,1.729,1.582,1.459,1.385,1.055,1.032,1.084,1.065,1.083,0.66,0.627,0.636,0.639,0.64,1.229,1.08,0.989,1.144,1.15,0.767,0.72,0.724,0.777,0.701,0.458,0.475,0.455,0.488,0.446],[2.5,2.594,2.66,2.608,2.692,1.847,1.958,1.966,1.825,1.923,1.263,1.259,1.258,1.137,1.19,1.62,1.802,1.603,1.5,1.361,1.095,1.075,1.126,1.109,1.125,0.688,0.654,0.663,0.665,0.667,1.249,1.089,1.002,1.16,1.133,0.782,0.734,0.738,0.792,0.716,0.467,0.485,0.464,0.498,0.456],[0.922,0.893,0.933,0.928,0.91,0.279,0.32,0.303,0.27,0.294,0.077,0.07,0.075,0.08,0.078,0.528,0.548,0.525,0.554,0.52,0.183,0.185,0.177,0.174,0.17,0.043,0.048,0.045,0.042,0.046,0.348,0.37,0.379,0.357,0.37,0.133,0.123,0.127,0.124,0.125,0.029,0.031,0.032,0.031,0.031],[0.96,1.035,1.024,1.059,1.007,0.32,0.359,0.349,0.302,0.324,0.085,0.081,0.083,0.089,0.086,0.551,0.546,0.54,0.575,0.501,0.19,0.193,0.185,0.181,0.177,0.045,0.05,0.047,0.044,0.047,0.359,0.376,0.38,0.364,0.375,0.136,0.126,0.13,0.126,0.127,0.03,0.031,0.032,0.031,0.031],[0.333,0.513,0.442,0.252,0.588,0.192,0.186,0.227,0.165,0.201,0.127,0.139,0.113,0.117,0.135,0.03,0.073,0.021,0.041,-0.023,0.04,0.042,0.043,0.044,0.042,0.028,0.027,0.027,0.026,0.027,0.02,0.009,0.013,0.016,-0.016,0.016,0.014,0.014,0.015,0.016,0.009,0.01,0.009,0.01,0.01],[0.038,0.142,0.091,0.131,0.097,0.041,0.039,0.046,0.033,0.03,0.008,0.011,0.008,0.009,0.008,0.023,-0.002,0.016,0.021,-0.018,0.007,0.008,0.008,0.007,0.006,0.002,0.002,0.002,0.002,0.002,0.01,0.006,0.001,0.006,0.006,0.003,0.003,0.003,0.002,0.003,0.001,0.001,0.001,0.001,0.001]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>nClusters<\/th>\n      <th>nWithinCluster<\/th>\n      <th>corRE<\/th>\n      <th>widthGrowth_Int<\/th>\n      <th>widthMixed_Int<\/th>\n      <th>widthGrowth_Time<\/th>\n      <th>widthMixed_Time<\/th>\n      <th>mixedWidthMinusgrowthWidth_Int<\/th>\n      <th>mixedWidthMinusgrowthWidth_Time<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":45,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4,5,6,7,8]}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,25,45,50,100]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


### Random effect correlation

<!--html_preserve--><div id="htmlwidget-93f87a4fc0be87290f5f" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-93f87a4fc0be87290f5f">{"x":{"filter":"none","data":[[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50],[5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25,5,5,5,5,5,10,10,10,10,10,25,25,25,25,25],[-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5,-0.5,-0.25,0,0.25,0.5],[1.512,1.851,1.739,2.513,2.436,0.828,1.008,1.169,1.037,1.199,0.528,0.57,0.635,0.632,0.579,0.6,0.777,0.955,1.096,1.17,0.429,0.478,0.495,0.53,0.552,0.269,0.339,0.325,0.317,0.282,0.371,0.478,0.602,0.61,0.724,0.296,0.314,0.347,0.356,0.341,0.194,0.22,0.221,0.216,0.208],[1.358,1.8,1.563,1.393,1.152,0.806,0.959,1.092,0.97,0.928,0.523,0.562,0.633,0.628,0.563,0.601,0.73,0.907,0.846,0.83,0.424,0.472,0.494,0.524,0.542,0.269,0.338,0.323,0.316,0.282,0.368,0.469,0.595,0.597,0.639,0.295,0.313,0.345,0.353,0.338,0.194,0.22,0.221,0.216,0.207],[-0.153,-0.051,-0.176,-1.119,-1.284,-0.022,-0.049,-0.077,-0.067,-0.27,-0.005,-0.007,-0.002,-0.005,-0.016,0.001,-0.047,-0.047,-0.249,-0.339,-0.005,-0.006,-0.001,-0.006,-0.01,-0,-0.001,-0.002,-0.001,0,-0.003,-0.009,-0.007,-0.013,-0.086,-0.001,-0.001,-0.002,-0.002,-0.003,-0,-0,-0,0,-0.001]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>nClusters<\/th>\n      <th>nWithinCluster<\/th>\n      <th>corRE<\/th>\n      <th>widthGrowth<\/th>\n      <th>widthMixed<\/th>\n      <th>mixedWidthMinusgrowthWidth<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","pageLength":45,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4,5]}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,25,45,50,100]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


# Summary

Latent growth curve modeling and mixed models offer two ways to approach longitudinal data.  If set up properly, and with large amounts of data, they will result in identical estimates.  The purpose of this doc was to examine the failures at small sample sizes.  

I typically tell people who are considering SEM that they shouldn't unless they have several hundred observations, a fact that has been born out in numerous studies, but which is still somehow regularly lost on the applied researcher. Growth curve models are highly constrained SEM, and it would appear they *still* require a couple hundred observations even in the well-behaved data settings above before estimation issues are finally overcome. In very small N settings, and especially with few time points the LGC struggles quite noticeably, often failing outright.   Meanwhile, a mixed model with REML appears to have issues mostly only with the smallest cluster x time point settings. 

Despite the similarities of the two approaches, they *are* different models however.  Time technically is an estimated parameter in the LGC - though we typically fix the values, they can be freely estimated. This is because they are just 'loadings' in the factor analytic sense[^estimateTime]. Secondly, any other time-varying covariates added to the LGC are assumed to interact with time. Thus while the slopes would vary over individuals in the mixed model, they vary over time points in the LGC.  As mentioned though, with proper constraints, the LGC can mimic the mixed model.

However, there are still a few things against using LGC in my opinion. 

- LGC *requires* balanced data, and so one must estimate missing values as a default, or else risk losing a lot of data even with only minor missingness, and doing so can make postestimation procedures problematic depending on the imputation technique chosen. 
- LGC also requires four time points[^tp], but as the above demonstrates, success is not guaranteed with 5 time points even with 50 observations. 
- As we have seen, LGC is not very viable for small samples. On the other hand, one could run a repeated measures anova, a special case of the mixed model, on two time points and a handful of subjects without issue.
- Adding covariates to an LGC is tedious and causes the number of estimated parameters to balloon quickly relative to the mixed model.
- These days, growth mixture models, mediation, multiple outcomes etc. can potentially be done with mixed models with little extra effort beyond the standard mixed model
- Mixed models are not restricted to time-based clustering[^multilvelsem]
- There are better (in my opinion) approaches to nonlinear effects, regularization, and other complexities in the non-SEM setting

In general, LGC should probably be reserved for models with latent variables (beyond the intercept and slope factors) and indirect effects.  In such cases, the data requirements will be even more taxing.  If a mixed model approach is appropriate, it should probably be preferred, and more so with smaller sample size settings.

# Future

vs. Bayesian mixed




# Code

[link](https://github.com/mclark--/Miscellaneous-R-Code/tree/master/SC%20and%20TR/mixedModels/growthCurvevsMixedModel.R)

## lavaan optimization settings



```
$control
$control$eval.max
[1] 20000

$control$iter.max
[1] 10000

$control$trace
[1] 0

$control$step.min
[1] 1

$control$step.max
[1] 1

$control$abs.tol
[1] 2.220446e-15

$control$rel.tol
[1] 1e-10

$control$x.tol
[1] 1.5e-08

$control$xf.tol
[1] 2.2e-14
```


[^nlminb]: lavaan uses same 'control' terminology as nlminb, but nlme notes `msMaxEval`, and `msMaxIter` for `eval.max` and `iter.max` arguments respectively. Aside from the iteration defaults, the only other difference between lavaan and nlme is with abs.tol, which by default is not used with nlminb (i.e. it is set to zero). Beyond that both lavaan and nlme use the defaults. The following is a print of `growthfittedmodel@optim`. 

[^estimateTime]:  They are often estimated to capture nonlinear trends.

[^multilvelsem]: One can take the long form  'multilevel' approach within the SEM context.  Like with the LGC, unless you have a complicated model full of indirect effects and latent variables, the only reason to use the SEM software is that you like to spend a lot more time coding up the model.

[^tp]: Like other SEM it can be run with three with proper constraints.
