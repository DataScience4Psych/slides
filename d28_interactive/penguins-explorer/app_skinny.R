# Palmer Penguins Explorer
# Interactive Shiny app for DS4P
# Run with: shiny::runApp("penguins-explorer")

library(shiny)
library(tidyverse)
library(palmerpenguins)

# ---- UI ----
ui <- fluidPage(
  titlePanel("Palmer Penguins Explorer"),

  sidebarLayout(
    sidebarPanel(
      # Variable selection
      selectInput(inputId = "x_var",
                  label = "X-axis variable:",
                  choices = c("bill_length_mm", "bill_depth_mm",
                              "flipper_length_mm", "body_mass_g")
                  ),

      selectInput(inputId = "y_var",
                  label = "Y-axis variable:",
                  choices = c("bill_length_mm", "bill_depth_mm",
                                        "flipper_length_mm", "body_mass_g")
                  ),
      checkboxInput(
        inputId = "color_species",
        label = "Color by species",
        value = TRUE
      )
      ),

    mainPanel(
      plotOutput(outputId = "scatter_plot")
    )
  )
)



# ---- Server ----
server <- function(input, output) {
  output$scatter_plot <- renderPlot({
    if (input$color_species) {
      p <- ggplot(penguins,
                  aes(x = .data[[input$x_var]],
                      y = .data[[input$y_var]],
                      color = species)) +
        scale_color_viridis_d()
    } else {
      p <- ggplot(penguins,
                  aes(x = .data[[input$x_var]],
                      y = .data[[input$y_var]]))
    }
    p + geom_point(size = 2, alpha = 0.7) +
      theme_minimal() +
      labs(x = str_replace_all(input$x_var, "_", " "),
           y = str_replace_all(input$y_var, "_", " "))
  })
}

shinyApp(ui, server)
