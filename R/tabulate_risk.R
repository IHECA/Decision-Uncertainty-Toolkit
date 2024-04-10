#' Output risk measures to table
#' 
#' @param exp_risk_list List of risk values for each scenario, whether the first element is the risk for the baseline scenario
#' @param n_s Numeric value of the number of scenarios (including the baseline) to include in the table
#' 
#' @return A character matrix of risk values and policy risk impact (%) for each strategy
#' 
#' @export
tabulate_risk <- function(exp_risk_list, n_s){
  exp_risk_list<-unlist(exp_risk_list)
  if(length(exp_risk_list)!=n_s){
    stop(paste("The length of the expect risk values vector is different from the specified 
                number of scenarios (n_s). Did you forget to sum the expect risks values
                over time (i.e. sum(fun_calculate_risk())?"))
  }else{
    df<-rbind(Risk=round(exp_risk_list, digits=0), 
              c("-", calculate_rr(exp_risk_list)))
    col_names<-c()
    for(i in 2:length(exp_risk_list)){
      col_names[i-1]<-paste("Intervention", i-1)
    }
    colnames(df)<-c("Baseline",col_names)
    rownames(df)[2]<-"Policy risk impact"
    df[2,2:length(df[1,])]<-scales::percent(as.numeric(df[2,2:length(df[1,])]))
    return(df)
  }
}