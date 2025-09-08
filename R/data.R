#' Sample PSA data
#'
#' Sample simulation outputs for a baseline scenario and
#' three interventions, in a format compatible with package
#' functions
#'
#' @format ## `psa_data`
#' A list of data frames, one for each scenario corresponding
#' to the list item name (`Baseline`, `Intervention_1`). Each data frame has 100
#' rows and 814 columns:
#' \describe{
#' \item{date}{(`Baseline` only) the simulation date in calendar time}
#' \item{time}{(Intervention scenarios only) simulation time as integer
#' starting with 0}
#' \item{X1, ..., X1727}{individual simulation results}
#' }

"psa_data"
