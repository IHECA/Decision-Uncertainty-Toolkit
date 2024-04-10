
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DecisionUncertaintyToolkit

<!-- badges: start -->
<!-- badges: end -->

During public health crises such as the COVID-19 pandemic,
decision-makers have relied on infectious disease models to predict and
estimate the impact of various health technologies. The challenges
associated with capturing and representing uncertainty using infectious
disease models can contribute to risks of making decisions misaligned to
policy objectives. Even when uncertainty is adequately captured in the
analysis, the tools for communicating the risks are important to
mitigate decisions to adopt sub-optimal policies and/or critical health
technologies such as vaccines and antivirals.

**The aim of the Decision Uncertainty Toolkit (DUT) is to extend best
practices from health economics to infectious disease modelling and
develop a suite of tools and visualization techniques to represent
parameter uncertainty and the risk these unknowns present to
decision-makers.**

The DUT is designed to evaluate the impact of policy alternatives on
outcomes compared to baseline (i.e., counterfactual analysis). It
leverages model outputs from uncertainty analysis for baseline and
policy alternatives to produce visual representations of uncertainty and
quantitative measures for assessing the associated risks.

This book provides open-source `R` code and explains how to use the code
to produce the DUT outputs using uncertainty analysis results from your
own model. It also includes standard text descriptions and examples of
each toolkit element.

## Installation

You can install the development version of DecisionUncertaintyToolkit
from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("papsti/DecisionUncertaintyToolkit")
```

## Get started

The DUT functions fall into several categories:

- ***Risk Measure:*** includes `calculate_risk()` and `tabulate_risk()`
  (see `vignettes("calculate-risk")`)

## Inputting simulation data

The DUT functions require input data (model outputs from the uncertainty
analysis) to be in a standardized format. Model outputs must be
structured as follows:

1.  *(Required)* A data.frame where the first column contains the model
    time, and subsequent columns contain the predicted output for each
    simulation run at the respective time.

    - The model time in the first column must contain numeric values
      indicating a simulation time (ex. 0, 1, 2, 3,…) or dates (ex.
      01/01/2024, 01/02/2024) which must be in `R` Date format (i.e.,
      class=“Date”).

    - If comparing multiple scenarios, the outputs for each scenario
      must be stored in separate data.frames.

2.  (*Optional)* A vector containing the weights assigned to each
    simulation run.

    - In an uncertainty analysis, different model runs may be more and
      less likely than others. There are various methods to account for
      this, such as calculating a log-likelihood for each simulation
      run. This information can be incorporated into the expected risk
      calculations by assigning a weight to each simulation run. For
      example, the log-likelihood for each simulation run could be
      convert into a weight. There are many ways to assign weights, and
      users must choose the most appropriate method for their specific
      scenario.

    - The weight vector must contain the same number of elements as the
      number of simulation run columns in the corresponding output
      data.frame as described above (i.e., all columns except for the
      first columns). The order of the weights in the vector must also
      follow the same order as the columns of the corresponding output
      data.frame.

    - If comparing multiple model scenarios, each scenario must have its
      own unique weight vector.

### Synthetic data

The `DecisionUncertaintyToolkit` package includes a synthetic simulation
dataset called `psa_data` that you can use to experiment with package
functions. Calling the package with
`library(DecisionUncertaintyToolkit)` will load the `psa_data` object
into your R session.

Imagine a decision maker is selecting between multiple policy
interventions related to COVID-19 in 2020. The model outputs are
timeseries of hospital occupancy under each of the following scenarios:

- Baseline: status quo, no intervention
- Intervention 1: close schools
- Intervention 2: institute a mandatory masking policy
- Intervention 3: close schools and institute a mandatory masking policy

Each intervention is expected to impact the number of individuals in the
hospital. Hospital capacity has a maximum upper bound, which we will use
as our decision threshold.

`psa_data` is a named list of data frames, with each data frame
containing synthetic model outputs for a given scenario:

``` r
class(psa_data)
#> [1] "list"
names(psa_data)
#> [1] "Baseline"       "Intervention_1" "Intervention_2" "Intervention_3"

psa_data$Baseline[1:5, 1:10]
#>         date       X1       X2       X3       X4       X5       X6       X7
#> 1 2024-01-01  0.00000  0.00000  0.00000  0.00000  0.00000  0.00000  0.00000
#> 2 2024-01-02 35.83232 37.23075 36.03765 36.89953 36.59754 36.13261 36.44546
#> 3 2024-01-03 30.64093 33.59007 31.03675 32.83302 32.20818 31.24644 31.87202
#> 4 2024-01-04 26.28367 30.84229 26.85785 29.66243 28.69752 27.20223 28.14384
#> 5 2024-01-05 22.64531 28.85823 23.38838 27.29372 25.96799 23.89016 25.15668
#>         X8       X9
#> 1  0.00000  0.00000
#> 2 36.62189 36.98825
#> 3 32.21741 32.96516
#> 4 28.65276 29.80027
#> 5 25.82604 27.39927

psa_data$Intervention_1[1:5, 1:10]
#>   time       X1       X2       X3       X4       X5       X6       X7       X8
#> 1    0  0.00000  0.00000  0.00000  0.00000  0.00000  0.00000  0.00000  0.00000
#> 2    1 35.83232 37.23075 36.03765 36.89953 36.59754 36.13261 36.44546 36.62189
#> 3    2 30.64093 33.59007 31.03675 32.83302 32.20818 31.24644 31.87202 32.21741
#> 4    3 26.28367 30.84229 26.85785 29.66243 28.69752 27.20223 28.14384 28.65276
#> 5    4 22.64531 28.85823 23.38838 27.29372 25.96799 23.89016 25.15668 25.82604
#>         X9
#> 1  0.00000
#> 2 36.98825
#> 3 32.96516
#> 4 29.80027
#> 5 27.39927
```

These data are used as examples throughout package vignettes.