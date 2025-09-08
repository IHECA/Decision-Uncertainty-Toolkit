test_that("risk table returns in correct format", {
  risk_table <- tabulate_risk(risk_measures, n_s = length(risk_measures))
  expect_equal(class(risk_table), c("matrix", "array"))
})

test_that("The length of the expect risk values vector is different from n_s", {
  expect_error(
    risk_table <- tabulate_risk(risk_measures, n_s = 3),
    class = "exp_risk_length"
  )
})
