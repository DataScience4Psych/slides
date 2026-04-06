# Palmer Penguins Explorer
# Interactive Shiny app for DS4P
# Run with: shiny::runApp("penguins-explorer")

library(shiny)
library(tidyverse)
library(palmerpenguins)

# Numeric columns available for plotting
numeric_vars <- c(
  "Bill Length (mm)"    = "bill_length_mm",
  "Bill Depth (mm)"     = "bill_depth_mm",
  "Flipper Length (mm)"  = "flipper_length_mm",
  "Body Mass (g)"        = "body_mass_g"
)

# ---- UI ----
ui <- fluidPage(
  titlePanel("Palmer Penguins Explorer"),

  sidebarLayout(
    sidebarPanel(
      width = 3,

      # Variable selection
      selectInput("x_var", "X-axis variable:",
                  choices = numeric_vars,
                  selected = "bill_depth_mm"),

      selectInput("y_var", "Y-axis variable:",
                  choices = numeric_vars,
                  selected = "bill_length_mm"),

      hr(),

      # Appearance controls
      checkboxInput("color_species", "Color by species", value = TRUE),

      sliderInput("pt_size", "Point size:",
                  min = 0.5, max = 5, value = 2, step = 0.5),

      sliderInput("pt_alpha", "Point opacity:",
                  min = 0.1, max = 1, value = 0.7, step = 0.1),

      hr(),

      # Filtering
      checkboxGroupInput("species", "Species:",
                         choices = levels(penguins$species),
                         selected = levels(penguins$species)),

      checkboxGroupInput("island", "Island:",
                         choices = levels(penguins$island),
                         selected = levels(penguins$island)),

      hr(),

      # Extras
      checkboxInput("add_smooth", "Add trend line", value = FALSE),
      checkboxInput("facet_species", "Facet by species", value = FALSE)
    ),

    mainPanel(
      width = 9,

      tabsetPanel(
        type = "tabs",

        tabPanel(
          "Scatter Plot",
          plotOutput("scatter_plot", height = "500px"),
          br(),
          verbatimTextOutput("correlation")
        ),

        tabPanel(
          "Distributions",
          fluidRow(
            column(6, plotOutput("hist_x", height = "400px")),
            column(6, plotOutput("hist_y", height = "400px"))
          )
        ),

        tabPanel(
          "Data Table",
          br(),
          textOutput("n_obs"),
          br(),
          dataTableOutput("data_table")
        ),

        tabPanel(
          "Summary Statistics",
          br(),
          tableOutput("summary_table")
        )
      )
    )
  )
)

# ---- Server ----
server <- function(input, output) {

  # Reactive: filtered data
  filtered_data <- reactive({
    penguins %>%
      filter(!is.na(species),
             species %in% input$species,
             island %in% input$island) %>%
      drop_na(all_of(c(input$x_var, input$y_var)))
  })

  # Helper to get nice axis labels
  label_for <- function(var) {
    names(numeric_vars)[numeric_vars == var]
  }

  # ---- Scatter Plot ----
  output$scatter_plot <- renderPlot({
    df <- filtered_data()

    if (input$color_species) {
      p <- ggplot(df, aes(x = .data[[input$x_var]],
                          y = .data[[input$y_var]],
                          color = species)) +
        scale_color_viridis_d()
    } else {
      p <- ggplot(df, aes(x = .data[[input$x_var]],
                          y = .data[[input$y_var]]))
    }

    p <- p +
      geom_point(size = input$pt_size, alpha = input$pt_alpha) +
      theme_minimal(base_size = 14) +
      labs(x = label_for(input$x_var),
           y = label_for(input$y_var),
           color = "Species")

    if (input$add_smooth) {
      p <- p + geom_smooth(method = "lm", se = TRUE)
    }

    if (input$facet_species && input$color_species) {
      p <- p + facet_wrap(~ species)
    }

    p
  })

  # ---- Correlation ----
  output$correlation <- renderPrint({
    df <- filtered_data()
    r <- cor(df[[input$x_var]], df[[input$y_var]], use = "complete.obs")
    cat(sprintf("Pearson correlation (r) between %s and %s: %.3f  (n = %d)",
                label_for(input$x_var), label_for(input$y_var),
                r, nrow(df)))
  })

  # ---- Histograms ----
  output$hist_x <- renderPlot({
    df <- filtered_data()

    if (input$color_species) {
      p <- ggplot(df, aes(x = .data[[input$x_var]], fill = species)) +
        scale_fill_viridis_d(alpha = 0.7)
    } else {
      p <- ggplot(df, aes(x = .data[[input$x_var]]))
    }

    p + geom_histogram(bins = 25, color = "white") +
      theme_minimal(base_size = 14) +
      labs(x = label_for(input$x_var), y = "Count",
           title = paste("Distribution of", label_for(input$x_var)),
           fill = "Species")
  })

  output$hist_y <- renderPlot({
    df <- filtered_data()

    if (input$color_species) {
      p <- ggplot(df, aes(x = .data[[input$y_var]], fill = species)) +
        scale_fill_viridis_d(alpha = 0.7)
    } else {
      p <- ggplot(df, aes(x = .data[[input$y_var]]))
    }

    p + geom_histogram(bins = 25, color = "white") +
      theme_minimal(base_size = 14) +
      labs(x = label_for(input$y_var), y = "Count",
           title = paste("Distribution of", label_for(input$y_var)),
           fill = "Species")
  })

  # ---- Data Table ----
  output$n_obs <- renderText({
    paste("Showing", nrow(filtered_data()), "observations")
  })

  output$data_table <- renderDataTable({
    filtered_data() %>%
      select(species, island, all_of(c(input$x_var, input$y_var)),
             sex, year)
  }, options = list(pageLength = 15))

  # ---- Summary Statistics ----
  output$summary_table <- renderTable({
    filtered_data() %>%
      group_by(species) %>%
      summarize(
        n = n(),
        across(all_of(c(input$x_var, input$y_var)),
               list(mean = ~ mean(.x, na.rm = TRUE),
                    sd   = ~ sd(.x, na.rm = TRUE)),
               .names = "{.col}_{.fn}")
      )
  }, digits = 2)
}

shinyApp(ui, server)
