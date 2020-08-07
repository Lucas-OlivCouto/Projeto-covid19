output$selectize_casesByEstados <- renderUI({
  selectizeInput(
    "caseEvolution_estados",
    label    = "Selecione os Estados",
    choices  = unique(data_evolution_estados$state),
    selected = top5_estados,
    multiple = TRUE
  )
})

output$case_evol_estados <- renderPlotly({
  data <- data_evolution_estados %>%
    group_by(date, var) %>%
    summarise(
      "value" = sum(value, na.rm = T)
    ) %>%
    as.data.frame()
  
  p <- plot_ly(
    data,
    x     = ~date,
    y     = ~value,
    name  = sapply(data$var, capFirst),
    color = ~var,
    type  = 'scatter',
    mode  = 'lines') %>%
    layout(
      yaxis = list(title = "Casos"),
      xaxis = list(title = "Data")
    )
  
  
  if (input$checkbox_logCaseEvolution_estados) {
    p <- layout(p, yaxis = list(type = "log"))
  }
  
  return(p)
})
