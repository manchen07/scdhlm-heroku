
<!-- README.md is generated from README.Rmd. Please edit that file -->

# scdhlm

<!-- badges: start -->

[![Build
Status](https://travis-ci.org/jepusto/scdhlm.svg?branch=master)](https://travis-ci.org/jepusto/scdhlm)
[![Coverage
Status](https://img.shields.io/codecov/c/github/jepusto/scdhlm/master.svg)](https://codecov.io/github/jepusto/scdhlm?branch=master)
[![](http://www.r-pkg.org/badges/version/scdhlm)](https://CRAN.R-project.org/package=scdhlm)
[![](http://cranlogs.r-pkg.org/badges/grand-total/scdhlm)](https://CRAN.R-project.org/package=scdhlm)
[![](http://cranlogs.r-pkg.org/badges/last-month/scdhlm)](https://CRAN.R-project.org/package=scdhlm)
<!-- badges: end -->

## Estimating Hierarchical Linear Models for Single-Case Designs

`scdhlm` provides a set of tools for estimating hierarchical linear
models and effect sizes based on data from single-case designs. The
estimated effect sizes, as described in Pustejovsky, Hedges, and Shadish
(2014), are comparable in principle to standardized mean differences
(SMDs) estimated from between-subjects randomized experiments. The
package includes functions for estimating design-comparable SMDs based
on data from ABAB designs (or more general treatment reversal designs)
and multiple baseline designs. Two estimation methods are available:
moment estimation (Hedges, Pustejovsky, & Shadish, 2012; 2013) and
restricted maximum likelihood estimation (Pustejovsky, Hedges, &
Shadish, 2014). The package also includes an interactive web interface
implemented using Shiny.

## Installation

You can install the released version of `scdhlm` from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("scdhlm")
```

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("jepusto/scdhlm")
```

You can access a local version of the [interactive
web-app](https://jepusto.shinyapps.io/scdhlm/) by running the commands:

``` r
library(scdhlm)
shine_scd()
```

## Demonstration

Here we demonstrate how to use `scdhlm` to calculate design-comparable
SMDs based on data from different single-case designs. We will first
demonstrate the older, moment estimation methods, followed by the
restricted maximum likelihood estimation method.

### Estimating SMDs using `effect_size_ABk()`

Lambert, Cartledge, Heward, and Lo (2006) tested the effect of using
response cards (compared to single-student responding) during math
lessons in two fourth-grade classrooms. The investigators collected data
on rates of disruptive behavior for nine focal students, using an ABAB
design. This example is discussed in Hedges, Pustejovsky, and Shadish
(2012), who selected it because the design was close to balanced and
used a relatively large number of cases. Their calculations can be
replicated using the `effect_size_ABk()` function. To use this function,
the user must provide the names of five variables:

  - the outcome variable,
  - a variable indicating the treatment condition,
  - a variable listing the case on which the outcome was measured,
  - a variable indicating the phase of treatment (i.e., each replication
    of a baseline and treatment condition), and
  - a variable listing the session number.

In the `Lambert` dataset, these variables are called respectively
`outcome`, `treatment`, `case`, `phase`, and `time`. Given these inputs,
the design-comparable SMD is calculated as follows:

``` r
library(nlme)
library(scdhlm)
data(Lambert)

Lambert_ES <- effect_size_ABk(outcome = outcome, treatment = treatment, id = case, 
                              phase = phase, time = time, data= Lambert)

str(Lambert_ES)
#> List of 12
#>  $ M_a            : int [1:2, 1:2] 6 4 6 7
#>   ..- attr(*, "dimnames")=List of 2
#>   .. ..$ : chr [1:2] "SSR" "RC"
#>   .. ..$ : chr [1:2] "1" "2"
#>  $ M_dot          : int 23
#>  $ D_bar          : num -5.46
#>  $ S_sq           : num 4.67
#>  $ delta_hat_unadj: num -2.52
#>  $ phi            : num 0.225
#>  $ sigma_sq_w     : num 4.53
#>  $ rho            : num 0.0299
#>  $ theta          : num 0.145
#>  $ nu             : num 164
#>  $ delta_hat      : num -2.51
#>  $ V_delta_hat    : num 0.0405
#>  - attr(*, "class")= chr "g_HPS"
```

The function produces a list containing the estimated effect size
estimate, an estimate of its variance, and several pieces of auxiliary
information. The effect size estimate `delta_hat` is equal to -2.513;
its variance `V_delta_hat` is equal to 0.041. A standard error for
`delta_hat` can be calculated by taking the square root of
`V_delta_hat`: `sqrt(Lambert_ES$V_delta_hat)` = 0.201. The effect size
estimate is bias-corrected in a manner analogous to Hedges’ g correction
for SMDs from a between-subjects design. The degrees of freedom `nu` are
estimated based on a Satterthwaite-type approximation, which is equal to
164.5 in this example.

### Estimating SMDs using `effect_size_MB()`

Saddler, Behforooz, and Asaro (2008) used a multiple baseline design to
investigate the effect of an instructional technique on the writing of
fourth grade students. The investigators assessed the intervention’s
effect on measures of writing quality, sentence complexity, and use of
target constructions.

Design-comparable SMDs can be estimated based on these data using the
`effect_size_MB()` function. The following code calculates a
design-comparable SMD estimate for the measure of writing quality:

``` r
data(Saddler)

Saddler_quality <- subset(Saddler, measure=="writing quality")
quality_ES <- effect_size_MB(outcome, treatment, case, time, data= Saddler_quality)

str(quality_ES)
#> List of 12
#>  $ g_dotdot       : int 41
#>  $ K              : int 13
#>  $ D_bar          : num 2.1
#>  $ S_sq           : num 0.952
#>  $ delta_hat_unadj: num 2.15
#>  $ phi            : num 0.0997
#>  $ sigma_sq_w     : num 0.349
#>  $ rho            : num 0.633
#>  $ theta          : num 0.201
#>  $ nu             : num 8.92
#>  $ delta_hat      : num 1.96
#>  $ V_delta_hat    : num 0.335
#>  - attr(*, "class")= chr "g_HPS"
```

The effect size estimate \``delta_hat` is equal to 1.963, with sampling
variance of `V_delta_hat` equal to 0.335 and a standard error of 0.579.

### Estimating SMDs using `g_REML()`

Laski, Charlop, and Schreibman (1988) used a multiple baseline across
individuals to evaluate the effect of a training program for parents on
the speech production of their autistic children, as measured using a
partial interval recording procedure. The design included \(m = 8\)
children. One child was measured separately with each parent; following
Hedges, Pustejovsky, and Shadish (2013), only the measurements taken
with the mother are included in our analysis.

For this study, we will estimate a design-comparable SMD using
restricted maximum likelihood (REML) methods, as described by
Pustejovsky and colleagues (2014). This is a two-step process. The first
step is to estimate a hierarchical linear model for the data, treated
the measurements as nested within cases. We fit the model using
`nlme::lme()`

``` r
data(Laski)

# Pustejovsky, Hedges, & Shadish (2014)
Laski_RML <- lme(fixed = outcome ~ treatment,
                 random = ~ 1 | case, 
                 correlation = corAR1(0, ~ time | case), 
                 data = Laski)
summary(Laski_RML)
#> Linear mixed-effects model fit by REML
#>  Data: Laski 
#>        AIC      BIC    logLik
#>   1048.285 1062.466 -519.1424
#> 
#> Random effects:
#>  Formula: ~1 | case
#>         (Intercept) Residual
#> StdDev:    15.68278  13.8842
#> 
#> Correlation Structure: AR(1)
#>  Formula: ~time | case 
#>  Parameter estimate(s):
#>      Phi 
#> 0.252769 
#> Fixed effects: outcome ~ treatment 
#>                       Value Std.Error  DF   t-value p-value
#> (Intercept)        39.07612  5.989138 119  6.524498       0
#> treatmenttreatment 30.68366  2.995972 119 10.241637       0
#>  Correlation: 
#>                    (Intr)
#> treatmenttreatment -0.272
#> 
#> Standardized Within-Group Residuals:
#>         Min          Q1         Med          Q3         Max 
#> -2.72642154 -0.69387388  0.01454473  0.69861200  2.14528141 
#> 
#> Number of Observations: 128
#> Number of Groups: 8
```

The summary of the fitted model displays estimates of the component
parameters, including the within-case and between-case standard
deviations, auto-correlation, and (unstandardized) treatment effect
estimate. These estimated components will be used to calculate the
effect size in next step.

The second step in the process is to estimate a design-comparable SMD
using `scdhlm::g_REML()`. The SMD parameter can be defined as the ratio
of a linear combination of the fitted model’s fixed effect parameters
over the square root of a linear combination of the model’s variance
components. `g_REML()` takes the fitted `lme` model object as input,
followed by the vectors `p_const` and `r_const`, which specify the
components of the fixed effects and variance estimates that are to be
used in constructing the design-comparable SMD. In this example, we use
the treatment effect in the numerator of the effect size and the sum of
the within-case and between-case variance components in the denominator
of the effect size. The constants are therefore given by `p_const =
c(0, 1)` and `r_const = c(1, 0, 1)`. The effect size estimated is
calculated as:

``` r
Laski_ES_RML <- g_REML(Laski_RML, p_const = c(0,1), r_const = c(1,0,1), returnModel=FALSE)

str(Laski_ES_RML)
#> List of 14
#>  $ p_beta   : num 30.7
#>  $ r_theta  : num 439
#>  $ delta_AB : num 1.46
#>  $ nu       : num [1, 1] 18.6
#>  $ kappa    : num [1, 1] 0.143
#>  $ g_AB     : num [1, 1] 1.4
#>  $ V_g_AB   : num [1, 1] 0.082
#>  $ cnvg_warn: logi FALSE
#>  $ sigma_sq : num 193
#>  $ phi      : num 0.253
#>  $ Tau      : Named num 246
#>   ..- attr(*, "names")= chr "case.var((Intercept))"
#>  $ I_E_inv  : num [1:3, 1:3] 798.92 1.32 -132.12 1.32 0.01 ...
#>  $ p_const  : num [1:2] 0 1
#>  $ r_const  : num [1:3] 1 0 1
#>  - attr(*, "class")= chr "g_REML"
```

The function returns a list containing the SMD effect size estimate
(`g_AB` = 1.405), its variance (`V_g_AB` = 0.082), the estimated
auto-correlation (`phi` = 0.253), estimated degrees of freedom (`nu` =
18.552), and several other pieces of auxiliary information.

## References

Hedges, L. V., Pustejovsky, J. E., & Shadish, W. R. (2012). A
standardized mean difference effect size for single case designs.
*Research Synthesis Methods, 3*(3), 224-239. doi:
[10.1002/jrsm.1052](http://doi.org/10.1002/jrsm.1052)

Hedges, L. V., Pustejovsky, J. E., & Shadish, W. R. (2013). A
standardized mean difference effect size for multiple baseline designs
across individuals. *Research Synthesis Methods, 4*(4), 324-341. doi:
[10.1002/jrsm.1086](http://doi.org/10.1002/jrsm.1086)

Lambert, M. C., Cartledge, G., Heward, W. L., & Lo, Y. (2006). Effects
of response cards on disruptive behavior and academic responding during
math lessons by fourth-grade urban students. *Journal of Positive
Behavior Interventions, 8*(2), 88-99. doi:
[10.1177/10983007060080020701](https://doi.org/10.1177/10983007060080020701)

Laski, K. E., Charlop, M. H., & Schreibman, L. (1988). Training parents
to use the natural language paradigm to increase their autistic
children’s speech. *Journal of Applied Behavior Analysis, 21*(4),
391–400. doi:
[10.1901/jaba.1988.21-391](https://doi.org/10.1901/jaba.1988.21-391)

Pustejovsky, J. E., Hedges, L. V., & Shadish, W. R. (2014).
Design-comparable effect sizes in multiple baseline designs: A general
modeling framework. *Journal of Educational and Behavioral Statistics,
39*(4), 211-227. doi:
[10.3102/1076998614547577](http://doi.org/10.3102/1076998614547577)

Saddler, B., Behforooz, B., & Asaro, K. (2008). The effects of
sentence-combining instruction on the writing of fourth-grade students
with writing difficulties. *The Journal of Special Education, 42*(2),
79–90. doi:
[10.1177/0022466907310371](http://doi.org/10.1177/0022466907310371)
