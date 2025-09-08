test_that("time calculations are returned in the correct format", {
  expect_type(time_outputs, "list")
  expect_equal(class(time_outputs_int1), c("data.frame"))
  # one plot per scenario
  expect_equal(length(time_outputs), length(psa_data))
  expect_equal(length(time_outputs_int1), 9)
})

test_that("time outputs calculated correctly from sample data", {
  expect_equal(
    round(as.numeric(time_outputs_int1[1:7]), digits = 2),
    c(0.48, 23.97, 18.00, 33.00, 16.37, 3.00, 28.00)
  )
})

test_that("the first argument is not a data.frame or list of data.frames", {
  expect_error(
    calculate_time(c(1:10), tmin = tmin, tmax = tmax, Dt = Dt, Dt_max = TRUE),
    class = "data_type"
  )
})

test_that("the first column of the data.frame must be a Date or a numeric value", {
  psa_data$Intervention_1$date <- as.character(psa_data$Intervention_1$date)
  expect_error(
    calculate_time(psa_data$Intervention_1, tmin = tmin, tmax = tmax, Dt = Dt, Dt_max = TRUE),
    class = "date_type"
  )
})

test_that("error if Dt is not the same length as the number of time steps", {
  expect_error(
    calculate_time(psa_data, tmin = tmin, tmax = tmax, Dt = c(rep(750, 199)), Dt_max = TRUE),
    class = "Dt_length"
  )
  expect_error(
    calculate_time(psa_data$Baseline, tmin = tmin, tmax = tmax, Dt = c(rep(750, 199)), Dt_max = TRUE),
    class = "Dt_length"
  )
})

test_that("error if the value of 'tmin' or 'tmax' cannot be found in the first
                 column of the data.frame.", {
  expect_error(
    calculate_time(psa_data, tmin = 0, tmax = tmax, Dt = Dt, Dt_max = TRUE),
    class = "tmin_max"
  )
  expect_error(
    calculate_time(psa_data,
      tmin = tmin, tmax = "2024-01-01", Dt = Dt,
      Dt_max = TRUE
    ),
    class = "tmin_max"
  )
})
