################################################################################
# A static ggplot2 plot
################################################################################

# Execute code in global.R
# source("global.R")

# Aggregate data
aggDelayFlights <- modFlights %>% 
  group_by(hour) %>% 
  summarise(delayed_flight_perc = sum(dep_delay > 0) / n())

# Create a plot
ggplot(aggDelayFlights, aes(hour, delayed_flight_perc)) + 
    geom_col(position = 'dodge') +
    theme_hc(base_size = 18) + 
    scale_fill_hc() +
    xlab("Hour") +
    ylab("Percentage of delayed flights") +
    scale_y_continuous(labels = scales::percent) +
    scale_x_continuous(limits = c(0,24), breaks = seq(0, 24, 2))
  