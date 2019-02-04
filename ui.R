library(shiny)
## The UI page controls the layout and appearance of the shiny application
ui <- fluidPage(
  
  # Title for the application
  titlePanel("Upload MU Files"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Select a file
      fileInput("file1", "Select CSV File From Computer to Upload",
                accept=c('text/csv', 
                         'text/comma-separated-values,text/plain', 
                         '.csv')),
      helpText("Note: You must click the \"Upload File\" Button to actually upload"),
      actionButton("do", "Upload File"),
      
      
      # Horizontal line
      tags$hr(),
      
      # Input: Display options (10 lines vs. entire file)
      radioButtons("disp", "Display Options",
                   choices = c("First 10 lines" = "head",
                               "Entire Data File" = "all"),
                   selected = "head"),
      
      # Horizontal lines 
      tags$hr(),
      tags$hr(),
      
      ## Action button to initiate process of cleaning data
      actionButton("transform", "Clean Data"),
      
      # Horizontal lines 
      tags$hr(),
      tags$hr(),
      
      # Download button to save the cleaned data
      downloadButton("downloadData", "Download")
      ),
    
    # Main panel for displaying outputs
    mainPanel(
      # Table displaying contents of data file & results from cleaning the data file
      dataTableOutput("contents")
    )
    
  )
)