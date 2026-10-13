# Capture the source location before the caller changes working directories.
.gm_script_file <- local({
  files <- lapply(sys.frames(), function(frame) frame$ofile)
  files <- Filter(function(value) is.character(value) && length(value) == 1L, files)
  if (length(files)) file.path(dirname(normalizePath(tail(files, 1L)[[1L]])), "download.py") else NULL
})

gm_download <- local({
  # Retain the script location inside the closure instead of the user's globals.
  default_script <- .gm_script_file
  function(url = NULL, output, tag = NULL, catalog = NULL, size = NULL,
           sha256 = NULL, python = Sys.getenv("GM_PYTHON"),
           script = Sys.getenv("GM_DOWNLOADER")) {
    # Preserve gm_download(url, output) and expose catalog and integrity parameters.
    args <- c("--output", output)
    if (!is.null(tag)) {
      if (!is.null(url) && nzchar(url)) stop("Use URL or tag, not both")
      if (is.null(catalog)) stop("catalog is required with tag")
      args <- c(args, "--tag", tag, "--catalog", catalog)
    } else {
      if (is.null(url) || length(url) != 1L || !nzchar(url)) stop("url is required")
      args <- c(args, "--url", url)
    }
    if (!is.null(size)) args <- c(args, "--size", format(size, scientific = FALSE, trim = TRUE))
    if (!is.null(sha256)) args <- c(args, "--sha256", sha256)
    if (length(output) != 1L || is.na(output) || !nzchar(output)) stop("output must be one path")
    if (!nzchar(script)) script <- default_script
    if (is.null(script) || !file.exists(script)) stop("Set script or GM_DOWNLOADER to download.py")
    if (!nzchar(python)) python <- if (.Platform$OS.type == "windows") "python" else "python3"

    # UTF-8 hex tokens preserve user arguments without shell expansion or splitting.
    hex <- function(value) paste(sprintf("%02x", as.integer(charToRaw(enc2utf8(value)))), collapse = "")
    bootstrap <- "import runpy,sys;runpy.run_path(bytes.fromhex(sys.argv.pop(1)).decode('utf-8'),run_name='__main__')"
    command_args <- c("-c", shQuote(bootstrap), hex(normalizePath(script)),
                      "--encoded-args", vapply(args, function(value) paste0("x", hex(value)), ""))
    # Return the path only when the shared downloader reports success.
    status <- system2(python, command_args)
    if (status != 0L) stop(sprintf("Download failed (exit %d)", status))
    invisible(output)
  }
})
rm(.gm_script_file)
