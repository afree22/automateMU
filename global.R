library(data.table)
library(tidyverse)
library(stringr)
library(lubridate)
library(shiny)



## Read in mu file with appropriate names
mu_names <- read_csv("data/MU-Names.csv")
mu_names <- colnames(mu_names)