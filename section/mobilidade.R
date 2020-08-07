output$provincePlot <- renderPlotly({
  
  # filter data based on date
  df_filtered <- subset(df, 
                        date >= input$dateInput[1] & 
                          date <= input$dateInput[2] & 
                          sub_region_1 == input$provinceInput)
  
  # make ggplot 
  p <- ggplot(df_filtered, aes(x = date, y = values, color = type)) +
    geom_line() +
    scale_x_date(date_breaks = "7 days", date_labels = "%a, %d-%b") +
    labs(
      title = paste("Mostrando dados de", input$provinceInput),
      # subtitle = paste("Selected date range from ", input$dateInput[[1]], "to", input$dateInput[[2]]),
      # caption = "Google LLC 'Google COVID-19 Community Mobility Reports' \n
      #         https://www.google.com/covid19/mobility/ Accessed: <Date>",
      color = "Tipo",
      y = "% de mundança em relação a linha de base",
      x = "Data"
    ) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "bottom")
  
  # make that ggplot interactive with plotly
  ggplotly(p, tooltip = c("all"))
})

# reset button
observeEvent(
  eventExpr = input$resetInput,
  handlerExpr = updateDateRangeInput(session,
                                     inputId = "dateInput",
                                     start = min(df$date),
                                     end = max(df$date),
                                     min = min(df$date),
                                     max = max(df$date))
)



