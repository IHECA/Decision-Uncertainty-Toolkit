test_that("time calculations are returned in the correct format", {
  expect_type(time_outputs, "list")
  # add test to expect names?
  # one plot per scenario
  expect_equal(length(time_outputs), length(psa_data))
})
