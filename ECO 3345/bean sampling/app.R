library(shiny)
library(ggplot2)
library(dplyr)
library(DT)

ui <- fluidPage(
  titlePanel("Sampling Activity: Red Beans and the Central Limit Theorem"),

  sidebarLayout(
    sidebarPanel(
      h4("Add a class sample"),
      numericInput(
        "red_percent_input",
        "Percent of red beans in the sample",
        value = NA,
        min = 0,
        max = 100,
        step = 0.1
      ),
      actionButton("add_sample", "Add sample percentage"),
      br(), br(),
      actionButton("remove_last", "Remove last sample"),
      actionButton("clear_all", "Clear all samples"),
      hr(),
      h4("Display options"),
      sliderInput("bins", "Histogram bins", min = 5, max = 30, value = 10),
      checkboxInput("show_density", "Overlay density curve", value = FALSE),
      checkboxInput("show_true_line", "Show true value", value = FALSE),
      hr(),
      h4("CLT simulation"),
      numericInput("sim_reps", "Number of simulated samples", value = 1000, min = 100, step = 100),
      actionButton("run_sim", "Run simulation")
    ),

    mainPanel(
      tabsetPanel(
        tabPanel(
          "Class data",
          br(),
          fluidRow(
            column(
              6,
              wellPanel(
                h4("Summary"),
                verbatimTextOutput("summary_text")
              )
            )
          ),
          plotOutput("hist_plot", height = "450px"),
          hr(),
          h4("Entered sample percentages"),
          DTOutput("sample_table")
        ),

        tabPanel(
          "Simulation",
          br(),
          plotOutput("sim_plot", height = "450px"),
          verbatimTextOutput("sim_text")
        ),

        tabPanel(
          "CLT overview",
          br(),
          p("When we repeatedly take random samples of the same size, the distribution of sample proportions becomes approximately normally distributed."),
          p("This is known as the ", strong("Central Limit Theorem")),
          
          h3("Key intuition"),
          tags$ul(
            tags$li("The center of the histogram should be close to 20%."),
            tags$li("Variation comes from randomness in sampling."),
            tags$li("More samples lead to a clearer overall shape."),
            tags$li("Larger sample sizes lead to a tighter distribution.")
          ),

          h3("Big takeaway"),
          p("Individual samples are noisy, but the distribution of many samples reveals the true population value.")
        )
      )
    )
  )
)

server <- function(input, output, session) {

  samples <- reactiveVal(
    data.frame(
      sample_number = integer(),
      red_percent = numeric(),
      stringsAsFactors = FALSE
    )
  )

  observeEvent(input$add_sample, {
    req(input$red_percent_input)

    if (input$red_percent_input < 0 || input$red_percent_input > 100) {
      showNotification("Percentage must be between 0 and 100.", type = "error")
      return()
    }

    current <- samples()
    new_row <- data.frame(
      sample_number = nrow(current) + 1,
      red_percent = input$red_percent_input,
      stringsAsFactors = FALSE
    )

    samples(bind_rows(current, new_row))
    updateNumericInput(session, "red_percent_input", value = NA)
  })

  observeEvent(input$remove_last, {
    current <- samples()
    if (nrow(current) > 0) {
      samples(current[-nrow(current), , drop = FALSE])
    }
  })

  observeEvent(input$clear_all, {
    samples(
      data.frame(
        sample_number = integer(),
        red_percent = numeric(),
        stringsAsFactors = FALSE
      )
    )
  })

  output$sample_table <- renderDT({
    datatable(samples(), rownames = FALSE, options = list(pageLength = 10, dom = "tip"))
  })

  output$summary_text <- renderText({
    df <- samples()

    if (nrow(df) == 0) return("No sample percentages entered yet.")

    paste0(
      "Number of class samples: ", nrow(df), "\n",
      "Average sample % red: ", round(mean(df$red_percent), 2), "%\n",
      "Median sample % red: ", round(median(df$red_percent), 2), "%\n",
      "Min: ", round(min(df$red_percent), 2), "% | Max: ", round(max(df$red_percent), 2), "%\n",
      "True population % red: 20%"
    )
  })

  output$hist_plot <- renderPlot({
    df <- samples()

    if (nrow(df) == 0) {
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, label = "Enter sample percentages to see the histogram", size = 7) +
        theme_void()
    } else {
      p <- ggplot(df, aes(x = red_percent)) +
        geom_histogram(bins = input$bins, boundary = 0, closed = "left") +
        scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, 10)) +
        labs(
          x = "Percent red beans in sample",
          y = "Frequency",
          title = "Histogram of class sample percentages"
        ) +
        theme_minimal(base_size = 14)

      if (isTRUE(input$show_density) && nrow(df) > 1) {
        p <- p + geom_density(aes(y = after_stat(count)), linewidth = 1)
      }

      if (isTRUE(input$show_true_line)) {
        p <- p + geom_vline(xintercept = 20, linetype = "dashed", linewidth = 1.2)
      }

      p
    }
  })

  sim_data <- eventReactive(input$run_sim, {
    x <- rbinom(input$sim_reps, size = 25, prob = 0.20)
    data.frame(sample_percent = 100 * x / 25)
  }, ignoreNULL = FALSE)

  output$sim_plot <- renderPlot({
    df <- sim_data()

    p <- ggplot(df, aes(x = sample_percent)) +
      geom_histogram(bins = input$bins, boundary = 0, closed = "left") +
      scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, 10)) +
      labs(
        x = "Simulated sample % red",
        y = "Frequency"      ) +
      theme_minimal(base_size = 14)

    if (isTRUE(input$show_density) && nrow(df) > 1) {
      p <- p + geom_density(
        aes(y = after_stat(count)),
        linewidth = 1,
        bw = 4.5,
        kernel = "gaussian",
        n = 2048
      )
    }

    if (isTRUE(input$show_true_line)) {
      p <- p + geom_vline(xintercept = 20, linetype = "dashed", linewidth = 1.2)
    }

    p
  })

  output$sim_text <- renderText({
    df <- sim_data()
    paste0(
      "Mean: ", round(mean(df$sample_percent), 2), "%\n",
      "SD: ", round(sd(df$sample_percent), 2), "\n")
  })
}

shinyApp(ui = ui, server = server)
