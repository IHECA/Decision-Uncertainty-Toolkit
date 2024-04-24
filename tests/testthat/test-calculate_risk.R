test_that("calculated risk is returned in the correct format", {
  expect_type(risk_measures, "list")
  # add test to expect names?
  # one risk measure per scenario
  expect_equal(sum(unlist(lapply(risk_measures, length))), length(psa_data))
})

test_that("unweighted risk is calculated correctly from sample data", {
  expect_equal(round(unlist(
    calculate_risk(psa_data, tmin = 0, tmax = tmax, Dt = Dt, Dt_max = TRUE)
  ), digits = 0), c(Baseline=45513, Intervention_1=3862, Intervention_2=3267, Intervention_3=844))
})

test_that("error if Dt is not the same length as the number of time steps", {
  expect_error(calculate_risk(psa_data, tmin = 0, tmax = tmax, Dt = c(rep(750, 199)), Dt_max = TRUE),
               "Dt must be the same length")
})
