# Software Bibliographies

This function detects all the R packages used in a project folder and
automatically creates software bibliographies in PDF, Word, Rmarkdown
and BibTeX formats.

## Usage

``` r
softbib(
  output = c("softbib.pdf", "softbib.docx", "softbib.bib", "softbib.Rmd"),
  output_dir = getwd(),
  include = NULL,
  exclude = NULL,
  style = NULL
)
```

## Arguments

- output:

  vector of file paths or `NULL`. Acceptable file name extensions: .bib,
  .Rmd, .docx, .pdf. `NULL` returns a vector of BibTeX cite keys.

- output_dir:

  path of the directory where files should be saved.

- include:

  `NULL` or character vector.

  - `NULL`: the working directory is crawled to identify `R` packages
    used in the project, and all packages are included in the software
    bibliography.

  - Character vector: the names of packages to include in the
    bibliography.

- exclude:

  character vector of package names to exclude from the bibliography.

- style:

  Path to a Citation Style Language file (with `.csl` extension) '
  Zotero Repository: <https://www.zotero.org/styles>

## Value

Writes bibliography to file and returns a character vector of citation
keys.

## Examples

``` r
if (interactive()) {

# Save current path
oldpath <- getwd()

# Navigate to a project folder, crawl the working directory to get a list of `R`
# packages, and create bibliographies
library(softbib)
setwd("~/path/to/my/R/project/")
softbib()

# Exclude some packages from the bibliography
softbib(exclude = c("base", "dplyr"))

# Specify the list of packages to include manually
softbib(include = c("countrycode", "modelsummary", "marginaleffects"))

# Download a Citation Style Language file from the Zotero archive and print a
# bibliography in the style of the American Political Science Review
download.file(
  "https://www.zotero.org/styles/american-political-science-review",
  destfile = "apsr.csl")
softbib(style = "apsr.csl")

# Return to old path
setwd(oldpath)
} # end if(interactive()){}
```
