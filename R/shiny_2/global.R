################################################################################
# A file containing objects (variables) which are available both in ui.R and server.R
# It may support the app in several fields, such as package installation, 
# data preprocessing, database connection etc.
################################################################################

library(shiny)
library(nycflights13)
library(dplyr)
library(ggplot2)
library(ggthemes)

options(scipen = 999)

flights <- flights
airlines <- airlines

# Join two data.frames
modFlights <- flights %>% 
  inner_join(airlines, by = 'carrier')

# Choose only sever airlines
chosenCarrier <- modFlights %>% 
  count(name) %>% 
  arrange(desc(n)) %>% 
  head(7)

# Filter data
modFlights <- modFlights %>% 
  filter(!is.na(dep_delay), name %in% chosenCarrier$name)

