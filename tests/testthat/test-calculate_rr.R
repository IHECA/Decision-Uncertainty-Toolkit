test_that("relative risk is returned in the correct format", {
  rr <- calculate_rr(risk_measures)
  expect_type(rr, "double")
  # add test to expect names?
})

# test_that("relative risk is calculated correctly from sample data", {
# })