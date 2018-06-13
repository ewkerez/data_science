################################################################################
# A file including user interface (UI) code
################################################################################

fluidPage(
  titlePanel("Aplikacja Shinny"),
  
  sidebarLayout(
  sidebarPanel(
    selectInput(
      inputId = "carrierName",
      label = "wybierz przewoźnika:",
      choices = sort(chosenCarrier$name),
      selected = sort(chosenCarrier$name)[1],
      multiple = TRUE,
      selectize = TRUE,
      width = NULL,
      size = NULL
    ),
    numericInput(
      inputId = "distance_valuse",
      label = "",
      value = 500
    ),
    uiOutput("delayRangeUI")
    # sliderInput(
    #   inputId = "delayRange",
    #   label = "Okresl przedzial opóżnienia:",
    #   min = 0,
    #   max = 1000,
    #   value = c(100,1000)
    # )
  ),            
  
  mainPanel(
    tabsetPanel(
    tabPanel(title = "Delay over day",
             plotOutput(outputId = "delay_plot")),
    tabPanel(title = "Explore data",
             tableOutput(outputId = "table_plot"))
            )
            )

  )
)



#fluidPage(
 # titlePanel("My first shiny app"),
  #sidebarLayout(
   # sidebarPanel("Side panel"
    #             # Here you add elements of side panel
  #  ),
   # mainPanel("Main panel"
              # Here you add elements of main panel
    #)
 # )
#)
