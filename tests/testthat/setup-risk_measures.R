tmax <- nrow(psa_data$Intervention_1)-1

risk_measures <- calculate_risk(
    psa_data, 
    tmin = 0, 
    tmax = tmax, 
    Dt = rep(750, nrow(psa_data$Baseline)),
    Dt_max = TRUE
)