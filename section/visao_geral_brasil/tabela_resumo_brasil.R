output$tebela_resumo_brasil <- renderUI({
  tabBox(
    tabPanel("Estados",
             div(
               dataTableOutput("summaryDT_state"),
               style = "margin-top: -10px")
    ),
    tabPanel("Municípios",
             div(
               dataTableOutput("summaryDT_municip"),
               style = "margin-top: -10px"
             )
    ),
    width = 12
  )
})

output$summaryDT_state <- renderDataTable(getSummaryDT_b(data_atdate_estados(current_date_estados), "nome", selectable = TRUE))
proxy_summaryDT_state  <- dataTableProxy("summaryDT_state")
output$summaryDT_municip   <- renderDataTable(getSummaryDT_b(data_atdate_municip(current_date_municip), "cidade", selectable = TRUE))
proxy_summaryDT_municip    <- dataTableProxy("summaryDT_municip")

observeEvent(input$timeSlider_b, {
  data_b <- data_atdate_estados(input$timeSlider_b)
  replaceData(proxy_summaryDT_state, summariseData_b(data_b, "nome"), rownames = FALSE)
}, ignoreInit = TRUE, ignoreNULL = TRUE)

observeEvent(input$summaryDT_state_row_last_clicked, {
  selectedRow_b    <- input$summaryDT_state_row_last_clicked
  selectedstate_b <- summariseData_b(data_atdate_estados(input$timeSlider_b), "nome")[selectedRow, "nome"]
  location_b        <- data_evolution_municip %>%
    distinct(`nome`, lat, long) %>%
    filter(`nome` == selectedstate_b) %>%
    summarise(
      lat  = mean(lat),
      long = mean(long)
    )
  leafletProxy("mapa_brasil") %>%
    setView(lng = location_b$long, lat = location_b$lat, zoom = 4)
})

observeEvent(input$summaryDT_municip_row_last_clicked, {
  selectedRow_b    <- input$summaryDT_municip_row_last_clicked
  selectedmunicip <- summariseData_b(data_atdate_municip(input$timeSlider_b), "cidade")[selectedRow, "cidade"]
  location_bm <- data_evolution_municip %>%
    distinct(`cidade`, lat, long) %>%
    filter(`cidade` == selectedmunicip) %>%
    summarise(
      lat  = mean(lat),
      long = mean(long)
    )
  leafletProxy("mapa_brasil") %>%
    setView(lng = location_bm$long, lat = location_bm$lat, zoom = 4)
})
###############para manter os dois dois ados tenho q tirar duas variaveis p ficarem iguais.... e nC#o dar erro
summariseData_b <- function(df, groupBy) {
  df %>%
    group_by(!!sym(groupBy)) %>%
    summarise(
      "Total de casos Confirmados"            = sum(confirmed, na.rm = T),
      # "Total estimado de Recuperados" = sum(recovered, na.rm = T),
      "Total de obitos"             = sum(deceased, na.rm = T)####,
      # "Casos ativos"               = sum(active, na.rm = T)
    ) %>%
    as.data.frame()
}

getSummaryDT_b <- function(data, groupBy, selectable = FALSE) {
  datatable(
    na.omit(summariseData_b(data, groupBy)),
    rownames  = FALSE,
    options   = list(
      order          = list(1, "desc"),
      scrollX        = TRUE,
      scrollY        = "37vh",
      scrollCollapse = T,
      dom            = 'ft',
      paging         = FALSE
    ),
    selection = ifelse(selectable, "single", "none")
  )
} 