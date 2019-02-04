#second file, server, what the data will pull from
library(shiny)
library(data.table)
library(tidyverse)
library(stringr)
library(lubridate)


server <- function(input, output) {
  
  ## create reactive data set from the user input file
  df = eventReactive(input$do,{
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    df = read_csv(inFile$datapath)
  })
  
  
  ## Create a new reactive data set when user clicks transform button
  ## This data set will be a cleaned version of the original data set
  cleanData <- eventReactive(input$transform,{

    ## calls function above to get the original data from user
    mu_data <- df()

    ## Filter so that the provider name isn't "practice"
    mu_data <- filter(mu_data, mu_data[,2] != "practice")
    
    ## Select only the variables we will need for analysis
    mu_data <- select(mu_data, varsForAnalysis)
    
    colnames(mu_data)[1:3] <- c("PracticeName", "ProviderName" ,"ProviderNPI")
    mu_data <- mutate(mu_data, NumDenom= paste(Numerator_1, Denominator_1, sep =","))
    
    ## Select the variables to keep then group by providerNPI and 
    ## spread so each column is the measurID and contains the Numerator/Denominator information
    spread_mu <- select(mu_data, c("PracticeName", "ProviderName" ,"ProviderNPI",
                                   "Measure_Id", "Reporting_start_date_1", 
                                   "Reporting_end_date_1", "NumDenom")) %>% 
      group_by(ProviderNPI) %>% 
      spread(Measure_Id, NumDenom)
    
    
    ## Keep the starting and ending reporting date and convert from character class to date class
    spread_mu$Reporting_start_date_1 <- as.Date(spread_mu$Reporting_start_date_1, format="%m/%d/%y")
    spread_mu$Reporting_end_date_1 <- as.Date(spread_mu$Reporting_end_date_1, format="%m/%d/%y")
    
    ## vector of column names
    oldNames <- colnames(spread_mu)[6:length(colnames(spread_mu))]
    
    ## separate into two columns for each numerator/denominator pair
    for(i in 1:length(oldNames)){
      spread_mu <- spread_mu %>%
        separate(oldNames[i], c(paste("Num-",oldNames[i],sep=""), 
                                paste("Denom-", oldNames[i], sep = "")), ",")
    }
    
    ## Create a new data frame contianing provider name from spread_mu dataframe
    fullData <- as.data.frame(paste("MU", spread_mu$ProviderName, " "))
    colnames(fullData)[1] <- mu_names[1]
    
    ## add in the empty columns that we need in order to upload the file
    for(i in 2:8){
      fullData <- mutate(fullData, assign(paste(mu_names[i],"",""),NA))
      colnames(fullData)[i] <- mu_names[i] 
    }
    
    
    ## Start connecting with spread_mu data, add columns in the correct order
    fullData <- cbind(fullData, spread_mu$PracticeName)
    fullData <- cbind(fullData, spread_mu$ProviderNPI)
    fullData <- cbind(fullData, spread_mu$Reporting_start_date_1)
    fullData <- cbind(fullData, spread_mu$Reporting_end_date_1)
    fullData <- cbind(fullData, spread_mu$ProviderName)
    colnames(fullData)[9:13] <- mu_names[9:13]
    
    
    ## No responses to MU measures 1 or 2
    changeNames <- mutate(fullData, ephi=NA)
    changeNames <- mutate(changeNames, cdss=NA)
    colnames(changeNames)[14:15] <- mu_names[14:15]
    
    ## Attach MU columns 6 - 19 to the data frame
    for(i in 6:19){
      changeNames <- cbind(changeNames, spread_mu[,i])
    }
    colnames(changeNames)[16:29] <- mu_names[16:29]
    
    
    ## These columns are out of order, add measure 9 before adding
    ## Response to public health
    changeNames <- cbind(changeNames, spread_mu$`Num-OBJ: 9`)
    changeNames <- cbind(changeNames, spread_mu$`Denom-OBJ: 9`)
    changeNames <- mutate(changeNames, pubHealth=NA)
    colnames(changeNames)[30:32] <- mu_names[30:32]
    
    ## Add the two parts to measure 8
    for(i in 20:23){
      changeNames <- cbind(changeNames, spread_mu[,i])
    }
    colnames(changeNames)[33:36] <- mu_names[33:36]

    ## store in the object cleanedData
    cleanedData <- changeNames
    })
  
  
  
  ## Render a data table based on whether or not the transform button was clicked
  output$contents <- renderDataTable({
    req(input$file1)
    
    if(input$transform){
      if(input$disp == "head") {
        return(head(cleanData()))
      }
      else {
        return(cleanData())
      }
    }
    
    else{
      if(input$disp == "head") {
        return(head(df()))
      }
      else {
        return(df())
      }
    }
  })
  
  
  ## This corresponds to the downloadData button and will save the cleanData file
  output$downloadData <- downloadHandler(
    filename = function() { paste("edited-", input$file1, sep='') },
    content = function(file){
      write.csv(cleanData(), file)
    }
  )
  
}