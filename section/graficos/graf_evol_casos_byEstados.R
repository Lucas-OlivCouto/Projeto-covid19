getDataByEstados <- function(countries, normalizeByPopulation) {
  req(countries)
  data_confirmed <- data_evolution_estados %>%
    select(`state`, date, var, value, population) %>%
    filter(`state` %in% countries &
             var == "confirmed" &
             value > 0) %>%
    group_by(`state`, date, population) %>%
    summarise("Confirmed" = sum(value, na.rm = T)) %>%
    arrange(date)
  if (nrow(data_confirmed) > 0) {
    data_confirmed <- data_confirmed %>%
      mutate(Confirmed = if_else(normalizeByPopulation, round(Confirmed / population * 100000, 2), Confirmed))
  }
  data_confirmed <- data_confirmed %>% as.data.frame()
  
  data_recovered <- data_evolution_estados %>%
    select(`state`, date, var, value, population) %>%
    filter(`state` %in% countries &
             var == "recovered" &
             value > 0) %>%
    group_by(`state`, date, population) %>%
    summarise("Estimated Recoveries" = sum(value, na.rm = T)) %>%
    arrange(date)
  if (nrow(data_recovered) > 0) {
    data_recovered <- data_recovered %>%
      mutate(`Estimated Recoveries` = if_else(normalizeByPopulation, round(`Estimated Recoveries` / population * 100000, 2), `Estimated Recoveries`))
  }
  data_recovered <- data_recovered %>% as.data.frame()
  
  data_deceased <- data_evolution_estados %>%
    select(`state`, date, var, value, population) %>%
    filter(`state` %in% countries &
             var == "deceased" &
             value > 0) %>%
    group_by(`state`, date, population) %>%
    summarise("Deceased" = sum(value, na.rm = T)) %>%
    arrange(date)
  if (nrow(data_deceased) > 0) {
    data_deceased <- data_deceased %>%
      mutate(Deceased = if_else(normalizeByPopulation, round(Deceased / population * 100000, 2), Deceased))
  }
  data_deceased <- data_deceased %>% as.data.frame()
  
  return(list(
    "confirmed." = data_confirmed,
    "recovered." = data_recovered,
    "deceased."  = data_deceased
  ))
}

output$case_evolution_byEstados <- renderPlotly({
  data <- getDataByEstados(input$caseEvolution_estados, input$checkbox_per100kEvolutionEstados)
  
  req(nrow(data$confirmed) > 0)
  p <- plot_ly(data = data$confirmed, x = ~date, y = ~Confirmed, color = ~`state`, type = 'scatter', mode = 'lines',
               legendgroup     = ~`state`) %>%
    add_trace(data = data$recovered, x = ~date, y = ~`Estimated Recoveries`, color = ~`state`, line = list(dash = 'dash'),
              legendgroup  = ~`state`, showlegend = FALSE) %>%
    add_trace(data = data$deceased, x = ~date, y = ~Deceased, color = ~`state`, line = list(dash = 'dot'),
              legendgroup  = ~`state`, showlegend = FALSE) %>%
    add_trace(data = data$confirmed[which(data$confirmed$`state` == input$caseEvolution_estados[1]),],
              x            = ~date, y = -100, line = list(color = 'rgb(0, 0, 0)'), legendgroup = 'helper', name = "Confirmed") %>%
    add_trace(data = data$confirmed[which(data$confirmed$`state` == input$caseEvolution_estados[1]),],
              x            = ~date, y = -100, line = list(color = 'rgb(0, 0, 0)', dash = 'dash'), legendgroup = 'helper', name = "Estimated Recoveries") %>%
    add_trace(data = data$confirmed[which(data$confirmed$`state` == input$caseEvolution_estados[1]),],
              x            = ~date, y = -100, line = list(color = 'rgb(0, 0, 0)', dash = 'dot'), legendgroup = 'helper', name = "Deceased") %>%
    layout(
      yaxis = list(title = "Casos", rangemode = "nonnegative"),
      xaxis = list(title = "Data")
    )
  
  if (input$checkbox_logCaseEvolutionEstados) {
    p <- layout(p, yaxis = list(type = "log"))
  }
  if (input$checkbox_per100kEvolutionEstados) {
    p <- layout(p, yaxis = list(title = "Casos por 100k habitantes"))
  }
  
  return(p)
})