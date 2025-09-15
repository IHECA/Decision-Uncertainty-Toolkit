test_that("temporal plot is returned in the correct format", {
  expect_type(peak_temporal_plots, "list")
  expect_true(any(inherits(peak_temporal_plots$Baseline, c("ggplot", "gg"))))
  #expect_equal(class(peak_temporal_plots$Baseline), c("gg", "ggplot"))
  # one plot per scenario
  expect_equal(length(peak_temporal_plots), length(psa_data))
})

test_that("the first argument is not a data.frame or list of data.frames", {
  expect_error(
    plot_temporal(c(1:10), D),
    class = "data_type"
  )
})
