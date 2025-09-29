library(shiny)
library(ggplot2)

alpha <- 0.5  # Cobb-Douglas preference

# Utility and marginal utility functions
U <- function(P, M) P^alpha * M^(1 - alpha)
MU_P <- function(P, M) alpha * P^(alpha - 1) * M^(1 - alpha)
MU_M <- function(P, M) (1 - alpha) * P^alpha * M^(-alpha)

ui <- fluidPage(
  titlePanel("Intuitive Understanding of MRS: Pizzas & Movies"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("pizza", "Number of Pizzas (P):", min = 1, max = 20, value = 5, step = 0.1),
      br(),
      h4("Marginal Rate of Substitution:"),
      HTML('<p style="font-size:18px; text-align:left;">
           MRS = - <span style="color:red;">MU<sub>P</sub></span> / <span style="color:green;">MU<sub>M</sub></span>
           </p>')
    ),
    
    mainPanel(
      plotOutput("indifferencePlot"),
      fluidRow(
        column(6, plotOutput("pizzaUtilityPlot")),
        column(6, plotOutput("moviesUtilityPlot"))
      )
    )
  )
)

server <- function(input, output, session) {
  
  # Compute movies to stay on indifference curve
  M_indiff <- reactive({ (U(5, 10) / input$pizza^alpha)^(1/(1 - alpha)) })
  
  # ---- Top: Indifference curve with tangent ----
  output$indifferencePlot <- renderPlot({
    P_vals <- seq(1, 20, length.out = 200)
    M_vals <- (U(5, 10) / P_vals^alpha)^(1 / (1 - alpha))
    
    P0 <- input$pizza
    M0 <- M_indiff()
    
    slope_IC <- -MU_P(P0, M0)/MU_M(P0, M0)
    
    # Short tangent line
    delta <- 3
    tangent_df <- data.frame(
      P = seq(P0 - delta, P0 + delta, length.out = 50),
      M = slope_IC * (seq(P0 - delta, P0 + delta, length.out = 50) - P0) + M0
    )
    
    df <- data.frame(P = P_vals, M = M_vals)
    
    ggplot(df, aes(x = P, y = M)) +
      geom_line(color = "black", size = 1) +
      geom_line(data = tangent_df, aes(x = P, y = M), color = "black", linetype = "dashed", size = 1) +
      geom_point(aes(x = P0, y = M0), color = "black", size = 3) +
      labs(x = "Pizzas", y = "Movies", title = "Indifference Curve with Tangent") +
      theme_minimal() +
      theme(axis.text = element_blank(), axis.ticks = element_blank()) +
      coord_cartesian(xlim = c(0, 20), ylim = c(0, 20))
  })
  
  # ---- Bottom left: Pizza vs Utility ----
  output$pizzaUtilityPlot <- renderPlot({
    P_vals <- seq(1, 20, length.out = 200)
    M_fixed <- M_indiff()
    U_vals <- U(P_vals, M_fixed)
    
    P0 <- input$pizza
    U0_current <- U(P0, M_fixed)
    slope_P <- MU_P(P0, M_fixed)
    
    # Slightly longer tangent line
    delta <- 5
    tangent_df <- data.frame(
      P = seq(P0 - delta, P0 + delta, length.out = 50),
      U = slope_P * (seq(P0 - delta, P0 + delta, length.out = 50) - P0) + U0_current
    )
    
    ggplot(data.frame(P = P_vals, U = U_vals), aes(x = P, y = U)) +
      geom_line(color = "black", size = 1) +
      geom_line(data = tangent_df, aes(x = P, y = U), color = "red", linetype = "dashed", size = 1) +
      geom_point(aes(x = P0, y = U0_current), color = "black", size = 3) +
      labs(x = "Pizzas", y = "Utility", title = "Utility vs Pizzas") +
      theme_minimal() +
      theme(axis.text = element_blank(), axis.ticks = element_blank()) +
      coord_cartesian(xlim = c(0, 20), ylim = c(0, max(U_vals)))
  })
  
  # ---- Bottom right: Movies vs Utility ----
  output$moviesUtilityPlot <- renderPlot({
    M_vals <- seq(1, 20, length.out = 200)
    P_fixed <- input$pizza
    U_vals <- U(P_fixed, M_vals)
    
    M0 <- M_indiff()
    U0_current <- U(P_fixed, M0)
    slope_M <- MU_M(P_fixed, M0)
    
    # Slightly longer tangent line
    delta <- 5
    tangent_df <- data.frame(
      M = seq(M0 - delta, M0 + delta, length.out = 50),
      U = slope_M * (seq(M0 - delta, M0 + delta, length.out = 50) - M0) + U0_current
    )
    
    ggplot(data.frame(M = M_vals, U = U_vals), aes(x = M, y = U)) +
      geom_line(color = "black", size = 1) +
      geom_line(data = tangent_df, aes(x = M, y = U), color = "green", linetype = "dashed", size = 1) +
      geom_point(aes(x = M0, y = U0_current), color = "black", size = 3) +
      labs(x = "Movies", y = "Utility", title = "Utility vs Movies") +
      theme_minimal() +
      theme(axis.text = element_blank(), axis.ticks = element_blank()) +
      coord_cartesian(xlim = c(0, 20), ylim = c(0, max(U_vals)))
  })
  
}

shinyApp(ui, server)
