#' Calculate relative risk
#'
#' @description This function calculates the expected relative risk for each
#' policy alternative relative to the baseline policy.
#'
#' @param exp_risk_list A list of expected risk values,
#' where the first element corresponds to the baseline policy.
#' This list can be generated using the [calculate_risk()] function.
#'
#' @noRd
#' @return A numeric vector of relative risk values for each policy alternative
#' except the baseline
calculate_rr <- function(exp_risk_list) {
  if (length(exp_risk_list) <= 1) {
    rlang::abort("The list of the expected risk values contains 1 or fewer elements. Relative risk values cannot be calculated.",
      class = "risk_list_length"
    )
  }
  exp_risk_list <- unlist(exp_risk_list)
  rr <- (exp_risk_list[2:length(exp_risk_list)] - exp_risk_list[1]) / exp_risk_list[1]
  return(rr)
}
