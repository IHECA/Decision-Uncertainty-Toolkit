test_that("fan plot is returned in the correct format", {
  expect_type(fan_plots, "list")
  expect_true(any(inherits(fan_plots$Baseline, c("ggplot", "gg"))))
  # one plot per scenario
  expect_equal(length(fan_plots), length(psa_data))
})

test_that("the first argument is not a data.frame or list of data.frames", {
  expect_error(
    plot_fan(c(1:10), tmin = tmin, tmax = tmax, Dt = Dt, Dt_max = TRUE),
    class = "data_type"
  )
})

test_that("error if Dt is not the same length as the number of time steps", {
  expect_error(
    plot_fan(psa_data, tmin = tmin, tmax = tmax, Dt = c(rep(750, 199)), Dt_max = TRUE),
    class = "Dt_length"
  )
})

test_that("error if the value of 'tmin' or 'tmax' cannot be found in the first
                 column of the data.frame.", {
  expect_error(
    plot_fan(psa_data, tmin = 0, tmax = tmax, Dt = Dt, Dt_max = TRUE),
    class = "tmin_max"
  )
  expect_error(
    plot_fan(psa_data,
      tmin = tmin, tmax = "2024-01-01", Dt = Dt,
      Dt_max = TRUE
    ),
    class = "tmin_max"
  )
})
