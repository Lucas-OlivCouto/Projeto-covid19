sumData_b <- function(date) {
  if (date >= min(data_evolution_estados$date)) {
    data_b <- data_atdate_estados(date) %>% summarise(
      confirmed = sum(confirmed, na.rm = T),
      recovered = sum(recovered, na.rm = T),
      deceased  = sum(deceased, na.rm = T),
      state = n_distinct(`state`)
    )
    return(data_b)
  }
  return(NULL)
}

figuras_brasil <- reactive({
  data_           <- sumData_b(input$timeSlider_b)
  data_yesterday_b <- sumData_b(input$timeSlider_b - 1)
  
  data_new_b <- list(
    new_confirmed = (data_$confirmed - data_yesterday_b$confirmed) / data_yesterday_b$confirmed * 100,
    new_recovered = (data_$recovered - data_yesterday_b$recovered) / data_yesterday_b$recovered * 100,
    new_deceased  = (data_$deceased - data_yesterday_b$deceased) / data_yesterday_b$deceased * 100,
    new_state = data_$state - data_yesterday_b$state
  )
  
  figuras_brasil <- list(
    "confirmed" = HTML(paste(format(data_$confirmed, big.mark = " "), sprintf("<h4>(%+.1f %%)</h4>", data_new_b$new_confirmed))),
    "recovered" = HTML(paste(format(data_$recovered, big.mark = " "), sprintf("<h4>(%+.1f %%)</h4>", data_new_b$new_recovered))),
    "deceased"  = HTML(paste(format(data_$deceased, big.mark = " "), sprintf("<h4>(%+.1f %%)</h4>", data_new_b$new_deceased))),
    "state" = HTML(paste(format(data_$state, big.mark = " "), "/ 27", sprintf("<h4>(%+d)</h4>", data_new_b$new_state)))
  )
  return(figuras_brasil)
})

output$valueBox_confirmed_b <- renderValueBox({
  valueBox(
    figuras_brasil()$confirmed,
    subtitle = "Casos confirmados",
    icon     = icon("file-medical"),
    color    = "yellow",
    width    = NULL
  )
})


output$valueBox_recovered_b <- renderValueBox({
  valueBox(
    figuras_brasil()$recovered,
    subtitle = "Estimativa de recuperados",
    icon     = icon("heart"),
    color    = "yellow"
  )
})

output$valueBox_deceased_b <- renderValueBox({
  valueBox(
    figuras_brasil()$deceased,
    subtitle = "óbitos",
    icon     = icon("heartbeat"),
    color    = "yellow"
  )
})

output$valueBox_state_b <- renderValueBox({
  valueBox(
    figuras_brasil()$state,
    subtitle = "Estados afetados (+DF)",
    icon     = icon("flag"),
    color    = "yellow"
  )
})

output$box_figuras_brasil <- renderUI(box(
  title = paste0("Resumo de (", strftime(input$timeSlider_b, format = "%d.%m.%Y"), ")"),
  fluidRow(
    column(
      valueBoxOutput("valueBox_confirmed_b", width = 3),
      valueBoxOutput("valueBox_recovered_b", width = 3),
      valueBoxOutput("valueBox_deceased_b", width = 3),
      valueBoxOutput("valueBox_state_b", width = 3),
      width = 12,
      style = "margin-left: -20px"
    )
   ),
  # div("Atualizado em: ", strftime(changed_date_estados, format = "%d.%m.%Y - %R %Z")),
   width = 12
))


