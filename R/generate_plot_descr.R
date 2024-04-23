#' Generate standard description for all plots
#'
#' @param plot A plot
#' @param link A link to the bookdown
#'
#' @return A plot with the standard description caption added
gen_stand_descr <- function(plot, link = "link") {
  sd <- paste(
    "<br>Please refer to DUT book for a standard description
              that should be used when presenting this plot to decision makers:",
    link
  )
  plot <- plot + ggplot2::labs(caption = sd) +
    ggplot2::theme(plot.caption = ggtext::element_textbox_simple(size = 9, face = "italic"))
  return(plot)
}
