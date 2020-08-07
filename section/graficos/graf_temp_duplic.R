output$selectize_doublingTime_estados <- renderUI({
  selectizeInput(
    "selectize_doublingTime_estados",
    label    = "selecione os Estados",
    choices  = unique(data_evolution_estados$`state`),
    selected = `top5_estados`,
    multiple = TRUE
  )
})

output$selectize_doublingTime_Variable_estados <- renderUI({
  selectizeInput(
    "selectize_doublingTime_Variable_estados",
    label    = "Selecione a Variável",
    choices  = list("Caso confirmado" = "doublingTimeConfirmed", "Obito" = "doublingTimeDeceased"),
    multiple = FALSE
  )
})

output$graf_temp_duplic <- renderPlotly({
  req(input$selectize_doublingTime_estados, input$selectize_doublingTime_Variable_estados)
  daysGrowthRate <- 7
  data           <- data_evolution_estados %>%
    pivot_wider(id_cols = c( date,`state`,newDeaths, newCases,  lat, long), names_from = var, values_from = value) %>%
    filter(if (input$selectize_doublingTime_Variable_estados == "doublingTimeConfirmed") (confirmed >= 100) else (deceased >= 10)) %>%
    filter(if (is.null(input$selectize_doublingTime_estados)) TRUE else `state` %in% input$selectize_doublingTime_estados) %>%
    group_by(`state`, date) %>%
    select(-recovered, -active) %>%
    summarise(
      confirmed = sum(confirmed, na.rm = T),
      deceased  = sum(deceased, na.rm = T)
    ) %>%
    arrange(date) %>%
    mutate(
      doublingTimeConfirmed = round(log(2) / log(1 + (((confirmed - lag(confirmed, daysGrowthRate)) / lag(confirmed, daysGrowthRate)) / daysGrowthRate)), 1),
      doublingTimeDeceased  = round(log(2) / log(1 + (((deceased - lag(deceased, daysGrowthRate)) / lag(deceased, daysGrowthRate)) / daysGrowthRate)), 1)) %>%
    mutate("daysSince" = row_number()) %>%
    filter(!is.na(doublingTimeConfirmed) | !is.na(doublingTimeDeceased))
  
  p <- plot_ly(data = data, x = ~daysSince, y = data[[input$selectize_doublingTime_Variable_estados]], color = ~`state`, type = 'scatter', mode = 'lines')
  
  if (input$selectize_doublingTime_Variable_estados == "doublingTimeConfirmed") {
    p <- layout(p,
                yaxis = list(title = "Tempo de duplição de casos confirmados - em dias"),
                xaxis = list(title = "Dias desde o 100° Caso Confirmado")
    )
  } else {
    p <- layout(p,
                yaxis = list(title = "Tempo de duplicao de óbitos - em dias"),
                xaxis = list(title = "Dias desde o 10° óbito")
    )
  }
  
  return(p)
})
