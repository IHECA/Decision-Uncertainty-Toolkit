test_that("calculated min/max values are returned in the correct format", {
  expect_type(peak_values_list, "list")
  expect_type(peak_values_list_base, "list")
  expect_type(min_values_list, "list")
  expect_type(min_values_list_base, "list")
  # one dataframe per scenario
  expect_equal(length(unlist(lapply(peak_values_list, length))), length(psa_data))
  expect_equal(length(peak_values_list_base), 3)
  expect_equal(length(unlist(lapply(min_values_list, length))), length(psa_data))
  expect_equal(length(min_values_list_base), 3)
})

test_that("the first argument is not a data.frame or list of data.frames", {
  expect_error(
    get_max_min_values(c(1:10), tmin = 0, tmax = tmax, Dt_max = TRUE),
    class = "data_type"
  )
  expect_error(
    get_max_min_values(c(1:10), tmin = 0, tmax = tmax, Dt_max = FALSE),
    class = "data_type"
  )
})

test_that("min and max values are calculated correctly from sample data", {
  expect_equal(
    round(head(peak_values_list$Baseline)[, 2], digits = 2),
    c(4207.44, 1681.52, 2539.18, 2969.72, 3073.74, 1520.14)
  )
  expect_equal(
    round(head(peak_values_list$Baseline)[, 3], digits = 0),
    as.Date(c(
      "2021-01-26", "2021-02-01", "2021-02-04", "2021-01-31", "2021-02-05",
      "2021-02-08"
    ))
  )
  expect_equal(
    round(head(min_values_list$Intervention_1)[, 2], digits = 2),
    c(rep(0, 6))
  )
  expect_equal(
    round(head(min_values_list$Intervention_1)[, 3], digits = 0),
    as.Date(c(rep("2021-01-01", 6)))
  )
})

test_that("error if the value of 'tmin' or 'tmax' cannot be found in the first
                 column of the data.frame.", {
  expect_error(
    get_max_min_values(psa_data, tmin = 0, tmax = tmax, Dt_max = TRUE),
    class = "tmin_max"
  )
  expect_error(
    get_max_min_values(psa_data, tmin = tmin, tmax = "2024-01-01", Dt_max = TRUE),
    class = "tmin_max"
  )
})
