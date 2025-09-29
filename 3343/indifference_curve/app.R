library(shiny)
library(ggplot2)

# Indifference curve utility function (Cobb-Douglas)
utility <- function(X, Y, alpha = 0.5) {
  return(X^alpha * Y^(1 - alpha))
}


# Plotting function for indifference curve
plot_indifference <- function(alpha, U_level = 100) {
  # X values (from 0.1 to 20 for visualization purposes)
  X <- seq(0.1, 20, length.out = 400)  # Avoid division by zero
  
  # Calculate Y values from the utility function
  Y <- (U_level / X^alpha)^(1 / (1 - alpha))
  
  # Filter out invalid values (NaN or negative values for Y)
  data <- data.frame(X = X, Y = Y)
  data <- data[!is.na(data$Y) & data$Y > 0, ]  # Remove NaN and negative Y values
  
  # Plot the indifference curve using ggplot2
  ggplot(data, aes(x = X, y = Y)) +
    geom_line(color = "red") +
    labs(title = paste("Indifference Curve for Utility U =", round(U_level, 2)),
         subtitle = paste("Alpha =", round(alpha, 2)),
         x = "Good X", y = "Good Y") +
    theme_minimal() +
    xlim(0, 20) +
    ylim(0, 20) +
    theme(plot.title = element_text(size = 14, face = "bold"),
          plot.subtitle = element_text(size = 12)) 
}

# Define the UI for the application
ui <- fluidPage(
  titlePanel("Interactive Cobb-Douglas Indifference Curve"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("alpha", "Alpha:", min = 0.01, max = 0.99, value = 0.5, step = 0.05),
      sliderInput("U_level", "U Level:", min = 1, max = 15, value = 5, step = 1)
    ),
    
    mainPanel(
      plotOutput("indifferencePlot"),
      uiOutput("formulaText")  # use uiOutput for MathJax
    )
  )
)

# Define the server logic
server <- function(input, output) {
  
  # Render plot
  output$indifferencePlot <- renderPlot({
    plot_indifference(input$alpha, input$U_level)
  })
  
  # Render formulas
  output$formulaText <- renderUI({
    alpha_rounded <- round(input$alpha, 2)
    U_rounded <- round(input$U_level, 2)
    
    withMathJax(
      tagList(
        # Constant formula
        helpText("Cobb-Douglas Utility Function: $$U(X,Y) = X^{\\alpha} \\cdot Y^{1-\\alpha}$$"),
        # Dynamically updated formula with utility value
        helpText(paste0("Current alpha and utility (dynamic): $$", 
                        U_rounded, "=\\cdot X^{", alpha_rounded, "} \\cdot Y^{", 
                        round(1 - alpha_rounded,2), "}$$"))
      )
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
