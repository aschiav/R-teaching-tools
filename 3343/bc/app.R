library(shiny)
library(ggplot2)

# Initial BC values
I_init <- 50
Px_init <- 5
Py_init <- 5

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      sliderInput("income", "Income (I₀):", min = 1, max = 100, value = I_init, step = 1, ticks = FALSE),
      sliderInput("priceX", "Price of X (Pₓ₀):", min = 1, max = 20, value = Px_init, step = 1, ticks = FALSE),
      sliderInput("priceY", "Price of Y (Pᵧ₀):", min = 1, max = 20, value = Py_init, step = 1, ticks = FALSE)
    ),
    
    mainPanel(
      plotOutput("budgetPlot")
    )
  )
)

server <- function(input, output, session) {
  
  output$budgetPlot <- renderPlot({
    I <- input$income
    Px <- input$priceX
    Py <- input$priceY
    
    # Current budget line
    X_vals <- seq(0, I/Px, length.out = 200)
    Y_vals <- (I - Px*X_vals)/Py
    df_budget <- data.frame(X = X_vals, Y = Y_vals)
    
    # Shaded affordable set
    affordable_df <- data.frame(
      X = c(0, 0, I/Px),
      Y = c(0, I/Py, 0)
    )
    
    # Original budget line (initial BC)
    X_init_vals <- seq(0, I_init/Px_init, length.out = 200)
    Y_init_vals <- (I_init - Px_init*X_init_vals)/Py_init
    df_init <- data.frame(X = X_init_vals, Y = Y_init_vals)
    
    ggplot() +
      geom_polygon(data = affordable_df, aes(x = X, y = Y), fill = "lightblue", alpha = 0.3) +
      geom_line(data = df_budget, aes(x = X, y = Y), color = "blue", size = 1.2) +
      geom_line(data = df_init, aes(x = X, y = Y), color = "gray", linetype = "dashed", size = 1) +
      # Label "Affordable Set" below the budget line
      annotate("text", x = (I/(2*Px)), y = 0.5 * I/(4*Py), label = "Affordable Set", size = 5, color = "black") +
      labs(x = "Good X", y = "Good Y", title = "Budget Constraint and Affordable Set") +
      theme_minimal() +
      theme(axis.text = element_blank(), axis.ticks = element_blank()) +
      coord_cartesian(xlim = c(0, 30), ylim = c(0, 30))
  })
  
}

shinyApp(ui, server)
