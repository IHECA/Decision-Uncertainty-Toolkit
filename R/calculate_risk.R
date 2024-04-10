#' Calculate risk measures
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
#' @param W Logical indicating whether the risk calculation should be weighted or not
#' @param weight Numeric vector containing weights for the risk calculation, one per time step
#' 
#' @return Numeric value or list of risk score(s)
#' 
#' @export
calculate_risk <- function(
    psa_data, 
    tmin, tmax, 
    Dt, Dt_max=TRUE, 
    W=FALSE, weight=NULL) {
  # check arguments up-front
  if(W & is.null(weight)) stop('Weighted calculation requested but weight vector was not provided.')

  if(length(Dt)!=length(tmin:tmax)){
    #Return error message if Dt is not the same length as tmin:tmax
    stop(paste("Dt must be the same length as the number of time periods (tmin:tmax)."))
  }else{
    if(inherits(psa_data,"list")){
      risk<-vector(mode="list",length = length(psa_data))
      names(risk)<-names(psa_data)
      N<-lapply(psa_data, function(x){length(x)-1})
      if(W==TRUE){
        if (setequal(lapply(weight, length),N)){
        }else{
          #Return error message if Dt is not the same length as tmin:tmax
          stop(paste("The weight vector must be the same length as 
                    the number of simulation runs."))
        }
      }else{
        weight<-lapply(N, function(x){rep(1,x)})
      }
      for (i in 1:length(psa_data)){
        risk[[i]]<-calculate_risk_1(psa_data[[i]], tmin, tmax, Dt, Dt_max, W, weight[[i]])
      }
    }else if(inherits(psa_data,"data.frame")){
      N<-(length(psa_data[1,])-1)
      if(W==TRUE){
        if (length(weight!=N)){
          #Return error message if weight vector is not the same length as tmin:tmax
          stop(paste("The weight vector must be the same length as the number of simulation runs."))
        }
      }else{
        weight<-rep(1,N)
      }
      risk<-calculate_risk_1(psa_data, tmin, tmax, Dt, Dt_max, W, weight)
    } else{
      stop(paste("The first argument is not a data.frame or list of data.frames"))
    }
    return(risk)
  }
}

#' Calculate risk measure for a single set of simulations
#' 
#' @inheritParams calculate_risk
#' 
#' @return Numeric value of risk score

calculate_risk_1 <- function(
    psa_data, 
    tmin, tmax, 
    Dt, Dt_max, 
    W, weight) {
  N<-(length(psa_data[1,])-1)
  expected_risk0<-0
  temp<-c()
  #sum over N psa runs
  for (i in 2:(N+1)){
    #sum over tmin to tmax for threshold that is a maximum
    if(Dt_max==TRUE){ 
      risk_n<-pmax(psa_data[(tmin+1):(tmax+1),i], Dt) - Dt
      #expected risk (total)
      expected_risk0<-expected_risk0+(sum(risk_n)*weight[i-1])
      #expected risk over time
      temp<-cbind(temp,risk_n*weight[i-1])
      #sum over tmin to tmax for threshold that is a minimum
    }else{
      risk_n<-Dt-pmin(psa_data[(tmin+1):(tmax+1),i], Dt)
      #expected risk (total)
      expected_risk0<-expected_risk0+(sum(risk_n)*weight[i-1])
      #expected risk over time
      temp<-cbind(temp,risk_n*weight[i-1])
    }
  }
  expected_risk<-expected_risk0/N
  exp_risk_time<-rowSums(temp)/length(temp[1,])
  return(sum(exp_risk_time))
}
