test_that("relative risk is returned in the correct format", {
  rr <- calculate_rr(risk_measures)
  expect_type(rr, "double")
})

test_that("relative risk is calculated correctly from sample data", {
  expect_equal(
    round(calculate_rr(risk_measures), digits = 3),
    c(Intervention_1 = -0.913)
  )
})

test_that("error if Dt is not the same length as the number of time steps", {
  expect_error(
    calculate_rr(risk_measure_int1),
    class = "risk_list_length"
  )
})
