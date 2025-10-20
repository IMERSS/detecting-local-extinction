source(".Rprofile")

build_all <- function () {
    unlink("public", recursive=TRUE)
    blogdown::build_site(build_rmd = TRUE)
}

build_changed <- function () {
    blogdown::build_site(build_rmd = "timestamp")
}

build_all()
