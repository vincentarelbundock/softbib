
#' Software Bibliographies
#'
#' This function detects all the R packages used in a project folder and
#' automatically creates software bibliographies in PDF, Word, Rmarkdown and
#' BibTeX formats.
#'
#' @param output vector of file paths or `NULL`. Acceptable file name extensions: .bib, .Rmd, .docx, .pdf. `NULL` returns a vector of BibTeX cite keys.
#' @param output_dir path of the directory where files should be saved.
#' @param include `NULL` or character vector.
#' + `NULL`: the working directory is crawled to identify `R` packages used in the project, and all packages are included in the software bibliography.
#' + Character vector: the names of packages to include in the bibliography.
#' @param exclude character vector of package names to exclude from the bibliography.
#' @param style Path to a Citation Style Language file (with `.csl` extension) '
#  which controls the reference style. The CSL file must be saved in the working
#  directory or one of its subdirectories. CSL files can be downloaded from the
#' Zotero Repository: https://www.zotero.org/styles
#' @examples
#' \dontrun{
#' # Navigate to a project folder, crawl the working directory to get a list of `R`
#' # packages, and create bibliographies
#' library(softbib)
#' setwd("~/path/to/my/R/project/")
#' softbib()
#' 
#' # Exclude some packages from the bibliography
#' softbib(exclude = c("base", "dplyr"))
#' 
#' # Specify the list of packages to include manually
#' softbib(include = c("countrycode", "modelsummary", "marginaleffects"))
#' 
#' # Download a Citation Style Language file from the Zotero archive and print a
#' # bibliography in the style of the American Political Science Review
#' download.file(
#'   "https://www.zotero.org/styles/american-political-science-review",
#'   destfile = "apsr.csl")
#' softbib(style = "apsr.csl")
#' }
#' @export
softbib <- function(
    output = c("softbib.pdf", "softbib.docx", "softbib.bib", "softbib.Rmd"),
    output_dir = getwd(),
    include = NULL,
    exclude = NULL,
    style = NULL) {

    # hard-coded values could eventually be set manually
    bibliography_name <- "softbib"
    project = getwd()

    # sanity checks
    checkmate::assert_character(exclude, null.ok = TRUE)
    checkmate::assert_character(include, null.ok = TRUE)
    checkmate::assert_directory_exists(output_dir)
    if (!is.null(style)) {
        checkmate::assert_file_exists(style, extension = "csl")
        style <- path.expand(style)
    }
    if (!is.null(include) && !is.null(exclude)) {
        stop("The `include` and `exclude` arguments cannot be used simultaneously.", call. = FALSE)
    }
    if (!is.null(output)) {
        extensions <- tools::file_ext(output)
        flag <- checkmate::check_true(all(extensions %in% c("pdf", "docx", "bib", "Rmd", "md")))
        if (!isTRUE(flag)) {
            stop('The `output` argument must be "a vector of file paths with the following extensions: ".pdf", ".docx", ".bib", ".Rmd", ".md"', call. = FALSE)
        }
        if (anyDuplicated(extensions)) {
            stop("The `output` argument cannot include multiple paths with the same extension.", call. = FALSE)
        }
    }
    

    # paths and unlink flags
    get_unlink <- function(ext) {
        regex <- paste0("\\.", ext, "$")
        out <- !any(grepl(regex, output))
        return(out)
    }

    get_path <- function(ext) {
        regex <- paste0("\\.", ext, "$")
        out <- output[grepl(regex, output)]
        if (!isTRUE(checkmate::check_path_for_output(out, overwrite = TRUE))) {
            rand <- sample(1:1e7, 1)
            out <- paste0("softbib_tmp_", rand, ".", ext)
        }
        return(out)
    }

    unlink_pdf <- get_unlink("pdf")
    unlink_bib <- get_unlink("bib")
    unlink_Rmd <- get_unlink("Rmd")
    unlink_docx <- get_unlink("docx")
    unlink_md <- get_unlink("md")


    fn_Rmd <- get_path("Rmd")
    fn_bib <- get_path("bib")
    fn_pdf <- get_path("pdf")
    fn_docx <- get_path("docx")
    fn_md <- get_path("md")

    # without bibtex, markdown file is useless
    if (isFALSE(unlink_Rmd) && isTRUE(unlink_bib)) {
        unlink_bib <- FALSE
        fn_bib <- gsub("Rmd$", "bib", fn_Rmd)
    }

    if (is.null(include)) {
        deps <- get_dependencies(project)
        deps <- c("base", deps) # cite R base unless in `exclude`
    } else {
        deps <- include
    }

    deps <- setdiff(deps, exclude)

    deps[deps == "R"] <- "base"

    deps <- unique(deps)

    void <- capture.output(
        missing <- suppressMessages(suppressWarnings(sapply(deps, requireNamespace, quietly = TRUE)))
    )
    if (any(!missing)) {
        missing <- names(missing)[!missing]
        msg <- sprintf("Missing package(s): %s.", paste(missing, collapse = ", "))
        stop(msg, call. = FALSE)
    }

    if (length(deps) == 0) {
        stop("Could not find an included `R` package.", call. = FALSE)
    }

    if (!isTRUE(checkmate::check_path_for_output(fn_bib))) {
        fn_bib <- paste0(tempfile(), ".bib")
    }

    write_bib(deps, fn_bib)

    keys <- get_keys(fn_bib)

    if (is.null(output)) {
        unlink(fn_bib)
        return(invisible(keys))
    }

    if (isTRUE(unlink_Rmd) && isTRUE(unlink_pdf) && isTRUE(unlink_docx) && isTRUE(unlink_md)) {
        return(invisible(keys))
    }

    write_rmarkdown(
        fn_bib,
        fn_Rmd,
        style = style,
        keys = keys)

    if (!isTRUE(unlink_pdf)) {
        rmarkdown::render(input = fn_Rmd, output_file = fn_pdf, output_dir = output_dir)
    }
    if (!isTRUE(unlink_docx)) {
        rmarkdown::render(input = fn_Rmd, output_file = fn_docx, output_dir = output_dir)
    }
    if (!isTRUE(unlink_md)) {
        rmarkdown::render(
            input = fn_Rmd,
            output_format = "md_document",
            output_file = fn_md,
            output_dir = output_dir)
    }
    
    if (isTRUE(unlink_bib)) unlink(fn_bib)
    if (isTRUE(unlink_Rmd)) unlink(fn_Rmd)

    return(invisible(keys))
}


get_keys <- function(path) {
    names(bibtex::read.bib(path))
}


write_bib <- function(pkgnames, path) {
    bibtex::write.bib(pkgnames, path)
    # make sure everything is UTF-8
    # https://stackoverflow.com/questions/7481799/convert-a-file-encoding-using-r-ansi-to-utf-8
    writeLines(
        iconv(readLines(path), from = "", to = "UTF8"), 
        file(path, encoding="UTF-8"))
}


get_dependencies <- function(path) {
    sort(unique(renv::dependencies(path = path, root = path)$Package))
}


write_rmarkdown <- function(fn_bib,
                            fn_Rmd,
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
        out <- sprintf(rmd_template, fn_bib, keys)
    } else {
        rmd_template <- paste(rmd_template, collapse = "\n")
        out <- sprintf(rmd_template, fn_bib, keys, style)
    }
    writeLines(
        out,
        file(fn_Rmd, encoding = "UTF-8"))
}