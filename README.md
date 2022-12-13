
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

## Getting started

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
download.file(
  "https://www.zotero.org/styles/american-political-science-review",
  destfile = "apsr.csl")

softbib(style = "apsr.csl")
```

## Ignoring files and folders

`softbib` uses the `renv::dependencies()` function to detect `R`
packages used in a project folder. Like the `renv` package, `softbib`
can respect user instructions to ignore certain files and folders. To
specify those ignore instructions, you must place a file called
`.renvignore` in the working directory. This file can include lines such
as:

    ignorethiscript.R
    ignorethisfolder/ignorethisscript2.R
    ignorethisfolder/

## LaTeX document with two bibliographies

It is relatively easy to insert a separate software bibliography in a
LaTeX document by using the `multibib` package in a document preamble.

First, save this `R` script and execute it:

``` r
library(softbib)
library(countrycode)
softbib::softbib(output = "software.bib")
```

Then, save this LaTeX document in the same folder:

``` latex
\documentclass{article}

\usepackage{multibib}
\newcites{softbib}{Software Bibliography}

% for this example we insert a bibtex entry in the main latex file instead of an external .bib file
\usepackage{filecontents}
\begin{filecontents*}{scientific.bib}
@article{arel2017unintended,
  title={The unintended consequences of bilateralism: Treaty shopping and international tax policy},
  author={Arel-Bundock, Vincent},
  journal={International Organization},
  volume={71},
  number={2},
  pages={349--371},
  year={2017},
  publisher={Cambridge University Press}
}
\end{filecontents*}

\begin{document}

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus non ipsum nibh. Morbi in nibh feugiat, congue purus sed, accumsan nunc. Ut porttitor egestas purus ut eleifend. Praesent gravida mauris quis nibh faucibus facilisis. In quis sapien quis nisl accumsan malesuada in eget lectus. Sed tempor dapibus ligula malesuada volutpat \cite{arel2017unintended}. 

% bibliography
\bibliographystyle{plain}
\bibliography{scientific}

% software bibliography
\nocitesoftbib{*}
\bibliographystylesoftbib{plain}
\bibliographysoftbib{software}

\end{document}
```

Finally, run these commands:

``` bash
pdflatex article
bibtex article
bibtex softbib
pdflatex article
pdflatex article
```

The result should look like this:

![](https://user-images.githubusercontent.com/987057/207441851-ec863a78-430f-43e9-a825-803e4d494f02.png)
