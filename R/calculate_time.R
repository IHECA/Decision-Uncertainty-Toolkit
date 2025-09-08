#' Calculate time of threshold exceedance
#'
#' @description For each policy alternative, this function calculates:
#' (i) the percent of simulations in which the threshold is exceeded (or not
#' met if the threshold is a minimum), (ii) the mean simulation time of the
#' first exceedance and 95th percentile range, (iii) the mean duration of the
#' first exceedance and 95th percentile range, and (iv) if the first column of
#' model output data.frame passed to the function is a Date, the mean date of
#' the first and last exceedance.
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
#' @param Dt A numeric vector of decision thresholds, one for each model
#' time step between `tmin` and `tmax`.
#' @param Dt_max A logical value indicating whether the decision threshold
#' is a maximum (`TRUE`) or a minimum (`FALSE`). The default is `TRUE`.
#'
#' @return A list of data.frames, one for each policy alternative.
#' @export
#'
#' @examples
#' tmin <- "2021-01-01"
#' tmax <- "2021-04-10"
#' Dt <- rep(750, nrow(psa_data$Baseline))
#'
#' calculate_time(
#'   psa_data,
#'   tmin = tmin,
#'   tmax = tmax,
#'   Dt = Dt,
#'   Dt_max = TRUE
#' )
calculate_time <- function(data, tmin, tmax, Dt, Dt_max = TRUE) {
  if (inherits(data, "list")) {
    stats <- lapply(data, calculate_time_1, tmin, tmax, Dt, Dt_max)
  } else if (inherits(data, "data.frame")) {
    stats <- calculate_time_1(data, tmin, tmax, Dt, Dt_max)
  } else {
    rlang::abort("The first argument is not a data.frame or list of data.frames",
      class = "data_type"
    )
  }
  return(stats)
}

#' Calculate time of threshold exceedance a single set of simulations
#'
#' @inheritParams calculate_time
#' @noRd
#' @return Dataframe of time and duration of first violation of the threshold
calculate_time_1 <- function(data, tmin, tmax, Dt, Dt_max = TRUE) {
  if (!inherits(data[, 1], "Date") && !inherits(data[, 1], "numeric") &&
    !inherits(data[, 1], "integer")) {
    rlang::abort("The first column of the data.frame must be a Date or a numeric value.",
      class = "date_type"
    )
  }
  N <- (length(data[1, ]) - 1)
  df <- data.frame()
  rind_tmin <- match(tmin, data[, 1])
  rind_tmax <- match(tmax, data[, 1])
  if (is.na(rind_tmin) || is.na(rind_tmax)) {
    # Return error message if tmin or tmax is not in the first column of 'data'
    rlang::abort("The value of 'tmin' or 'tmax' cannot be found in the first
                 column of the data.frame.",
      class = "tmin_max"
    )
  } else if (length(Dt) != length(data[rind_tmin:rind_tmax, 1])) {
    # Return error message if Dt is not the same length as tmin:tmax
    rlang::abort("Dt must be the same length as the number of time periods
                 between 'tmin' and 'tmax'.",
      class = "Dt_length"
    )
  }

  sim_time <- c(1:length(data[rind_tmin:rind_tmax, 1]))
  # sum over N psa runs
  for (i in 2:(N + 1)) {
    if (Dt_max == TRUE) {
      # vector of index positions of values >threshold
      temp <- which(data[rind_tmin:rind_tmax, i] > Dt)
    } else {
      # vector of index positions of values <threshold
      temp <- which(data[rind_tmin:rind_tmax, i] < Dt)
    }
    if (all(is.na(temp))) {
      df <- rbind(df, c(first = NA, time = NA))
    } else {
      # simulation time of the first occurrence >/<threshold
      first <- sim_time[min(temp)]
      # check if the temp vector contents sequential values
      # return index of first non-sequential value
      check_seq <- which(diff(temp) != 1)
      # simulation time of end of first sequence of values >/<threshold
      last <- ifelse(length(check_seq) == 0, sim_time[max(temp)], sim_time[check_seq])
      # total simulation time >/<threshold (first occurrence)
      time <- last - first + 1
      df <- rbind(df, c(first, time))
    }
  }
  colnames(df) <- c("time_first", "duration_first")
  out <- c(percent_sims = sum(!is.na(df[, 1])) / length(df[, 1]))
  out <- append(out, colMeans(df, na.rm = TRUE))
  # out <- append(out, apply(df, 2, stats::median, na.rm = TRUE))
  out <- append(out, stats::quantile(df[, 1], c(0.025, 0.975), na.rm = TRUE), after = 2)
  out <- append(out, stats::quantile(df[, 2], c(0.025, 0.975), na.rm = TRUE))
  names_out <- c(names(out))
  out <- t(as.data.frame(out))
  colnames(out) <- names_out
  if (inherits(data[rind_tmin:rind_tmax, 1], "Date")) {
    first_date <- data[rind_tmin:rind_tmax, 1][round(out[2], digits = 0)]
    last_date <- data[rind_tmin:rind_tmax, 1][round(out[2] + out[5], digits = 0)]
    # names_out<-c(names_out,"date_first","date_last")
    out <- cbind.data.frame(out, date_first = first_date, date_last = last_date)
    # colnames(out)<-names_out
  }
  return(out)
}
