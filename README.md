
<!-- README.md is generated from README.Rmd. Please edit that file -->

<img src="man/figures/logo2.png" style="float: left; width: 170px; margin-right: 20px;" />
<h1>

DUToolkit
</h1>

<!-- badges: start -->

<!-- badges: end -->

The DUToolkit package provides a suite of tools and visualization for
the characterization, estimation, and communication of parameter
uncertainty and decision risk. The package is designed to evaluate the
impact of policy alternatives on outcomes compared to baseline (i.e.,
counterfactual analysis), leveraging model outputs from uncertainty
analysis. See [Wiggins et
al. (2025)](https://doi.org/10.1371/journal.pone.0332522) for a full
description of the underlying methods.

During public health crises such as the COVID-19 pandemic,
decision-makers relied on models to predict and estimate the impact of
various policy alternatives on health outcomes. Often, there is a high
degree of uncertainty in the evidence base underpinning these models.
When there is increased uncertainty, the risk of selecting a policy
option that does not align with the intended policy objective also
increases; we term this decision risk. Even when models adequately
capture uncertainty, the tools used to communicate their outcomes,
underlying uncertainty, and the associated decision risk are important
to mitigate decisions to adopt sub-optimal policies and/or critical
health technologies.

## Installation

You can install the ‘DUToolkit’ package from CRAN with the following
command in the console:

``` r
install.packages("DUToolkit")
```

## Usage

``` r
library(DUToolkit)

# calculate risk measures
tmin <- "2021-01-01"
tmax <- "2021-04-10"
Dt <- rep(750, nrow(psa_data$Baseline))

risk_measures <- calculate_risk(
  psa_data,
  tmin = tmin,
  tmax = tmax,
  Dt = Dt,
  Dt_max = TRUE
)

tabulate_risk(risk_measures, n_s = 2)
#>                    Baseline   Intervention 1
#> Risk               "23078.21" "2007.47"     
#> Policy risk impact "-"        "-91.30%"
```

``` r
# generate fan plots
fan_plots <- plot_fan(
  psa_data,
  tmin = tmin,
  tmax = tmax,
  Dt = Dt,
  Dt_max = TRUE
)

## example plot
fan_plots$Baseline
```

<img src="man/figures/README-fan-1.png" width="100%" />

``` r
## find peak values
peak_values_list <- get_max_min_values(
  psa_data,
  tmin = tmin,
  tmax = tmax,
  Dt_max = TRUE
)

head(peak_values_list$Baseline)
#>   N  outcome     i_time
#> 1 1 4207.443 2021-01-26
#> 2 2 1681.521 2021-02-01
#> 3 3 2539.177 2021-02-04
#> 4 4 2969.721 2021-01-31
#> 5 5 3073.741 2021-02-05
#> 6 6 1520.144 2021-02-08
```

``` r
# define single threshold value for the peak (D)
D <- 750
# generate density plots
density_plots <- plot_density(
  peak_values_list,
  D = D,
  Dt_max = TRUE,
  risk_measures
)

## example plot
density_plots$Intervention_1
```

<img src="man/figures/README-density-1.png" width="100%" />

``` r
# define vector of threshold values
Dp <- c(750, 1000, 2000)

# calculate probability that peak value is > specified threshold values
peak_probs <- calculate_threshold_probs(
  peak_values_list,
  Dp = Dp,
  Dt_max = TRUE
)

peak_probs$Baseline
#>    750   1000   2000 
#> 0.9494 0.8887 0.5895
```

``` r
# calculate risk measures at peak values
peak_risk <- calculate_max_min_risk(
  peak_values_list,
  D = D,
  Dt_max = TRUE
)

# generate risk table dataframe
tabulate_risk(peak_risk, n_s = 2)
#>                    Baseline  Intervention 1
#> Risk               "1500.79" "156.52"      
#> Policy risk impact "-"       "-89.57%"
```

``` r
# generate raincloud plot
plot_raincloud(
  peak_values_list,
  D = D
)
```

<img src="man/figures/README-rain-1.png" width="100%" />

``` r
# define time step variables
t_s <- 20 # the total number of timesteps from the peak
t_ss <- 10 # the timestep increments

# find values for temporal density plots
peak_temporal_list <- get_relative_values(
  psa_data,
  peak_values_list,
  t_s = t_s,
  t_ss = t_ss
)

head(peak_temporal_list$Baseline[[1]])
#>   time  outcome N
#> 1 peak 4207.443 1
#> 2 peak 1681.521 2
#> 3 peak 2539.177 3
#> 4 peak 2969.721 4
#> 5 peak 3073.741 5
#> 6 peak 1520.144 6
```

``` r
# generate peak temporal density plots
peak_temporal_plots <- plot_temporal(
  peak_temporal_list,
  D
)

## example plot
peak_temporal_plots$Intervention_1
```

<img src="man/figures/README-plot_temporal-1.png" width="100%" />

``` r
# generate summary statistics for peak temporal data
stats_peak_temporal <- sum_stats_temporal(peak_temporal_list)

stats_peak_temporal$Baseline
#>   time_step   n      q1  median    mean      q3
#> 1   peak-20 813   90.32  136.99  157.21  210.21
#> 2   peak-10 813  738.29 1013.14 1005.52 1260.49
#> 3      peak 813 1520.14 2300.14 2247.85 2982.81
#> 4   peak+10 813  884.80 1246.00 1211.20 1548.80
#> 5   peak+20 813  247.77  326.34  338.76  418.55
```

## Acknowledgments

We would like to thank everyone whom we engaged with including workshop
participants for their feedback on the Decision Uncertainty Toolkit.
