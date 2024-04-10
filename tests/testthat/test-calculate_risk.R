test_that("calculated risk is returned in the correct format", {
  expect_type(risk_measures, "list")
  # add test to expect names?
  # one risk measure per scenario
  expect_equal(sum(unlist(lapply(risk_measures, length))), length(psa_data))
})

# test_that("unweighted risk is calculated correctly from sample data", {
# })

# test_that("unweighted risk is calculated correctly from sample data", {
# })
