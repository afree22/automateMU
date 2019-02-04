library(data.table)
library(tidyverse)
library(stringr)
library(lubridate)
library(shiny)

## The global file is run once when the app launches
## Objects defined in the global file are accessible in the ui.R and server.R files

## Read in mu file with appropriate names
mu_names <- read_csv("data/MU-Names.csv")
mu_names <- colnames(mu_names)


## Used in Server.R (line 31)
## select varaiables for analysis from the original data set 
## assumes that some of the column names will repeat
varsForAnalysis <- c("Practice Name", "Provider Name", "Provider NPI", 
                                 "Measure_Id", "Measure Name", "Reporting_start_date_1",
                                 "Reporting_end_date_1", "Denominator_1",
                                 "Numerator_1", "Performance_Rate")