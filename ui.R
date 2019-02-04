library(shiny)

# Define UI for data upload app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Uploading Files"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Select a file ----
      fileInput("file1", "Select CSV File From Computer to Upload",
                accept=c('text/csv', 
                         'text/comma-separated-values,text/plain', 
                         '.csv')),
      helpText("Note: You must click the \"Upload File\" Button to actually upload"),
      actionButton("do", "Upload File"),
      
      
      # Horizontal line ----
      tags$hr(),
      
      # Input: Select number of rows to display ----
      radioButtons("disp", "Display Options",
                   choices = c("First 10 lines" = "head",
                               "Entire Data File" = "all"),
                   selected = "head"),
      
      # Horizontal line ----
      tags$hr(),
      tags$hr(),
      
      ## Action button to initiate process of cleaning data
      actionButton("transform", "Clean Data"),
      
      tags$hr(),
      tags$hr(),
      
      # download button to save the cleaned data
      downloadButton("downloadData", "Download")
      ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      # Table displaying contents of data file & results from cleaning the data file
      dataTableOutput("contents")
    )
    
  )
)