
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `softbib`: Software Bibliographies for `R` Projects

This package detects all the `R` librairies used in a project and
automatically creates software bibliographies in PDF, Word, Rmarkdown,
and BibTeX formats. Bibliographies can be printed in thousands of
styles, using CSL files downloaded from the [Zotero style
repository.](https://www.zotero.org/styles)

## Installation

Install the development version of `softbib`:

``` r
library(remotes)
install_github("vincentarelbundock/softbib")
```

## Examples

Navigate to a project folder, crawl the working directory to get a list
of `R` packages, and create bibliographies:

``` r
library(softbib)

setwd("~/path/to/my/R/project/")

softbib()
```

Exclude some packages from the bibliography:

``` r
softbib(exclude = c("base", "dplyr"))
```

Specify the list of packages to include manually:

``` r
softbib(include = c("countrycode", "modelsummary", "marginaleffects"))
```

Download a Citation Style Language file from the Zotero archive and
print a bibliography in the style of the American Political Science
Review:

``` r
download.file("https://www.zotero.org/styles/american-political-science-review", destfile = "apsr.csl")

softbib(style = "apsr.csl")
```
