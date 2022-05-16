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
        rmd_template <- rmd_template[!grepl("^csl", rmd_template)]
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
#' @param project Path to the R project folder. By default, `softbib` uses the current working directory.
#' @param output Character vector with file extensions of the desired output formats.
#' @param style Path to a Citation Style Language file (with `.csl` extension)
#'   which controls the reference style. CSL files can be downloaded from the
#'   Zotero Repository: https://www.zotero.org/styles
#' @param exclude character vector with BibTeX keys to exclude from the software bibliography.
#' @param include character vector with BibTeX keys to include in the software bibliography.
#' @export
softbib <- function(
    project = getwd(),
    output = c("bib", "pdf", "docx", "rmd"),
    style = NULL,
    exclude = NULL,
    include = NULL) {

    # hard-coded name will be saved in the project folder
    bibliography_name <- "softbib"

    # sanity checks
    checkmate::assert_directory_exists(project)
    checkmate::assert_character(output)
    checkmate::assert_true(all(output %in% c("bib", "pdf", "docx", "rmd")))
    checkmate::assert_character(exclude, null.ok = TRUE)
    checkmate::assert_character(include, null.ok = TRUE)

    if (!is.null(include) && !is.null(exclude)) {
        stop("The `include` and `exclude` arguments cannot be used simultaneously.")
    }

    flag <- checkmate::check_file_exists(style, extension = "csl")
    if (!is.null(style) && !isTRUE(flag)) {
        stop("The `style` argument must be `NULL` or be a valid path to a Citation Style Language file with a `.csl` extension. You can download CSL files to format citations in over 10000 styles from the Zotero Repository: https://www.zotero.org/styles")
    }

    fn_rmarkdown <- file.path(project, paste0(bibliography_name, ".Rmd"))
    fn_pdf <- file.path(project, paste0(bibliography_name, ".pdf"))
    fn_word <- file.path(project, paste0(bibliography_name, ".docx"))
    fn_bibtex <- file.path(project, paste0(bibliography_name, ".bib"))

    deps <- get_dependencies(project)
    deps <- c("base", deps) # cite R base unless in `exclude`

    write_bib(deps, fn_bibtex)

    keys <- get_keys(fn_bibtex)

    if (!is.null(exclude)) {
        keys <- setdiff(keys, exclude)
    }

    if (!is.null(include)) {
        if (any(!include %in% keys)) {
            stop(sprintf("Some of the BibTeX keys in the `include` argument are missing from the generated BibTeX file stored here: %s", fn_bibtex))
        }
    }

    write_rmarkdown(fn_bibtex,
                    fn_rmarkdown,
                    style = style,
                    keys = keys)

    if ("pdf" %in% output) {
        rmarkdown::render(input = fn_rmarkdown, output_file = fn_pdf)
    }
    if ("docx" %in% output) {
        rmarkdown::render(input = fn_rmarkdown, output_file = fn_word)
    }
    # cleanup
    if (!"rmd" %in% output) {
        unlink(fn_rmarkdown)
    }
    if (!"bib" %in% output) {
        unlink(fn_bibtex)
    }
}

