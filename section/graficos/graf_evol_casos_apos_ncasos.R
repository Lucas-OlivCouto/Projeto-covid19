output$selectize_casesByEstadosAfter100th <- renderUI({
  selectizeInput(
    "caseEvolution_EstadosAfter100th",
    label    = "Selecione os Estados",
    choices  = unique(data_evolution_estados$`state`),
    selected = top5_estados,
    multiple = TRUE
  )
})

output$selectize_casesSinceNth <- renderUI({
  selectizeInput(
    "case_evolution_after_n_estados_var",
    label    = "Selecione a variável",
    choices  = list("Casos Confirmados" = "confirmed", "óbitos" = "deceased"),
    multiple = FALSE
  )
})

output$graf_evol_casos_apos_ncasos <- renderPlotly({
  req(!is.null(input$checkbox_per100kEvolutionEstados100th), input$case_evolution_after_n_estados_var)
  data <- data_evolution_estados %>%
    arrange(date) %>%
    filter(if (input$case_evolution_after_n_estados_var == "confirmed") (value >= 100 & var == "confirmed") else (value >= 10 & var == "deceased")) %>%
    group_by(`state`, population, date) %>%
    filter(if (is.null(input$caseEvolution_EstadosAfter100th)) TRUE else `state` %in% input$caseEvolution_EstadosAfter100th) %>%
    summarise(value = sum(value, na.rm = T)) %>%
    mutate("daysSince" = row_number()) %>%
    ungroup()
  
  if (input$checkbox_per100kEvolutionEstados100th) {
    data$value <- data$value / data$population * 100000
  }
  
  p <- plot_ly(data = data, x = ~daysSince, y = ~value, color = ~`state`, type = 'scatter', mode = 'lines')
  
  if (input$case_evolution_after_n_estados_var == "confirmed") {
    p <- layout(p,
                yaxis = list(title = "Casos Confirmados"),
                xaxis = list(title = "Dias desde o 100° caso confirmado")
    )
  } else {
    p <- layout(p,
                yaxis = list(title = "Obitos"),
                xaxis = list(title = "Dias desde o 10° óbito confirmado")
    )
  }
  if (input$checkbox_logCaseEvolution100thEstados) {
    p <- layout(p, yaxis = list(type = "log"))
  }
  if (input$checkbox_per100kEvolutionEstados100th) {
    p <- layout(p, yaxis = list(title = "# Casos por 100k habitantes"))
  }
  
  return(p)
})
