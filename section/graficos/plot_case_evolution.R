output$selectize_casesByCountries <- renderUI({
  selectizeInput(
    "caseEvolution_country",
    label    = "Selecione o País",
    choices  = unique(data_evolution$`Country/Region`),
    selected = top5_paises,
    multiple = TRUE
  )
})

output$case_evolution <- renderPlotly({
  data <- data_evolution %>%
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


  if (input$checkbox_logCaseEvolution) {
    p <- layout(p, yaxis = list(type = "log"))
  }

  return(p)
})
