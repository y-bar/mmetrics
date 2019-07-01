
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mmetrics <a href='https://shinichi-takayanagi.github.io/mmetrics/'><img src='man/figures/logo.png' align="right" height="139" /></a>

[![Travis-CI Build
Status](https://api.travis-ci.com/shinichi-takayanagi/mmetrics.svg?branch=master)](https://travis-ci.com/shinichi-takayanagi/mmetrics)
[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/mmetrics)](https://cran.r-project.org/package=mmetrics)
[![codecov](https://codecov.io/github/shinichi-takayanagi/mmetrics/branch/master/graphs/badge.svg)](https://codecov.io/github/shinichi-takayanagi/mmetrics)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

Easy Computation of Marketing Metrics with Different Analysis Axis.

## Installation

You can install the released version of {mmetrics} from CRAN with:

``` r
install.packages("mmetrics")
```

Or install the development version from github with:

``` r
# install.packages("remotes")
remotes::install_github("shinichi-takayanagi/mmetrics")
```

## Example

### Create Dummy data

First, we create dummy data for this example.

``` r
# Dummy data
df <- data.frame(
  gender = rep(c("M", "F"), 5),
  age = (1:10)*10,
  cost = c(51:60),
  impression = c(101:110),
  click = c(0:9)*3,
  conversion = c(0:9)
)

head(df)
#>   gender age cost impression click conversion
#> 1      M  10   51        101     0          0
#> 2      F  20   52        102     3          1
#> 3      M  30   53        103     6          2
#> 4      F  40   54        104     9          3
#> 5      M  50   55        105    12          4
#> 6      F  60   56        106    15          5
```

### Define metrics

As a next step, we define metrics to evaluate using `mmetrics::define`.

``` r
# Example metrics
metrics <- mmetrics::define(
  cost = sum(cost),
  ctr  = sum(click)/sum(impression)
)
```

### Just call `mmetrics::add()` \!

Call `mmetrics::add()` with grouping key (here `gender`) then we will
get new `data.frame` with defined metrics.

``` r
mmetrics::add(df, gender, metrics = metrics)
#> # A tibble: 2 x 3
#>   gender  cost   ctr
#>   <fct>  <int> <dbl>
#> 1 F        280 0.142
#> 2 M        275 0.114
```

### Remove aggregate function from metrics using `mmetrics::disaggregate()`

It is hassle for users to re-define metrics when you would like to use
these for `dplyr::mutate()`. In this case, you can use
`mmetrics::disaggregate()` to remove *the first aggregation function*
for the argument and return disaggregated metrics.

``` r
metrics_disaggregated <- mmetrics::disaggregate(metrics)
# Woo! sum() are removed!!!
print(metrics_disaggregated)
#> $cost
#> <quosure>
#> expr: ^cost
#> env:  000000001254E0D0
#> 
#> $ctr
#> <quosure>
#> expr: ^click / impression
#> env:  0000000012572568
```

You can use these metrics for `dplyr::mutate()`

``` r
dplyr::mutate(df, !!!metrics_disaggregated)
#>    gender age cost impression click conversion        ctr
#> 1       M  10   51        101     0          0 0.00000000
#> 2       F  20   52        102     3          1 0.02941176
#> 3       M  30   53        103     6          2 0.05825243
#> 4       F  40   54        104     9          3 0.08653846
#> 5       M  50   55        105    12          4 0.11428571
#> 6       F  60   56        106    15          5 0.14150943
#> 7       M  70   57        107    18          6 0.16822430
#> 8       F  80   58        108    21          7 0.19444444
#> 9       M  90   59        109    24          8 0.22018349
#> 10      F 100   60        110    27          9 0.24545455
```

…or, you can use `mmetrics::gmutate()` defind in our package.

``` r
mmetrics::gmutate(df, metrics = metrics_disaggregated)
#> # A tibble: 10 x 7
#>    gender   age  cost impression click conversion    ctr
#>    <fct>  <dbl> <int>      <int> <dbl>      <int>  <dbl>
#>  1 M         10    51        101     0          0 0     
#>  2 F         20    52        102     3          1 0.0294
#>  3 M         30    53        103     6          2 0.0583
#>  4 F         40    54        104     9          3 0.0865
#>  5 M         50    55        105    12          4 0.114 
#>  6 F         60    56        106    15          5 0.142 
#>  7 M         70    57        107    18          6 0.168 
#>  8 F         80    58        108    21          7 0.194 
#>  9 M         90    59        109    24          8 0.220 
#> 10 F        100    60        110    27          9 0.245
```

## More examples

  - As a first step, see the vignettes [Introduction to {mmetrics}
    package](https://shinichi-takayanagi.github.io/mmetrics/articles/introduction.html)
