
# netCoin <img src="man/figures/hexa_netCoin.png" align="right" alt="" width="200" />

<!-- badges: start -->

[![](http://cranlogs.r-pkg.org/badges/last-month/netCoin?color=green)](https://cran.r-project.org/package=netCoin)
[![](https://www.r-pkg.org/badges/version/netCoin?color=orange)](https://cran.r-project.org/package=netCoin)
[![](https://img.shields.io/badge/doi-10.18637/jss.v093.i11-yellow.svg)](https://doi.org/10.18637/jss.v093.i11)
[![](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
<!-- badges: end -->

This package integrates traditional statistical techniques with
automatic learning and social network analysis tools for the purpose of
obtaining visual and interactive displays of data.

# Installation

To install the last version of the package:

``` r
# Install development version
devtools::install_github("Modesto-Escobar/netCoin-1.0")
```

The stable version is available in CRAN:

``` r
# Install CRAN version
install.packages("netCoin")
```

# Usage

The most simple way to run the coincidence analysis from survey data is
to use the `surCoin()` function which produces a HTML with a dynamic
network:

``` r
data(ess)

plot(surCoin(data = ess, variables = c("Gender", "Social participation"))) # plot network object
```

<iframe width="850" height="850" src="articles/pkgdown/index/html/index1/index.html" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen>

</iframe>

# Citation

To cite this package `citation("netCoin")`:

Escobar M, Martinez-Uribe L (2020). “Network Coincidence Analysis: The
netCoin R Package.” Journal of Statistical Software, *93*(11), 1-32.
doi: 10.18637/jss.v093.i11 (URL:
<https://doi.org/10.18637/jss.v093.i11>)
