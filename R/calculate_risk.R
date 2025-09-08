#' Calculate risk measures
#'
#' @description This function calculates the expected risk measure for each
#' policy alternative using the outputs from multiple model runs with different
#' input parameter sets (e.g., probabilistic sensitivity, uncertainty, or
#' Bayesian inference analysis).
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
#' @param W A logical value indicating whether the risk calculation should
#' be weighted (`TRUE`) or not (`FALSE`). The default is `FALSE` (an equal
#' weight of 1 is assumed for all simulation runs).
#' @param weight A list of numeric vectors of weights for the risk calculation,
#' with one weight corresponding to each time step. Required if `W` is `TRUE`.
#'
#' @return A list of risk scores, one for each policy alternative.
#' @export
#'
#' @examples
#' tmin <- "2021-01-01"
#' tmax <- "2021-04-10"
#' Dt <- rep(750, nrow(psa_data$Baseline))
#'
#' calculate_risk(
#'   psa_data,
#'   tmin = tmin,
#'   tmax = tmax,
#'   Dt = Dt,
#'   Dt_max = TRUE
#' )
calculate_risk <- function(
    data,
    tmin,
    tmax,
    Dt,
    Dt_max = TRUE,
    W = FALSE,
    weight = NULL) {
  # check arguments up-front
  if (W & is.null(weight)) {
    rlang::abort("Weighted calculation requested but weight vector was not provided.",
      class = "weight_vector"
    )
  }
  if (inherits(data, "list")) {
    risk <- vector(mode = "list", length = length(data))
    names(risk) <- names(data)
    N <- lapply(data, function(x) {
      length(x) - 1
    })
    if (W == TRUE) {
      if (setequal(lapply(weight, length), N)) {
      } else {
        rlang::abort("The weight vector must be the same length as the number of simulation runs.",
          class = "weight_vector"
        )
      }
    } else {
      weight <- lapply(N, function(x) {
        rep(1, x)
      })
    }
    for (i in 1:length(data)) {
      risk[[i]] <- calculate_risk_1(data[[i]], tmin, tmax, Dt, Dt_max, W, weight[[i]])
    }
  } else if (inherits(data, "data.frame")) {
    N <- (length(data[1, ]) - 1)
    if (W == TRUE) {
      if (length(weight != N)) {
        rlang::abort("The weight vector must be the same length as the number of simulation runs.",
          class = "weight_vector"
        )
      }
    } else {
      weight <- rep(1, N)
    }
    risk <- calculate_risk_1(data, tmin, tmax, Dt, Dt_max, W, weight)
  } else {
    rlang::abort("The first argument is not a data.frame or list of data.frames",
      class = "data_type"
    )
  }
  return(risk)
}

#' Calculate risk measure for a single set of simulations
#'
#' @inheritParams calculate_risk
#' @noRd
#' @return Numeric value of risk score
calculate_risk_1 <- function(
    data,
    tmin, tmax,
    Dt, Dt_max = TRUE,
    W, weight) {
  N <- (length(data[1, ]) - 1)
  expected_risk0 <- 0
  temp <- c()
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
  # sum over N psa runs
  for (i in 2:(N + 1)) {
    # sum over tmin to tmax for threshold that is a maximum
    if (Dt_max == TRUE) {
      # risk_n <- pmax(data[(tmin + 1):(tmax + 1), i], Dt) - Dt
      risk_n <- pmax(data[rind_tmin:rind_tmax, i], Dt) - Dt
      # expected risk (total)
      expected_risk0 <- expected_risk0 + (sum(risk_n) * weight[i - 1])
      # expected risk over time
      temp <- cbind(temp, risk_n * weight[i - 1])
      # sum over tmin to tmax for threshold that is a minimum
    } else {
      risk_n <- Dt - pmin(data[rind_tmin:rind_tmax, i], Dt)
      # risk_n <- Dt - pmin(data[(tmin + 1):(tmax + 1), i], Dt)
      # expected risk (total)
      expected_risk0 <- expected_risk0 + (sum(risk_n) * weight[i - 1])
      # expected risk over time
      temp <- cbind(temp, risk_n * weight[i - 1])
    }
  }
  expected_risk <- expected_risk0 / N
  exp_risk_time <- rowSums(temp) / length(temp[1, ])
  return(sum(exp_risk_time))
}
