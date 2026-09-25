gm_download <- function(url, output) {
  stopifnot(length(url)==1, length(output)==1)
  status <- system2("python3", c("clients/download.py", "--url", url, "--output", output))
  if (status != 0) stop("download failed")
  invisible(output)
}
