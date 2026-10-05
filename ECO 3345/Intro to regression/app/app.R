library(shiny)
source(file.path("R", "plot_helpers.R"), local = TRUE)

# Fixed CSV files: everyone sees exactly the same observations.
datasets <- read_activity_data("data")

ui <- fluidPage(
  tags$head(
    tags$title("Intro to regression"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$style(HTML("
      body { background:#f4f7fa; color:#182638; font-family:system-ui,-apple-system,sans-serif; }
      .activity { max-width:1000px; margin:24px auto; padding:26px; background:white;
                  border:1px solid #e2e8ef; border-radius:16px; }
      h1 { font-size:28px; font-weight:650; margin:0 0 10px; }
      .intro { color:#475569; margin-bottom:22px; font-size:16px; }
      .controls { display:grid; grid-template-columns:1fr 1fr; column-gap:32px; }
      .equation { background:#edf7f8; border-radius:10px; padding:14px 18px;
                  font-size:26px; font-weight:600; font-variant-numeric:tabular-nums; }
      .equation-label { display:block; font-size:13px; font-weight:500; color:#425563; margin-bottom:4px; }
      .control-label { margin-bottom:6px; font-size:15px; font-weight:600; }
      .footer-note { color:#475569; font-size:14px; margin-top:6px; }
      .shiny-input-container { width:100% !important; }
      .irs--shiny .irs-bar { border-color:#087f8c; background:#087f8c; }
      .irs--shiny .irs-single { background:#087f8c; }
      #scatter { height:420px !important; }
      @media(max-width:600px) {
        .activity { margin:8px auto; padding:16px 10px; border-radius:10px; }
        .controls { grid-template-columns:1fr; }
        h1 { font-size:24px; }
        .equation { font-size:23px; }
        #scatter { height:340px !important; }
      }
    "))
  ),
  div(class = "activity",
    h1("Intro to regression"),
    p(class = "intro", "Move the line until it fits the pattern in the points."),
    selectInput("dataset", "Dataset", choices = setNames(seq_along(datasets), paste("Dataset", seq_along(datasets))),
                selected = 1, selectize = FALSE),
    div(class = "equation", role = "status", `aria-live` = "polite",
        span(class = "equation-label", "Your line"), textOutput("equation", inline = TRUE)),
    plotOutput("scatter", height = "420px"),
    div(class = "controls",
        sliderInput("intercept", "Intercept",
                    min = -10, max = 35, value = 12.5, step = 0.1),
        sliderInput("slope", "Slope",
                    min = -4, max = 4, value = 0, step = 0.05)),
    p(class = "footer-note", "")
  )
)

server <- function(input, output, session) {
  selected_data <- reactive({
    req(input$dataset %in% as.character(seq_along(datasets)))
    datasets[[as.integer(input$dataset)]]
  })

  observeEvent(input$dataset, {
    updateSliderInput(session, "intercept", value = 12.5)
    updateSliderInput(session, "slope", value = 0)
  }, ignoreInit = TRUE)

  output$equation <- renderText({
    req(is.finite(input$intercept), is.finite(input$slope))
    line_equation(input$intercept, input$slope)
  })

  output$scatter <- renderPlot({
    req(is.finite(input$intercept), is.finite(input$slope))
    draw_activity_plot(selected_data(), input$intercept, input$slope)
  }, res = 110, alt = reactive(paste(
    "Scatterplot of x and y for dataset", input$dataset,
    "with your line:", line_equation(input$intercept, input$slope))))
}

shinyApp(ui, server)
