#' Output risk measures to table
#'
#' @description This function tabulates the expected risk values for each
#' policy alternative and the percent change in risk relative to the baseline scenario.
#'
#' @param exp_risk_list A list of expected risk values
#' where the first element corresponds to the baseline policy.
#' This list can be generated using the [calculate_risk()] function.
#' @param n_s A numeric value of the number of policy alternatives (including
#' the baseline policy) to include in the table.
#'
#' @return A character matrix of risk values and policy risk impact (%)
#' for each policy alternative.
#'
#' @export
#'
#' @examples
#' tmin <- "2021-01-01"
#' tmax <- "2021-04-10"
#' Dt <- rep(750, nrow(psa_data$Baseline))
#'
#' risk_measures <- calculate_risk(
#'   psa_data,
#'   tmin = tmin,
#'   tmax = tmax,
#'   Dt = Dt,
#'   Dt_max = TRUE
#' )
#'
#' tabulate_risk(
#'   risk_measures,
#'   n_s = length(psa_data)
#' )
tabulate_risk <- function(exp_risk_list, n_s) {
  exp_risk_list <- unlist(exp_risk_list)
  if (length(exp_risk_list) != n_s) {
    rlang::abort("The length of the expect risk values vector is different from the specified
                number of scenarios (n_s). Did you forget to sum the expect risks values
                over time (i.e. sum(fun_calculate_risk())?", class = "exp_risk_length")
  } else {
    df <- rbind(
      Risk = round(exp_risk_list, digits = 2),
      c("-", calculate_rr(exp_risk_list))
    )
    col_names <- c()
    for (i in 2:length(exp_risk_list)) {
      col_names[i - 1] <- paste("Intervention", i - 1)
    }
    colnames(df) <- c("Baseline", col_names)
    rownames(df)[2] <- "Policy risk impact"
    df[2, 2:length(df[1, ])] <- scales::label_percent(accuracy = 0.01)(as.numeric(df[2, 2:length(df[1, ])]))
    return(df)
  }
}
