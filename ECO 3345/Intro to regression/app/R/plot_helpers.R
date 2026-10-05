# Shared by the student app and the instructor script.
# Axis limits stay fixed when the line moves and when the dataset changes.
read_activity_data <- function(data_dir) {
  lapply(seq_len(4), function(i) {
    d <- read.csv(file.path(data_dir, paste0("dataset_", i, ".csv")))
    stopifnot(identical(names(d), c("x", "y")), nrow(d) > 2,
              all(is.finite(d$x)), all(is.finite(d$y)))
    d
  })
}

line_equation <- function(intercept, slope, digits = 2) {
  # Avoid displaying a minus sign for a numerical slope that rounds to zero.
  if (round(slope, digits) == 0) slope <- 0
  paste0("\u0177 = ", formatC(intercept, format = "f", digits = digits),
         if (slope < 0) " \u2212 " else " + ",
         formatC(abs(slope), format = "f", digits = digits), "x")
}

draw_activity_plot <- function(data, intercept = NULL, slope = NULL,
                               title = "", line_label = NULL) {
  old_par <- par(mar = c(4.1, 4.2, 2.1, 1.1), mgp = c(2.5, 0.7, 0),
                 las = 1, family = "sans", col.axis = "#334155",
                 col.lab = "#182638", fg = "#CBD5E1", bg = "white")
  on.exit(par(old_par))
  plot(data$x, data$y, type = "n", xlim = c(0, 10), ylim = c(0, 35),
       xaxs = "i", yaxs = "i", xlab = "x", ylab = "y", main = title,
       axes = FALSE)
  abline(h = seq(0, 35, 5), v = seq(0, 10, 2), col = "#EDF1F5")
  axis(1, at = seq(0, 10, 2)); axis(2, at = seq(0, 35, 5))
  box()
  if (!is.null(intercept) && !is.null(slope)) {
    abline(a = intercept, b = slope, col = "#087F8C", lwd = 3)
  }
  points(data$x, data$y, pch = 21, bg = "#263B53", col = "white",
         cex = 1.25, lwd = 0.8)
  if (!is.null(line_label)) {
    legend("topright", legend = line_label, col = "#087F8C", lwd = 3,
           bty = "n", text.col = "#182638", cex = 0.95)
  }
  invisible(NULL)
}
