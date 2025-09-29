library(shiny)
library(ggplot2)

# ---- Utility helpers ----
num_deriv <- function(f, x, h = 1e-5) {
  sapply(x, function(xi) (f(xi + h) - f(xi - h)) / (2 * h))
}

safe_avg <- function(y, x) {
  out <- y / x
  out[!is.finite(out)] <- NA_real_
  out
}

# Predefined functions with parameters
make_fun <- function(name, params) {
  switch(
    name,
    "Power: a*x^b" = {
      a <- params$a; b <- params$b
      function(x) a * x^b
    },
    "Log: a*ln(x)" = {
      a <- params$a
      function(x) a * log(x)
    },
    "Exponential: a*exp(b*x)" = {
      a <- params$a; b <- params$b
      function(x) a * exp(b * x)
    },
    "Square root: a*sqrt(x)" = {
      a <- params$a
      function(x) a * sqrt(x)
    },
    "Polynomial: a*x^3 + b*x^2 + c*x + d" = {
      a <- params$a; b <- params$b; c <- params$c; d <- params$d
      function(x) a*x^3 + b*x^2 + c*x + d
    },
    "Linear: a*x + b" = {
      a <- params$a; b <- params$b
      function(x) a*x + b
    }
  )
}

ui <- fluidPage(
  titlePanel("Marginal and Average of a Function"),
  sidebarLayout(
    sidebarPanel(
      width = 4,
      selectInput(
        "fun_name", "Choose a function f(x):",
        choices = c(
          "Power: a*x^b",
          "Log: a*ln(x)",
          "Exponential: a*exp(b*x)",
          "Square root: a*sqrt(x)",
          "Polynomial: a*x^3 + b*x^2 + c*x + d",
          "Linear: a*x + b"
        ),
        selected = "Power: a*x^b"
      ),
      
      # Parameter controls
      conditionalPanel(
        condition = "input.fun_name == 'Power: a*x^b'",
        sliderInput("a_power", "a:", min = -5, max = 5, value = 1, step = 0.1),
        sliderInput("b_power", "b:", min = -3, max = 5, value = 0.5, step = 0.1)
      ),
      conditionalPanel(
        condition = "input.fun_name == 'Log: a*ln(x)'",
        sliderInput("a_log", "a:", min = -5, max = 5, value = 2, step = 0.1)
      ),
      conditionalPanel(
        condition = "input.fun_name == 'Exponential: a*exp(b*x)'",
        sliderInput("a_exp", "a:", min = -5, max = 5, value = 1, step = 0.1),
        sliderInput("b_exp", "b:", min = -2, max = 2, value = 0.2, step = 0.05)
      ),
      conditionalPanel(
        condition = "input.fun_name == 'Square root: a*sqrt(x)'",
        sliderInput("a_sqrt", "a:", min = -5, max = 5, value = 3, step = 0.1)
      ),
      conditionalPanel(
        condition = "input.fun_name == 'Polynomial: a*x^3 + b*x^2 + c*x + d'",
        sliderInput("a_poly", "a (x^3):", min = -2, max = 2, value = 0.1, step = 0.05),
        sliderInput("b_poly", "b (x^2):", min = -2, max = 2, value = -0.5, step = 0.05),
        sliderInput("c_poly", "c (x):",   min = -5, max = 5, value = 2, step = 0.1),
        sliderInput("d_poly", "d:",       min = -5, max = 5, value = 0, step = 0.1)
      ),
      conditionalPanel(
        condition = "input.fun_name == 'Linear: a*x + b'",
        sliderInput("a_lin", "a:", min = -5, max = 5, value = 1, step = 0.1),
        sliderInput("b_lin", "b:", min = -10, max = 10, value = 0, step = 0.5)
      ),
      
      tags$hr(),
      sliderInput("x0", "x:", min = 0, max = 15, value = 3, step = 0.1),
      sliderInput("xrange", "x-range (domain):", min = 0, max = 15, value = c(1, 15), step = 0.1),
      checkboxInput("show_tangent", "Show tangent line at x0", value = TRUE),
      checkboxInput("show_avgline", "Show average line from origin to (x0, f(x0))", value = TRUE),
      checkboxInput("show_points", "Mark f(x0), M(x0), A(x0)", value = TRUE)
    ),
    mainPanel(
      width = 8,
      plotOutput("plot_fx", height = 360),
      plotOutput("plot_ma", height = 360),
      uiOutput("values")
    )
  )
)

server <- function(input, output, session) {
  # Sync x0 slider with xrange
  observe({
    xmin <- input$xrange[1]
    xmax <- input$xrange[2]
    if (input$x0 < xmin || input$x0 > xmax) {
      updateSliderInput(session, "x0", min = xmin, max = xmax, value = min(max(input$x0, xmin), xmax))
    } else {
      updateSliderInput(session, "x0", min = xmin, max = xmax)
    }
  })
  
  params <- reactive({
    switch(
      input$fun_name,
      "Power: a*x^b" = list(a = input$a_power, b = input$b_power),
      "Log: a*ln(x)" = list(a = input$a_log),
      "Exponential: a*exp(b*x)" = list(a = input$a_exp, b = input$b_exp),
      "Square root: a*sqrt(x)" = list(a = input$a_sqrt),
      "Polynomial: a*x^3 + b*x^2 + c*x + d" = list(a = input$a_poly, b = input$b_poly, c = input$c_poly, d = input$d_poly),
      "Linear: a*x + b" = list(a = input$a_lin, b = input$b_lin)
    )
  })
  
  f <- reactive({ make_fun(input$fun_name, params()) })
  
  grid <- reactive({
    xmin <- input$xrange[1]
    xmax <- input$xrange[2]
    if (xmin >= xmax) xmax <- xmin + 1
    needs_pos <- input$fun_name %in% c("Log: a*ln(x)", "Square root: a*sqrt(x)")
    start <- if (needs_pos || xmin <= 0) max(1e-3, xmin) else xmin
    seq(start, xmax, length.out = 400)
  })
  
  df_all <- reactive({
    x <- grid(); fx <- f()(x)
    mx <- num_deriv(f(), x)
    ax <- safe_avg(fx, x)
    
    x0 <- min(max(input$x0, min(x)), max(x))
    f0 <- f()(x0)
    m0 <- num_deriv(f(), x0)
    a0 <- f0 / x0
    
    data.frame(x = x, fx = fx, mx = mx, ax = ax, x0 = x0, f0 = f0, m0 = m0, a0 = a0)
  })
  
  output$plot_fx <- renderPlot({
    d <- df_all()
    p <- ggplot(d, aes(x, fx)) +
      geom_line(linewidth = 1) +
      labs(title = "Function f(x) with Tangent and Average Line",
           y = "f(x)", x = "x") +
      theme_minimal(base_size = 13)
    
    if (input$show_tangent) {
      xrange <- range(d$x)
      seg_x <- seq(max(xrange[1], d$x0[1] - 0.2*(xrange[2]-xrange[1])),
                   min(xrange[2], d$x0[1] + 0.2*(xrange[2]-xrange[1])),
                   length.out = 50)
      seg_y <- d$f0[1] + d$m0[1] * (seg_x - d$x0[1])
      p <- p + geom_line(data = data.frame(x = seg_x, y = seg_y),
                         aes(x, y), color = "blue", linetype = "dashed")
    }
    
    if (input$show_avgline && is.finite(d$a0[1])) {
      x_start <- 0
      if (abs(d$x0[1]) > .Machine$double.eps) {
        slope_avg <- d$a0[1]
        y_start <- slope_avg * x_start
        p <- p + geom_segment(aes(x = x_start, xend = d$x0[1], y = y_start, yend = d$f0[1]),
                              color = "orange", linewidth = 1)
        xm <- (x_start + d$x0[1]) / 2
        ym <- (y_start + d$f0[1]) / 2
        p <- p + annotate("text", x = xm, y = ym,
                          label = paste0("slope = A(x0) = ", round(slope_avg, 3)),
                          color = "orange", vjust = -0.5)
      }
    }
    
    if (input$show_points) {
      p <- p +
        geom_point(aes(x = x0, y = f0), size = 3) +
        annotate("text", x = d$x0[1], y = d$f0[1], label = "  f(x0)", hjust = 0, vjust = -0.7)
    }
    
    p
  })
  
  output$plot_ma <- renderPlot({
    d <- df_all()
    p <- ggplot(d, aes(x)) +
      geom_line(aes(y = mx, color = "Marginal: f'(x)"), linewidth = 1) +
      geom_line(aes(y = ax, color = "Average: f(x)/x"), linewidth = 1) +
      scale_color_manual(values = c("Marginal: f'(x)" = "blue", "Average: f(x)/x" = "orange")) +
      labs(title = "Marginal vs Average",
           y = "Value", x = "x", color = "Legend") +
      theme_minimal(base_size = 13)
    
    if (input$show_points) {
      p <- p +
        geom_point(aes(x = x0, y = m0), color = "blue") +
        geom_point(aes(x = x0, y = a0), color = "orange") +
        annotate("text", x = d$x0[1], y = d$m0[1], label = "  M(x0)", hjust = 0, vjust = -0.7, color = "blue") +
        annotate("text", x = d$x0[1], y = d$a0[1], label = "  A(x0)", hjust = 0, vjust = 1.3, color = "orange")
    }
    
    p
  })
  
  output$values <- renderUI({
    d <- df_all()
    HTML(sprintf("<p><b>At x<sub>0</sub> = %.3f:</b> &nbsp; M(x<sub>0</sub>) = f'(x<sub>0</sub>) = %.3f &nbsp;&nbsp; | &nbsp;&nbsp; A(x<sub>0</sub>) = f(x<sub>0</sub>)/x<sub>0</sub> = %.3f</p>",
                 d$x0[1], d$m0[1], d$a0[1]))
  })
}

shinyApp(ui, server)
