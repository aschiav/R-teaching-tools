# INTRO TO REGRESSION: instructor plots and best-fit lines
# Source this file in RStudio. It reads the exact CSVs used in the student app.
# Change these two settings, then source again if desired:

setwd("~/Library/CloudStorage/OneDrive-St.John'sUniversity/Documents/Teaching/Courses/ECO 3345 SJU/activities/intro to regression")
dataset_number <- 1
show_best_fit <- TRUE

# Locate this file whether run by source(), RStudio's Source, or Rscript.
.activity_dir <- local({
  source_files <- Filter(Negate(is.null), lapply(sys.frames(), function(f) f$ofile))
  if (length(source_files)) {
    dirname(normalizePath(tail(source_files, 1)[[1]], mustWork = TRUE))
  } else {
    script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
    if (length(script_arg)) {
      dirname(normalizePath(sub("^--file=", "", script_arg[1]), mustWork = TRUE))
    } else if (file.exists("instructor.R")) {
      normalizePath(".")
    } else {
      stop("Use Source on instructor.R, or set the working directory to its folder.")
    }
  }
})

source(file.path(.activity_dir, "app", "R", "plot_helpers.R"))
activity_data <- read_activity_data(file.path(.activity_dir, "app", "data"))

# Scatterplot only: plot_dataset(1), ..., plot_dataset(4)
# Reveal the line: reveal_fit(1), ..., reveal_fit(4)
plot_dataset <- function(dataset = 1, reveal = FALSE) {
  stopifnot(length(dataset) == 1, dataset %in% seq_along(activity_data))
  d <- activity_data[[as.integer(dataset)]]
  if (reveal) {
    fit <- lm(y ~ x, data = d)
    coefficients <- unname(coef(fit))
    draw_activity_plot(d, coefficients[1], coefficients[2],
                       title = paste("Dataset", dataset),
                       line_label = "Line of best fit")
    mtext(line_equation(coefficients[1], coefficients[2]),
          side = 3, adj = 0, line = 0.3, cex = 1.5, font = 2, col = "#087F8C")
    cat(sprintf("Dataset %d: intercept = %.4f; slope = %.4f\n",
                dataset, round(coefficients[1], 4) + 0, round(coefficients[2], 4) + 0))
    return(invisible(fit))
  }
  draw_activity_plot(d, title = paste("Dataset", dataset))
  invisible(d)
}

reveal_fit <- function(dataset = 1) plot_dataset(dataset, reveal = TRUE)

# The initial plot. Set show_best_fit = FALSE above to start with points only.
plot_dataset(dataset_number, reveal = show_best_fit)

# During class, run these lines one at a time in the console:
# plot_dataset(1)
# reveal_fit(1)
# plot_dataset(2)
# reveal_fit(2)
# plot_dataset(3)
# reveal_fit(3)

# Dataset 4: a symmetric V with zero covariance but a strong nonlinear relationship.
# plot_dataset(4)
# reveal_fit(4)
# cov(activity_data[[4]]$x, activity_data[[4]]$y)
