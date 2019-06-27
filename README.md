
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mmetrics

[![Travis-CI Build
Status](https://api.travis-ci.com/shinichi-takayanagi/mmetrics.svg?branch=master)](https://travis-ci.com/shinichi-takayanagi/mmetrics)
[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/mmetrics)](https://cran.r-project.org/package=mmetrics)
[![codecov](https://codecov.io/github/shinichi-takayanagi/mmetrics/branch/master/graphs/badge.svg)](https://codecov.io/github/shinichi-takayanagi/mmetrics)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

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

## More examples

  - As a first step, see the vignettes [Introduction to {mmetrics}
    package](https://shinichi-takayanagi.github.io/mmetrics/articles/introduction.html)
