################################################################################
# A file including backend code (server) 
################################################################################

# global r otwiera się tylko raz i dopeiro potem patrzymy na ui i server
# dobre to wciagania paczek, możemy trzymać tutaj stałe zmiennne
# zdefiniowac połącznien z bazą danych

shinyServer(function(input, output, session) {

  
  out$delayRangeUI <- renderUI({
    
    sliderInput(
      inputId = "delayRange",
      label = "Okresl przedzial opóżnienia:",
      min = 0,
      max = 1000,
      value = c(100,1000)
    )
  })
  
  agreg_data <- reactive({
  
  aggDelayFlights <- modFlights %>% 
    filter(name %in% input$carrierName) %>%
    group_by(name, hour) %>% 
    summarise(delayed_flight_perc = sum(
      dep_delay > input$delayRange[1] &
        dep_delay < input$delayRange[2] &
        distance >= input$distance_valuse/ n()))
})
  output$delay_plot <- renderPlot({
    # Aggregate data

    
    # Create a plot
    ggplot(agreg_data(), aes(hour, delayed_flight_perc, fill= name)) + 
      geom_col(position = 'dodge') +
      theme_hc(base_size = 18) + 
      scale_fill_hc() +
      xlab("Hour") +
      ylab("Percentage of delayed flights") +
      scale_y_continuous(labels = scales::percent) +
      scale_x_continuous(limits = c(0,24), breaks = seq(0, 24, 2))
    
  })
  
  output$table_plot <- renderTable({

    agreg_data() %>%
    mutate(
        delayed_flight_perc = scales::percent(delayed_flight_perc)
      )
      
    
  })

})



