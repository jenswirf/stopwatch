

stopwatch <- function() {

  context <- rstudioapi::getActiveDocumentContext()
  code <- context$selection[[1]]$text
  if (!nchar(code) > 0) stop("No code selected.")
  rstudioapi::sendToConsole(stringr::str_c("watch({\n", code, "\n})"), execute = TRUE)

}


watch <- function(expr, silent = FALSE, log = TRUE) {

  # record start time
  start <- lubridate::now()

  # time expresssion
  tic <- proc.time()
  expr
  toc <- proc.time()

  # elapsed time
  e <- as.list(toc - tic)

  # log results in .timings
  if (log)
    #stopwatch.log(expr, start, e)

  # print pretty to console
  if (!silent)
    stopwatch.print(e$elapsed)

  e$elapsed

  invisible()
}


stopwatch.log <- function(expr, start, e) {

  run <- tibble(
    start = start,
    user = e$user.self,
    system = e$sys.self,
    elapsed = e$elapsed,
    call = expr
  )

  if(!exists(".timings", where = .GlobalEnv))
    .timings <<- data_frame()

  .timings <<- bind_rows(.timings, run)

}



stopwatch.print <- function(x) {

  # decide number of decimals
  if (x < 1) {
    x <- format(round(x, 3), nsmall = 3)
  } else if (s < 60) {
    x <- format(round(x, 1), nsmall = 1)
  } else {
    x <- round(x)
  }

  # pretty print
  cat(paste("Time: ", lubridate::seconds_to_period(x)))

  invisible()
}

