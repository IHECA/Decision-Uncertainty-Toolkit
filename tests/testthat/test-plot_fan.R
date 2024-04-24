test_that("fan plot is returned in the correct format", {
  expect_type(fan_plots, "list")
  # add test to expect names?
  # one plot per scenario
  expect_equal(length(fan_plots), length(psa_data))
})


test_that("error if Dt is not the same length as the number of time steps", {
  expect_error(plot_fan(psa_data, tmin = 0, tmax = tmax, Dt = c(rep(750, 199)), Dt_max = TRUE),
               "Dt must be the same length")
})
