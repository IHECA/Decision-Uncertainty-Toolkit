# parameters
tmin <- "2021-01-01"
tmax <- "2021-04-10"
Dt <- rep(750, nrow(psa_data$Baseline))
Dp <- c(750, 1000, 2000) # define vector of threshold values
D <- 750
t_s <- 20
t_ss <- 10
Dt_max <- TRUE

risk_measures <- calculate_risk(
  psa_data,
  tmin = tmin,
  tmax = tmax,
  Dt = Dt,
  Dt_max = TRUE
)

risk_measure_int1 <- calculate_risk(
  psa_data$Intervention_1,
  tmin = tmin,
  tmax = tmax,
  Dt = Dt,
  Dt_max = TRUE
)

time_outputs <- calculate_time(
  psa_data,
  tmin = tmin,
  tmax = tmax,
  Dt = Dt,
  Dt_max = TRUE
)

time_outputs_int1 <- calculate_time(
  psa_data$Intervention_1,
  tmin = tmin,
  tmax = tmax,
  Dt = Dt,
  Dt_max = TRUE
)

fan_plots <- plot_fan(
  psa_data,
  tmin = tmin,
  tmax = tmax,
  Dt = Dt,
  Dt_max = TRUE
)

peak_values_list <- get_max_min_values(
  psa_data,
  tmin = tmin,
  tmax = tmax,
  Dt_max = TRUE
)

peak_values_list_base <- get_max_min_values(
  psa_data$Baseline,
  tmin = tmin,
  tmax = tmax,
  Dt_max = TRUE
)

min_values_list <- get_max_min_values(
  psa_data,
  tmin = tmin,
  tmax = tmax,
  Dt_max = FALSE
)

min_values_list_base <- get_max_min_values(
  psa_data$Baseline,
  tmin = tmin,
  tmax = tmax,
  Dt_max = FALSE
)

peak_probs <- calculate_threshold_probs(peak_values_list, Dp = Dp, Dt_max = TRUE)
peak_probs_base <- calculate_threshold_probs(peak_values_list$Baseline, Dp = Dp, Dt_max = TRUE)
min_probs <- calculate_threshold_probs(min_values_list, Dp = Dp, Dt_max = FALSE)
min_probs_base <- calculate_threshold_probs(min_values_list$Baseline, Dp = Dp, Dt_max = FALSE)

peak_risk <- calculate_max_min_risk(peak_values_list, D = D, Dt_max = TRUE)
peak_risk_base <- calculate_max_min_risk(peak_values_list$Baseline, D = D, Dt_max = TRUE)
min_risk <- calculate_max_min_risk(min_values_list, D = D, Dt_max = FALSE)
min_risk_base <- calculate_max_min_risk(min_values_list$Baseline, D = D, Dt_max = FALSE)

density_plots <- plot_density(
  peak_values_list,
  D = D,
  Dt_max = TRUE,
  risk_measures
)

peak_temporal_list <- get_relative_values(psa_data, peak_values_list, t_s = t_s, t_ss = t_ss)
peak_temporal_base <- get_relative_values(psa_data$Baseline, peak_values_list$Baseline,
  t_s = t_s, t_ss = t_ss
)

peak_temporal_plots <- plot_temporal(peak_temporal_list, D)

stats_peak_temporal <- sum_stats_temporal(peak_temporal_list)
stats_peak_temporal_base <- sum_stats_temporal(peak_temporal_list$Baseline)
