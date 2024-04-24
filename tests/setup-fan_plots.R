tmax <- nrow(psa_data$Intervention_1)-1
Dt <- rep(750, nrow(psa_data$Baseline))

fan_plots <- plot_fan(
  psa_data,
  tmin = 0,
  tmax = tmax,
  Dt = Dt,
  Dt_max = TRUE
)

time_outputs <- calculate_time(
  psa_data,
  tmin = 0,
  tmax = tmax,
  Dt = Dt,
  Dt_max = TRUE
)
