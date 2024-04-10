#' Calculate relative risk
#' 
#' @param exp_risk_list Numeric vector of expected risk, where the first element corresponds to the baseline scenario
#' 
#' @return Numeric vector of relative risk values for each scenario except the baseline
calculate_rr <- function(exp_risk_list){
  exp_risk_list<-unlist(exp_risk_list)
  rr<-(exp_risk_list[2:length(exp_risk_list)]-exp_risk_list[1])/exp_risk_list[1]
  return(rr)
}