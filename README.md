
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mmetrics

[![Travis-CI Build
Status](https://api.travis-ci.com/shinichi-takayanagi/mmetrics.svg?branch=master)](https://travis-ci.com/shinichi-takayanagi/mmetrics)
[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/mmetrics)](https://cran.r-project.org/package=mmetrics)

## Installation

``` r
install.packages("mmetrics")

# Or the development version from GitHub:
# install.packages("devtools")
devtools::install_github("shinichi-takayanagi/mmetrics")
```

## Example

First, we create dummy data for this example.

``` r
library("mmetrics")
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

As a next step, we define metrics to evaluate using `rlang::quos`.

``` r
# Example metrics
metrics <- rlang::quos(
  cost = sum(cost),
  ctr  = sum(click)/sum(impression)
)
```

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

We can also use multiple grouping keys.

``` r
mmetrics::add(df, gender, age, metrics = metrics)
#> # A tibble: 10 x 4
#> # Groups:   gender [2]
#>    gender   age  cost    ctr
#>    <fct>  <dbl> <int>  <dbl>
#>  1 F         20    52 0.0294
#>  2 F         40    54 0.0865
#>  3 F         60    56 0.142 
#>  4 F         80    58 0.194 
#>  5 F        100    60 0.245 
#>  6 M         10    51 0     
#>  7 M         30    53 0.0583
#>  8 M         50    55 0.114 
#>  9 M         70    57 0.168 
#> 10 M         90    59 0.220
```

If we do not specify any grouping keys, `mmetrics::add()` behave like
`dplyr::mutate()` as a default option.

``` r
mmetrics::add(df, metrics = metrics)
#> # A tibble: 10 x 4
#> # Groups:   gender [2]
#>    gender   age  cost    ctr
#>    <fct>  <dbl> <int>  <dbl>
#>  1 F         20    52 0.0294
#>  2 F         40    54 0.0865
#>  3 F         60    56 0.142 
#>  4 F         80    58 0.194 
#>  5 F        100    60 0.245 
#>  6 M         10    51 0     
#>  7 M         30    53 0.0583
#>  8 M         50    55 0.114 
#>  9 M         70    57 0.168 
#> 10 M         90    59 0.220
```

If we want to summarize all data, change `summarize` argument to `TRUE`.

``` r
mmetrics::add(df, metrics = metrics, summarize=TRUE)
#> # A tibble: 1 x 2
#>    cost   ctr
#>   <int> <dbl>
#> 1   555 0.128
```
