tmax <- nrow(psa_data$Intervention_1)-1
Dt <- rep(750, nrow(psa_data$Baseline))

risk_measures <- calculate_risk(
    psa_data,
    tmin = 0,
    tmax = tmax,
    Dt = Dt,
    Dt_max = TRUE
)
