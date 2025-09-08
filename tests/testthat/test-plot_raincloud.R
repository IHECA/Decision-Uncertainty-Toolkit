test_that("raincloud plot is returned in the correct format", {
  expect_equal(class(plot_raincloud(peak_values_list, D = D)), c("gg", "ggplot"))
})

test_that("the first argument is not a list with at least two elements", {
  expect_error(
    plot_raincloud(c(1:10), D = D),
    class = "data_type"
  )
  expect_error(
    plot_raincloud(peak_values_list$Baseline, D = D),
    class = "data_type"
  )
})
