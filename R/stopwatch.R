
#' stopwatch
#' @export
stopwatch <- function() {

  context <- rstudioapi::getActiveDocumentContext()
  code <- context$selection[[1]]$text
  if (!nchar(code) > 0) {
    opt <- options(show.error.messages=FALSE)
    on.exit(options(opt))
    stop()
  }
  rstudioapi::sendToConsole(stringr::str_c("stopwatch::watch({\n", code, "\n})"), execute = TRUE)
  invisible()
}

#' watch
#' @export
watch <- function(expr, silent = FALSE, log = TRUE) {

  start <- lubridate::now()

  tic <- proc.time()
  expr
  toc <- proc.time()


  e <- as.list(toc - tic)

  call <- as.list(sys.call())[[2]]

  if (log)
    stopwatch.log(expr, start, e, call)

  if (!silent)
    stopwatch.print(e$elapsed)

  invisible()
}


stopwatch.log <- function(expr, start, e, call) {

  call <- paste(deparse(call), collapse = "")
  call <- stringr::str_sub(call, 2, stringr::str_length(call) - 1)
  call <- stringr::str_trim(call)
  call <- stringr::str_replace_all(call, "\\s\\s+", " ")
  call <- ifelse(stringr::str_length(call) > 50, stringr::str_c(strtrim(call, 47), "..."), call)

  if (!exists(".timings", where = .GlobalEnv)) {
    .timings <<- tibble::tibble()
    index <- 1
  } else {
    index <- max(.timings$index) + 1
  }

  run <- tibble::tibble(
      index = index,
      start = start,
      user = e$user.self,
      system = e$sys.self,
      elapsed = e$elapsed,
      call = call
    )

  .timings <<- dplyr::bind_rows(.timings, run)

}



stopwatch.print <- function(x) {

  # decide number of decimals
  if (x < 1) {
    x <- format(round(x, 3), nsmall = 3)
  } else if (x < 60) {
    x <- format(round(x, 1), nsmall = 1)
  } else {
    x <- round(x)
  }

  # pretty print
  cat(paste("Elapsed time: ", lubridate::seconds_to_period(x), "\n"))

  invisible()
}

