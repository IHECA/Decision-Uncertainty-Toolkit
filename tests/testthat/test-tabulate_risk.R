test_that("risk table returns in correct format", {
  risk_table <- tabulate_risk(risk_measures, n_s = length(risk_measures))
  expect_equal(class(risk_table), c("matrix", "array"))
})
