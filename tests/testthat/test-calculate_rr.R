test_that("relative risk is returned in the correct format", {
  rr <- calculate_rr(risk_measures)
  expect_type(rr, "double")
  # add test to expect names?
})

test_that("relative risk is calculated correctly from sample data", {
  expect_equal(round(calculate_rr(risk_measures), digits = 3),
  c(Intervention_1=-0.915, Intervention_2=-0.928, Intervention_3=-0.981))
})
