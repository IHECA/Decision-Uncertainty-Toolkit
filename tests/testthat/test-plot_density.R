test_that("density plot is returned in the correct format", {
  expect_type(density_plots, "list")
  expect_equal(class(density_plots$Baseline), c("gg", "ggplot"))
  # one plot per scenario
  expect_equal(length(density_plots), length(psa_data))
})

test_that("the first argument is not a data.frame or list of data.frames", {
  expect_error(
    plot_density(c(1:10), D = D, Dt_max = TRUE, risk_measures),
    class = "data_type"
  )
})
