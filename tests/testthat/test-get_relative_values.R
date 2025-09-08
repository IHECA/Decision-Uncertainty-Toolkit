test_that("calculated relative values are returned in the correct format", {
  expect_type(peak_temporal_list, "list")
  expect_type(peak_temporal_base, "list")
  # one dataframe per scenario
  expect_equal(length(unlist(lapply(peak_temporal_list, length))), length(psa_data))
  expect_equal(length(peak_temporal_base), 2)
})

test_that("the first argument is not a data.frame or list of data.frames", {
  expect_error(
    get_relative_values(c(1:10), peak_values_list, t_s = t_s, t_ss = t_ss),
    class = "data_type"
  )
})

test_that("the data and max_min_values_list must be the same length", {
  expect_error(
    get_relative_values(psa_data, peak_values_list[1], t_s = t_s, t_ss = t_ss),
    class = "data_length"
  )
  expect_error(
    get_relative_values(psa_data[1], peak_values_list, t_s = t_s, t_ss = t_ss),
    class = "data_length"
  )
})

test_that("relative values are calculated correctly from sample data", {
  expect_equal(
    round(peak_temporal_list$Intervention_1[[1]][814:820, 2], digits = 2),
    c(1063.70, 475.56, 466.04, 788.05, 531.83, 263.85, 547.97)
  )
  expect_equal(
    round(head(peak_temporal_base[[1]])[, 2], digits = 2),
    c(4207.44, 1681.52, 2539.18, 2969.72, 3073.74, 1520.14)
  )
  expect_equal(
    peak_temporal_list$Intervention_1[[2]],
    c("peak-20", "peak-10", "peak", "peak+10", "peak+20")
  )
  expect_equal(
    peak_temporal_base[[2]],
    c("peak-20", "peak-10", "peak", "peak+10", "peak+20")
  )
})
