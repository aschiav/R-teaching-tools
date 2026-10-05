# Intro to regression

A simple classroom activity: students select a dataset, move a line, and share
their intercept and slope aloud. The student app shows a live prediction equation.
It does not calculate or reveal a best-fit line, score guesses, show residuals,
collect submissions, or save student information.

## Files

- `app/app.R`: student Shiny app; publish this **app folder** on shinyapps.io.
- `app/data/dataset_1.csv`: clear positive relationship, 30 observations.
- `app/data/dataset_2.csv`: noisier positive relationship, 30 observations.
- `app/data/dataset_3.csv`: negative relationship, 30 observations.
- `app/data/dataset_4.csv`: noisy symmetric V-shaped relationship, 33 observations.
- `app/R/plot_helpers.R`: shared data-reading and plotting functions.
- `instructor.R`: instructor-only plots and least-squares reveals.

The datasets are fixed, simulated x/y values. Both the app and instructor script
read the same CSVs; neither generates new data at runtime. All plots use x = 0–10
and y = 0–35 so the axes do not move as students adjust their line. The intercept
can range from −10 to 35 (steps of 0.1); slope from −4 to 4 (steps of 0.05).
Each dataset starts with intercept 12.5 and slope 0. Switching datasets resets
the line. Students can use the arrow keys on focused slider handles.

## Run and publish

The student app needs only the `shiny` package in addition to base R:

```r
install.packages("shiny") # only if needed
# With the working directory set to this activity folder:
shiny::runApp("app")
```

Publish the `app` subfolder using your usual shinyapps.io workflow. It contains
all required data and helpers. Keep `instructor.R` outside the published folder.
Embed the published app in Canvas as usual; no Canvas integration is included.

## Instructor reveal

Open `instructor.R` in RStudio and click **Source**. The default displays Dataset 1
with its best-fit line and prints the coefficients in the console. Set
`show_best_fit <- FALSE` near the top before sourcing to start with points only.
After sourcing once, run these commands individually during class:

```r
plot_dataset(1) # points only
reveal_fit(1)   # points + least-squares line; prints intercept and slope
plot_dataset(2)
reveal_fit(2)
plot_dataset(3)
reveal_fit(3)
plot_dataset(4)
reveal_fit(4)
```

The reveal function returns the fitted `lm` object invisibly, so you can also use
`fit <- reveal_fit(2)` and `coef(fit)`. The displayed equation rounds coefficients
to two decimal places; the plotted best-fit line uses the full-precision fit.
The instructor script uses only base R and locates the CSVs relative to itself.

The interface uses the standard Shiny [sliderInput](https://shiny.posit.co/r/reference/shiny/latest/sliderinput.html)
and [renderPlot](https://shiny.posit.co/r/reference/shiny/latest/renderplot.html) APIs.

## Dataset 4: nonlinear relationship, zero covariance

The fourth dataset follows `y = 4 + 6 * abs(x - 5) + noise`, with x from 1 to 9
in steps of 0.25. Noise has a generating standard deviation of 1.25 y units,
with the same noise assigned to each mirrored pair. Mirrored x values therefore
have identical y values, so their
contributions to covariance cancel exactly. Sample covariance and correlation
are zero, and the least-squares slope is zero up to floating-point precision.
The fitted line is horizontal at mean(y), approximately 16.17.

Teaching point: zero correlation does not mean no relationship. A straight-line
regression of y on x misses this V-shaped pattern. Regression can capture
nonlinear patterns if appropriate transformations or other terms are included;
for example, using abs(x - 5) as a predictor captures the V-shaped trend while leaving noise.

The current CSVs include additional fixed noise (seed 33450925): standard
deviations of 0.9, 0.6, and 0.9 y units added to the earlier versions of
Datasets 1–3, respectively. Dataset 4 uses the paired noise described above.
These values are saved once, so all students and instructor plots remain in sync.
