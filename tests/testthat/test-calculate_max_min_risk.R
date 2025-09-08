test_that("risk values are returned in the correct format", {
  expect_type(peak_risk, "list")
  expect_type(peak_risk_base, "double")
  expect_type(min_risk, "list")
  expect_type(min_risk_base, "double")
  # one dataframe per scenario
  expect_equal(length(unlist(lapply(peak_risk, length))), length(psa_data))
  expect_equal(length(peak_risk_base), 1)
  expect_equal(length(unlist(lapply(min_risk, length))), length(psa_data))
  expect_equal(length(min_risk_base), 1)
})

test_that("the first argument is not a data.frame or list of data.frames", {
  expect_error(
    calculate_max_min_risk(c(1:10), D = D, Dt_max = TRUE),
    class = "data_type"
  )
  expect_error(
    calculate_max_min_risk(c(1:10), D = D, Dt_max = FALSE),
    class = "data_type"
  )
})

test_that("risk values are calculated correctly", {
  expect_equal(
    as.vector(round(unlist(peak_risk), digits = 2)),
    c(1500.79, 156.52)
  )
  expect_equal(
    as.vector(round(unlist(min_risk), digits = 2)),
    c(749.02, 750)
  )
})
