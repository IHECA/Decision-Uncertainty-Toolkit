#' Generate standard description for all plots
#'
#' @param plot A plot
#' @param link A link to the bookdown
#' @noRd
#' @return A plot with the standard description caption added
gen_stand_descr <- function(plot, link = "link") {
  sd <- paste0(
    "<br>Refer to the DUToolkit vignette '", link,"' for the recommended standard
    description to accompany this plot."
  )
  plot <- plot + ggplot2::labs(caption = sd) +
    ggplot2::theme(plot.caption = ggtext::element_textbox_simple(size = 9, face = "italic"))
  return(plot)
}
