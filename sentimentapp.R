# Load 
library(shiny)
library(dplyr)
library(syuzhet)

# UI
ui <- fluidPage(
  titlePanel("Get sentiment"),
  sidebarLayout(
    sidebarPanel(
      textInput(
        "text",
        label = NULL,
        value = "I love Dr. Soon Chun",
        width = NULL,
        placeholder = "Compose text here"
      )
    ),
    mainPanel(
      tableOutput("table")
    )
  )
)

# Server
server <- function(input, output, session) {
  output$table <- renderTable({
    input$text %>% (function(text) tibble(Text = text, Mood = get_sentiment(text)))
  })
}

# Run
shinyApp(ui = ui, server = server)
