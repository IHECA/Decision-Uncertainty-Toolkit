test_that("calculated summary stats are returned in the correct format", {
  expect_type(stats_peak_temporal, "list")
  expect_type(stats_peak_temporal_base, "list")
  # one risk measure per scenario
  expect_equal(length(stats_peak_temporal), length(psa_data))
  expect_equal(length(stats_peak_temporal_base), 6)
})

test_that("the first argument is not a data.frame or list of data.frames", {
  expect_error(
    sum_stats_temporal(c(1:10)),
    class = "data_type"
  )
})

test_that("summary stats are calculated correctly", {
  expect_equal(
    as.numeric(round(stats_peak_temporal$Intervention_1[2, 2:6], digits = 2)),
    c(813.00, 320.62, 436.46, 462.35, 576.80)
  )
  expect_equal(
    as.numeric(round(stats_peak_temporal_base[5, 2:6], digits = 2)),
    c(813.00, 247.77, 326.34, 338.76, 418.55)
  )
})
