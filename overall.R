# Load packages
library(shiny)

# Load choropleth
load("choropleth.rda")

# Define UI
ui <- fluidPage(
  titlePanel("Sentiment Analaysis of Social Netizens -
             By Christina Daquieno"),
  sidebarLayout(
    sidebarPanel(
      HTML("Sentiment analysis and opinion mining have a wide set of applications in businesses, politics and healthcare to understand the stakeholders. In this study, we analyze the mood and emotions of citizens in the United States, applying the sentiment analysis on a large-scale social network data. The geographic, temporal and topical analyses may bring many insights on understanding population level emotions of citizens. We employ Data Science methods to collect the twitter datasets collected using Twitters API and analyze them using the sentiment analysis package Syuzhet in R Studio. We determine the emotions of the people in each state. Social Media now allows us to have a large form of opinionated data for analysis. The dataset used in this study is a collection of Tweets consisting of personal thoughts, opinions or just a simple emoji. The data from Twitter allows getting different opinions from all social and interest groups. This helps prevent bias when running the sentiment analysis. The sentiment analysis classifies each tweet into negative and positive emotional categories. The machine classified tweets are then visualized according to the location of the tweets to a map to show the positive and negative emotional scales in each state of the US. The temporal analysis and topical analyses will reveal population level feelings related to residence, and their prominent linguistic expressions.
          https://sentimentofusa.shinyapps.io/analysis/
           http://52.14.221.36:3838/census/
           https://github.com/cdaquieno/sentiment-  ")
    ),
    mainPanel(
      plotOutput("choropleth")
    )
  )
)

# Define server function
server <- function(input, output) {
  output$choropleth <- renderPlot(choropleth)
}

# Create Shiny object
shinyApp(ui = ui, server = server)
