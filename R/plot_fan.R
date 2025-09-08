#' Generate time-outcome fan plots
#'
#' @description For each policy alternative, this function generates time-outcome
#' fan plots summarizing the trajectory of the outcome over time using the mean value for
#' a given policy alternative. Uncertainty is characterized by shading the
#' 50% and 95% credible intervals (calculated as 25th and 75th percentiles and
#' 2.5th and 97.5th percentiles, respectively). The decision threshold is shown
#' directly on the plot to provide a clear reference point for interpreting
#' the outcome values.
#'
#' @param data A list of data.frames (one data.frame for each policy
#' alternative).
#'
#' @section `data` format:
#' Each data.frame in `data` contains the results from multiple model
#' runs using different parameter sets (e.g., from probabilistic sensitivity,
#' uncertainty, or Bayesian inference analysis). The first column contains
#' the model time and subsequent columns contain the predicted output for
#' each simulation run at the respective time.
#' The model time in the first column must contain numeric values indicating
#' a simulation time (ex. 1, 2, 3,...) or dates (ex. "2021-01-01", "2021-01-02")
#' which must be in `R` Date format (i.e., class="Date"). To ensure a consistent
#' basis for comparison, the model time in the first column should be the same for
#' each policy alternative (data.frame).
#'
#' @param tmin A numeric value or a date specifying the minimum simulation time
#' to include in the analysis (ex. 1 or "2021-01-01"). This should correspond to a value in the first
#' column of each data.frame in `data`.
#' @param tmax A numeric value or a date specifying the maximum simulation time to
#' include in the analysis (ex. 100 or "2021-04-10"). This should correspond to a value in the first
#' column of each data.frame in `data`.
#' @param Dt A numeric vector of decision thresholds, one for each model
#' time step between `tmin` and `tmax`.
#' @param Dt_max A logical value indicating whether the decision threshold
#' is a maximum (`TRUE`) or a minimum (`FALSE`). The default is `TRUE`.
#'
#' @return A list of ggplots, one for each policy alternative.
#' @export
#'
#' @examples
#' tmin <- "2021-01-01"
#' tmax <- "2021-04-10"
#' Dt <- rep(750, nrow(psa_data$Baseline))
#'
#' fan_plots <- plot_fan(
#'   psa_data,
#'   tmin = tmin,
#'   tmax = tmax,
#'   Dt = Dt,
#'   Dt_max = TRUE
#' )
plot_fan <- function(data, tmin, tmax, Dt, Dt_max = TRUE) {
  if (inherits(data, "list")) {
    plot <- lapply(data, plot_fan_1, tmin, tmax, Dt, Dt_max)
    if (!is.null(names(plot)) && all(names(plot) != "")) {
      plot <- stats::setNames(
        lapply(names(plot), function(name) {
          plot[[name]] + ggplot2::ggtitle(name)
        }),
        names(plot)
      )
    } else {
      # Assign sequential names if unnamed
      plot_names <- paste0("Plot_", seq_along(plot))
      plot <- stats::setNames(
        lapply(seq_along(plot), function(i) {
          plot[[i]] + ggplot2::ggtitle(plot_names[i])
        }),
        plot_names
      )
    }
  } else if (inherits(data, "data.frame")) {
    plot <- plot_fan_1(data, tmin, tmax, Dt, Dt_max)
  } else {
    rlang::abort("The first argument is not a data.frame or list of data.frames",
      class = "data_type"
    )
  }
  return(plot)
}

#' Plot time-outcome fan plot for a single set of simulations
#'
#' @inheritParams plot_fan
#' @noRd
#' @return ggplot time-outcome fan plot
plot_fan_1 <- function(data, tmin, tmax, Dt, Dt_max = TRUE) {
  if (!inherits(data[, 1], "Date") && !inherits(data[, 1], "numeric") &&
    !inherits(data[, 1], "integer")) {
    rlang::abort("The first column of the data.frame must be a Date or a numeric value.",
      class = "date_type"
    )
  }
  rind_tmin <- match(tmin, data[, 1])
  rind_tmax <- match(tmax, data[, 1])
  if (is.na(rind_tmin) || is.na(rind_tmax)) {
    # Return error message if tmin or tmax is not in the first column of 'data'
    rlang::abort("The value of 'tmin' or 'tmax' cannot be found in the first
                 column of the data.frame.",
      class = "tmin_max"
    )
  } else if (length(Dt) != length(data[rind_tmin:rind_tmax, 1])) {
    # Return error message if Dt is not the same length as tmin:tmax
    rlang::abort("Dt must be the same length as the number of time periods
                 between 'tmin' and 'tmax'.",
      class = "Dt_length"
    )
  }
  time <- one <- two <- three <- four <- five <- NULL
  l <- length(data[1, ])
  percentiles_df <- data[rind_tmin:rind_tmax, 1]
  perc_df <- c()
  for (i in (rind_tmin:rind_tmax)) {
    q <- stats::quantile(
      as.numeric(data[i, 2:l]),
      c(0.025, 0.25, 0.5, 0.75, 0.975)
    )
    perc_df <- rbind(perc_df, q)
  }
  percentiles_df <- cbind.data.frame(percentiles_df, perc_df, Dt)
  colnames(percentiles_df) <- c("time", "one", "two", "three", "four", "five", "Dt")

  plot <- ggplot2::ggplot(
    as.data.frame(percentiles_df),
    ggplot2::aes(x = time, y = three, group = 1)
  ) +
    ggplot2::geom_ribbon(
      ggplot2::aes(
        ymin = one, ymax = five,
        fill = "95th %tile range"
      ),
      alpha = 0.5
    ) +
    ggplot2::geom_ribbon(
      ggplot2::aes(
        ymin = two, ymax = four,
        fill = "50th %tile range"
      ),
      alpha = 0.4
    ) +
    ggplot2::geom_line(ggplot2::aes(y = three, color = "Median"),
      linetype = "solid", linewidth = 1
    ) +
    ggplot2::geom_line(ggplot2::aes(y = Dt, color = "Policy target"),
      linetype = "dashed", linewidth = 0.75
    ) +
    ggplot2::ylab("Outcome") +
    ggplot2::xlab("Time") +
    ggplot2::theme_classic()

  # Add the manual scales
  plot <- plot +
    ggplot2::scale_color_manual(values = c(
      "Median" = "black",
      "Policy target" = "red"
    )) +
    ggplot2::scale_fill_manual(values = c(
      "95th %tile range" = "#9386A6FF",
      "50th %tile range" = "#6C568CFF"
    ))

  plot <- plot + ggplot2::guides(fill = ggplot2::guide_legend(
    override.aes =
      list(linetype = 0)
  ))

  plot <- plot + ggplot2::theme(
    legend.position = "bottom",
    legend.title = ggplot2::element_blank(),
    legend.text = ggplot2::element_text(size = 8)
  )

  # add caption
  time_outcomes_list <- calculate_time(data, tmin, tmax, Dt, Dt_max)
  time_output_captions <- caption_time(time_outcomes_list, Dt_max)

  plot <- plot + ggplot2::labs(subtitle = time_output_captions) +
    ggplot2::theme(plot.subtitle = ggtext::element_textbox_simple(size = 9))

  plot <- gen_stand_descr(plot, link="Time-outcome fan plots")

  return(plot)
}

#' Generate time caption for time-outcome fan plot
#'
#' @param time_outcomes Dataframe or list of dataframe(s) generated by calculate_time()
#' @param Dt_max Logical indicating whether decision threshold is a maximum (`TRUE`)
#' or minimum (`FALSE`)
#'
#' @return A character vector or list of character vector(s) of the time caption
#' @noRd
caption_time <- function(time_outcomes, Dt_max = TRUE) {
  if (inherits(time_outcomes, "list")) {
    stats <- lapply(time_outcomes, caption_time_1, Dt_max)
  } else {
    stats <- caption_time_1(time_outcomes, Dt_max)
  }
  return(stats)
}

#' Generate time caption for time-outcome fan plot for a single set of simulations
#'
#' @inheritParams caption_time
#'
#' @return A character vector of the time caption
#' @noRd
caption_time_1 <- function(time_outcomes, Dt_max = TRUE) {
  paste(
    "The threshold is", ifelse(Dt_max == TRUE, "exceeded", "not reached"),
    "in", scales::label_percent(accuracy = 1)(time_outcomes[1, 1]),
    "of all simulations. The first", ifelse(Dt_max == TRUE, "exceedance", "short fall"),
    "occurs at mean simulation time", round(time_outcomes[1, 2], digits = 0),
    "(95% CI", round(time_outcomes[1, 3], digits = 0), "-",
    round(time_outcomes[1, 4], digits = 0), ") and lasts for a mean of ",
    round(time_outcomes[1, 5], digits = 0), "(95% CI",
    round(time_outcomes[1, 6], digits = 0), "-",
    round(time_outcomes[1, 7], digits = 0), ") simulation time steps.<br>"
  )
}
