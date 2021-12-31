Sys.setenv(DOWNLOAD_STATIC_LIBV8=1)

install.packages("remotes")
install.packages("reticulate")

options(download.file.method = "wget")
remotes::install_github("facebookexperimental/Robyn/R")
library(Robyn)
library(reticulate)
Sys.setenv(RETICULATE_PYTHON = "/usr/bin/python3.8")

virtualenv_create("r-reticulate")
use_virtualenv("r-reticulate", required = TRUE)
py_install("nevergrad", pip = TRUE)
virtualenv_exists("r-reticulate")