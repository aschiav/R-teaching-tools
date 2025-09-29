library(shiny)
library(plotly)

utility <- function(X, Y, alpha = 0.5) {
  X^alpha * Y^(1 - alpha)
}

ui <- fluidPage(
  titlePanel("3D Cobb-Douglas Utility Function with Contours (Persistent Orientation)"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("alpha", "Alpha (share parameter for X):", min = 0.01, max = 0.99, value = 0.5, step = 0.01),
      sliderInput("X_max", "Max X value:", min = 1, max = 20, value = 10),
      sliderInput("Y_max", "Max Y value:", min = 1, max = 20, value = 10),
      sliderInput("resolution", "Grid resolution:", min = 10, max = 100, value = 50)
    ),
    
    mainPanel(
      plotlyOutput("utilityPlot")
    )
  )
)

server <- function(input, output, session) {
  
  # Initialize plot only once
  output$utilityPlot <- renderPlotly({
    X_seq <- seq(0.1, input$X_max, length.out = input$resolution)
    Y_seq <- seq(0.1, input$Y_max, length.out = input$resolution)
    grid <- expand.grid(X = X_seq, Y = Y_seq)
    U_matrix <- matrix(utility(grid$X, grid$Y, input$alpha), nrow = input$resolution, ncol = input$resolution)
    
    plot_ly(x = X_seq, y = Y_seq, z = U_matrix) %>%
      add_surface(contours = list(
        z = list(show=TRUE, usecolormap=TRUE, highlightcolor="#ff0000", project=list(z=TRUE))
      )) %>%
      layout(title = paste0("Cobb-Douglas Utility Surface (α = ", input$alpha, ")"),
             scene = list(
               xaxis = list(title = "X"),
               yaxis = list(title = "Y"),
               zaxis = list(title = "Utility U(X,Y)")
             ))
  })
  
  # Update surface using plotlyProxy whenever alpha changes
  observe({
    X_seq <- seq(0.1, input$X_max, length.out = input$resolution)
    Y_seq <- seq(0.1, input$Y_max, length.out = input$resolution)
    grid <- expand.grid(X = X_seq, Y = Y_seq)
    U_matrix <- matrix(utility(grid$X, grid$Y, input$alpha), nrow = input$resolution, ncol = input$resolution)
    
    plotlyProxy("utilityPlot", session) %>%
      plotlyProxyInvoke("restyle", list(z = list(U_matrix)))
  })
}

shinyApp(ui, server)
