test_that("probability values are returned in the correct format", {
  expect_type(peak_probs, "list")
  expect_type(peak_probs_base, "double")
  expect_type(min_probs, "list")
  expect_type(min_probs_base, "double")
  # one dataframe per scenario
  expect_equal(length(unlist(lapply(peak_probs, length))), length(psa_data))
  expect_equal(length(peak_probs_base), length(Dp))
  expect_equal(length(unlist(lapply(min_probs, length))), length(psa_data))
  expect_equal(length(min_probs_base), length(Dp))
})

test_that("the first argument is not a data.frame or list of data.frames", {
  expect_error(
    calculate_threshold_probs(c(1:10), Dp = Dp, Dt_max = TRUE),
    class = "data_type"
  )
  expect_error(
    calculate_threshold_probs(c(1:10), Dp = Dp, Dt_max = FALSE),
    class = "data_type"
  )
})

test_that("probability values are calculated correctly", {
  expect_equal(
    as.vector(round(peak_probs$Baseline, digits = 2)),
    c(0.95, 0.89, 0.59)
  )
  expect_equal(
    as.vector(round(peak_probs$Intervention_1, digits = 2)),
    c(0.49, 0.25, 0.00)
  )
})
