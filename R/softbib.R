get_keys <- function(path) {
    names(bibtex::read.bib(path))
}

write_bib <- function(pkgnames, path) {
    bibtex::write.bib(pkgnames, path)
}

get_dependencies <- function(path) {
    sort(unique(renv::dependencies(path = path)$Package))
}

write_rmarkdown <- function(fn_bibtex,
                            fn_rmarkdown,
                            style,
                            keys) {
    rmd_template <- c(
        "---",
        "bibliography: %s",
        "nocite: |",
        "  %s",
        "csl: %s",
        "---",
        "",
        "# Software Bibliography",
        "")
    keys <- paste(paste0("@", keys), collapse = ", ")
    if (is.null(style)) {
        rmd_template <- rmd_template[!grepl("^csl", rmd_template)]
        rmd_template <- paste(rmd_template, collapse = "\n")
        out <- sprintf(rmd_template, fn_bibtex, keys)
    } else {
        rmd_template <- paste(rmd_template, collapse = "\n")
        out <- sprintf(rmd_template, fn_bibtex, keys, style)
    }
    cat(out, file = fn_rmarkdown, append = FALSE)
}


#' Software Bibliographies
#'
#' This function detects all the R packages used in a project folder and
#' automatically creates software bibliographies in PDF, Word, Rmarkdown and
#' BibTeX formats.
#'
#' @param include `NULL` or character vector.
#' + `NULL`: the working directory is crawled to identify `R` packages used in the project, and all packages are included in the software bibliography.
#' + Character vector: the names of packages to include in the bibliography.
#' @param exclude character vector of package names to exclude from the bibliography.
#' @param style Path to a Citation Style Language file (with `.csl` extension) '
#  which controls the reference style. The CSL file must be saved in the working
#  directory or one of its subdirectories. CSL files can be downloaded from the
#' Zotero Repository: https://www.zotero.org/styles
#' @export
softbib <- function(
    include = NULL,
    exclude = NULL,
    style = NULL) {

    # hard-coded values could eventually be set manually
    bibliography_name <- "softbib"
    project = getwd()

    # sanity checks
    checkmate::assert_character(exclude, null.ok = TRUE)
    checkmate::assert_character(include, null.ok = TRUE)
    if (!is.null(style)) {
        checkmate::assert_file_exists(style, extension = "csl")
        style <- path.expand(style)
    }

    if (!is.null(include) && !is.null(exclude)) {
        stop("The `include` and `exclude` arguments cannot be used simultaneously.", call. = FALSE)
    }

    fn_rmarkdown <- file.path(project, paste0(bibliography_name, ".Rmd"))
    fn_pdf <- file.path(project, paste0(bibliography_name, ".pdf"))
    fn_word <- file.path(project, paste0(bibliography_name, ".docx"))
    fn_bibtex <- file.path(project, paste0(bibliography_name, ".bib"))

    if (is.null(include)) {
        deps <- get_dependencies(project)
        deps <- c("base", deps) # cite R base unless in `exclude`
    } else {
        deps <- include
    }

    deps <- setdiff(deps, exclude)

    if (length(deps) == 0) {
        stop("Could not find an included `R` package.", call. = FALSE)
    }

    write_bib(deps, fn_bibtex)

    keys <- get_keys(fn_bibtex)

    write_rmarkdown(
        fn_bibtex,
        fn_rmarkdown,
        style = style,
        keys = keys)

    rmarkdown::render(input = fn_rmarkdown, output_file = fn_pdf)
    rmarkdown::render(input = fn_rmarkdown, output_file = fn_word)
}

