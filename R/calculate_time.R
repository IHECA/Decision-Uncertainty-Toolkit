#' Calculate time of threshold exceedance
#'
#' @param psa_data A data.frame (or a list of data.frames containing) where the first column contains the model time, and subsequent columns contain the predicted output for each simulation run at the respective time. See Data format section for more information.
#'
#' @section Data format:
#'
#' The model time in the first column must contain numeric values indicating a simulation time (ex. 0, 1, 2, 3,...) or dates (ex. 01/01/2024, 01/02/2024) which must be in `R` Date format (i.e., class="Date"). If comparing simulation results across multiple scenarios, provide a list of data.frames, where each data.frame gives the output for one scenario.
#'
#' @param tmin Numeric value giving the minimum simulation time
#' @param tmax Numeric value giving the maximum simulation time
#' @param Dt Numeric vector of decision thresholds at each time between `tmin` and `tmax``
#' @param Dt_max Logical indicating whether decision threshold is a maximum (`TRUE`) or minimum (`FALSE`)
#'
#' @return Dataframe or list of dataframe(s) of time and duration of first violation of the threshold
#' @export
calculate_time <- function(psa_data, tmin, tmax, Dt, Dt_max = TRUE) {
  if (inherits(psa_data, "list")) {
    stats <- lapply(psa_data, calculate_time_1, tmin, tmax, Dt, Dt_max)
  } else if (inherits(psa_data, "data.frame")) {
    stats <- calculate_time_1(psa_data, tmin, tmax, Dt, Dt_max)
  } else {
    stop(paste("The first argument is not a data.frame or list of data.frames"))
  }
  return(stats)
}

#' Calculate time of threshold exceedance a single set of simulations
#'
#' @inheritParams calculate_time
#'
#' @return Dataframe of time and duration of first violation of the threshold
calculate_time_1 <- function(psa_data, tmin, tmax, Dt, Dt_max = TRUE) {
  N <- (length(psa_data[1, ]) - 1)
  df <- data.frame()
  if (inherits(psa_data[, 1], "Date")) {
    sim_time <- c(0:length(psa_data[, 1]))
  } else if (inherits(psa_data[, 1], "numeric") || inherits(psa_data[, 1], "integer")) {
    sim_time <- psa_data[, 1]
  } else {
    stop(paste("The first column of the data.frame must be a Date or a numeric value."))
  }
  if (length(Dt) == length(tmin:tmax)) {
    # sum over N psa runs
    for (i in 2:(N + 1)) {
      if (Dt_max == TRUE) {
        # vector of index positions of values >threshold
        temp <- which(psa_data[, i] > Dt)
      } else {
        # vector of index positions of values <threshold
        temp <- which(psa_data[, i] < Dt)
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
  } else {
    # Return error message if Dt is not the same length as tmin:tmax
    stop(paste("Dt must be the same length as the number of time periods (tmin:tmax)."))
  }
  colnames(df) <- c("time_first", "duration_first")
  out <- c(percent_sims = sum(!is.na(df[, 1])) / length(df[, 1]))
  # out<-append(out,colMeans(df, na.rm = TRUE))
  out <- append(out, apply(df, 2, stats::median, na.rm = TRUE))
  out <- append(out, stats::quantile(df[, 1], c(0.025, 0.95), na.rm = TRUE), after = 2)
  out <- append(out, stats::quantile(df[, 2], c(0.025, 0.95), na.rm = TRUE))
  names_out <- c(names(out))
  out <- t(as.data.frame(out))
  colnames(out) <- names_out
  if (inherits(psa_data[, 1], "Date")) {
    first_date <- psa_data[, 1][round(out[2], digits = 0)]
    last_date <- psa_data[, 1][round(out[2] + out[5], digits = 0)]
    # names_out<-c(names_out,"date_first","date_last")
    out <- cbind.data.frame(out, date_first = first_date, date_last = last_date)
    # colnames(out)<-names_out
  }
  return(out)
}
