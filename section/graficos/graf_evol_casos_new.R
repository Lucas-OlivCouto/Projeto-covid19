##TRab
output$selectize_casesByEstados_new <- renderUI({
  selectizeInput(
    "selectize_casesByEstados_new",
    label    = "Selecione os Estados",
    choices  = c("All", unique(data_evolution_estados$`state`)),
    selected = "All"
  )
})

output$case_evol_estados_new <- renderPlotly({
  req(input$selectize_casesByEstados_new)
  data <- data_evolution_estados %>%
    mutate(var = sapply(var, capFirst)) %>%
    filter(if (input$selectize_casesByEstados_new == "All") TRUE else `state` %in% input$selectize_casesByEstados_new) %>%
    group_by(date, var, `state`) %>%
    summarise(new_cases = sum(value_new, na.rm = T))
  
  if (input$selectize_casesByEstados_new == "All") {
    data <- data %>%
      group_by(date, var) %>%
      summarise(new_cases = sum(new_cases, na.rm = T))
  }
  
  p <- plot_ly(data = data, x = ~date, y = ~new_cases, color = ~var, type = 'bar') %>%
    layout(
      yaxis = list(title = "Novos casos"),
      xaxis = list(title = "Data")
    )
})