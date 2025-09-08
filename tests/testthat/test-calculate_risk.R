test_that("calculated risk is returned in the correct format", {
  expect_type(risk_measures, "list")
  expect_type(risk_measure_int1, "double")
  # one risk measure per scenario
  expect_equal(sum(unlist(lapply(risk_measures, length))), length(psa_data))
  expect_equal(length(risk_measure_int1), 1)
})

test_that("unweighted risk is calculated correctly from sample data", {
  expect_equal(
    round(unlist(
      calculate_risk(psa_data, tmin = tmin, tmax = tmax, Dt = Dt, Dt_max = TRUE)
    ), digits = 0),
    c(Baseline = 23078, Intervention_1 = 2007)
  )

  expect_equal(round(unlist(
    calculate_risk(psa_data$Intervention_1,
      tmin = tmin, tmax = tmax, Dt = Dt,
      Dt_max = TRUE
    )
  ), digits = 0), 2007)
})

test_that("the first argument is not a data.frame or list of data.frames", {
  expect_error(
    calculate_risk(c(1:10), tmin = tmin, tmax = tmax, Dt = Dt, Dt_max = TRUE),
    class = "data_type"
  )
})

test_that("error if Dt is not the same length as the number of time steps", {
  expect_error(
    calculate_risk(psa_data,
      tmin = tmin, tmax = tmax, Dt = c(rep(750, 199)),
      Dt_max = TRUE
    ),
    class = "Dt_length"
  )
})

test_that("error if the weight vector is not the same length as the number of simulations", {
  expect_error(
    calculate_risk(psa_data,
      tmin = tmin, tmax = tmax, Dt = Dt, Dt_max = TRUE,
      W = TRUE, weight = c(rep(1, length(psa_data$Baseline[1, ]) - 2))
    ),
    class = "weight_vector"
  )
  expect_error(
    calculate_risk(psa_data,
      tmin = tmin, tmax = tmax, Dt = Dt, Dt_max = TRUE,
      W = TRUE
    ),
    class = "weight_vector"
  )
  expect_error(
    calculate_risk(psa_data$Baseline,
      tmin = tmin, tmax = tmax, Dt = Dt, Dt_max = TRUE,
      W = TRUE, weight = c(rep(1, length(psa_data$Baseline[1, ]) - 2))
    ),
    class = "weight_vector"
  )
})

test_that("error if the value of 'tmin' or 'tmax' cannot be found in the first
                 column of the data.frame.", {
  expect_error(
    calculate_risk(psa_data, tmin = 0, tmax = tmax, Dt = Dt, Dt_max = TRUE),
    class = "tmin_max"
  )
  expect_error(
    calculate_risk(psa_data,
      tmin = tmin, tmax = "2024-01-01", Dt = Dt,
      Dt_max = TRUE
    ),
    class = "tmin_max"
  )
})
