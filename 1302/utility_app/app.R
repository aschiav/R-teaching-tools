library(shiny)
library(plotly)

# Define the Cobb-Douglas function
cobb_douglas <- function(x1, x2, alpha) {
  return(x1^alpha * x2^(1-alpha))
}

# Define UI for application
ui <- fluidPage(
  titlePanel("Cobb-Douglas Utility Function"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("alpha", 
                  "Alpha:", 
                  min = 0, 
                  max = 1, 
                  value = 0.5, 
                  step = 0.01)
    ),
    
    mainPanel(
      plotlyOutput("utilityPlot")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  output$utilityPlot <- renderPlotly({
    # Generate x1 and x2 values
    x1 <- seq(0.1, 10, length=50)
    x2 <- seq(0.1, 10, length=50)
    alpha <- input$alpha
    
    # Create a matrix of utility values
    m <- matrix(nrow = length(x1), ncol = length(x2))
    
    # Compute utility values
    for (i in 1:length(x1)) {
      for (j in 1:length(x2)) {
        m[j, i] <- cobb_douglas(x1[i], x2[j], alpha)
      }
    }
    
    # Plot with plotly
    plot_ly(z = m, type = "surface") %>%
      layout(scene = list(
        xaxis = list(title = "Pizza"),
        yaxis = list(title = "Burrito"),
        zaxis = list(title = "Utility")
      ))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
