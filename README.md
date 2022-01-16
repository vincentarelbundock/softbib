
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `softbib`: Software Bibliographies for `R` Projects

This package detects all the `R` librairies used in a project and
automatically creates software bibliographies in PDF, Word, Rmarkdown,
and BibTeX formats.

## Installation

You can install the development version of softbib like so:

``` r
library(remotes)
install_github("vincentarelbundock/softbib")
```

## Example

From the terminal, we create a new project with a simple `R` script:

``` sh
mkdir new_project
cd new_project

echo 'library(countrycode)
library(stringr)
countrycode("Canada", "country.name", "iso3c")' > script.R
```

Launch `R`:

``` sh
R
```

Load `softbib` and read the documentation:

``` r
library(softbib)
?softbib
```

Scan the project folder and create software bibliographies:

``` r
softbib()
```
