#' Finds peak (or lowest) model output values
#'
#' @description For each policy alternative, this function finds the peak
#' (or lowest if the threshold is a minimum) model output values for
#' each simulation run.
#'
#' @param data A list of data.frames (one data.frame for each policy
#' alternative).
#'
#' @section data format:
#' Each data.frame in `data` contains the results from multiple model
#' runs using different parameter sets (e.g., from probabilistic sensitivity,
#' uncertainty, or Bayesian inference analysis). The first column contains
#' the model time and subsequent columns contain the predicted output for
#' each simulation run at the respective time.
#' The model time in the first column must contain numeric values indicating
#' a simulation time (ex. 1, 2, 3,...) or dates (ex. "2021-01-01", "2021-01-02")
#' which must be in `R` Date format (i.e., class="Date"). To ensure a consistent
#' basis for comparison, the model time in the first column should be the same for
#' each policy alternative (data.frame).
#'
#' @param tmin A numeric value or a date specifying the minimum simulation time
#' to include in the analysis (ex. 1 or "2021-01-01"). This should correspond to a value in the first
#' column of each data.frame in `data`.
#' @param tmax A numeric value or a date specifying the maximum simulation time to
#' include in the analysis (ex. 100 or "2021-04-10"). This should correspond to a value in the first
#' column of each data.frame in `data`.
#' @param Dt_max A logical value indicating whether the decision threshold
#' is a maximum (`TRUE`) or a minimum (`FALSE`). The default is `TRUE`.
#'
#' @return A list of data.frame(s) containing the peak (or lowest)
#' value and corresponding simulation time for each policy alternative.
#' @export
#'
#' @examples
#' tmin <- "2021-01-01"
#' tmax <- "2021-04-10"
#' Dt <- rep(750, nrow(psa_data$Baseline))
#'
#' peak_values_list <- get_max_min_values(
#'   psa_data,
#'   tmin = tmin,
#'   tmax = tmax,
#'   Dt_max = TRUE
#' )
get_max_min_values <- function(
    data,
    tmin, tmax,
    Dt_max = TRUE) {
  if (inherits(data, "list")) {
    values <- lapply(data, get_max_min_values_1, tmin, tmax, Dt_max)
  } else if (inherits(data, "data.frame")) {
    values <- get_max_min_values_1(data, tmin, tmax, Dt_max)
  } else {
    rlang::abort("The first argument is not a data.frame or list of data.frames",
      class = "data_type"
    )
  }
  return(values)
}


#' Finds peak (or lowest) model output values for a single set of simulations
#'
#' @inheritParams get_max_min_values
#' @noRd
#' @return Data.frame containing the peak (or lowest) value and corresponding
#' simulation time for each simulation run
get_max_min_values_1 <- function(
    data,
    tmin, tmax,
    Dt_max = TRUE) {
  if (!inherits(data[, 1], "Date") && !inherits(data[, 1], "numeric") &&
    !inherits(data[, 1], "integer")) {
    rlang::abort("The first column of the data.frame must be a Date or a numeric value.",
      class = "date_type"
    )
  }
  rind_tmin <- match(tmin, data[, 1])
  rind_tmax <- match(tmax, data[, 1])
  if (is.na(rind_tmin) || is.na(rind_tmax)) {
    # Return error message if tmin or tmax is not in the first column of 'data'
    rlang::abort("The value of 'tmin' or 'tmax' cannot be found in the first
                 column of the data.frame.",
      class = "tmin_max"
    )
  }
  N <- (length(data[1, ]) - 1)
  values <- data.frame(N = colnames(data)[1:N+1])
  df <- data[rind_tmin:rind_tmax, ]
  for (i in 2:(N + 1)) {
    # if threshold is a maximum find max values
    if (Dt_max == TRUE) {
      values[i - 1, "outcome"] <- max(df[, i])
      values[i - 1, "i_time"] <- df[which.max(df[, i]), 1]
      # if threshold is a minimum find min values
    } else {
      values[i - 1, "outcome"] <- min(df[, i])
      values[i - 1, "i_time"] <- df[which.min(df[, i]), 1]
    }
  }
  return(values)
}
