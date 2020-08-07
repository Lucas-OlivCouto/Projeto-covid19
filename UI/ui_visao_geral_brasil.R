body_visao_geral_brasil <- dashboardBody(
  tags$head(
    tags$style(type = "text/css", "#mapa_brasil {height: 50vh !important;}"),
    tags$style(type = 'text/css', ".slider-animate-button_ { font-size: 20pt !important; }"),
    tags$style(type = 'text/css', ".slider-animate-container_ { text-align: left !important; }"),
    tags$style(type = "text/css", "@media (max-width: 991px)_ { .details_ { display: flex; flex-direction: column; } }"),
    tags$style(type = "text/css", "@media (max-width: 991px)_ { .details .map_ { order: 1; width: 100%; } }"),
    tags$style(type = "text/css", "@media (max-width: 991px)_ { .details .summary_ { order: 3; width: 100%; } }"),
    tags$style(type = "text/css", "@media (max-width: 991px)_ { .details .slider_ { order: 2; width: 100%; } }")
  ),
  fluidRow(
    fluidRow(
    uiOutput("box_figuras_brasil")
  ),
  fluidRow(
    class = "details_",
    column(
      box(
        width = 12,
        leafletOutput("mapa_brasil")
      ),
      class = "map_",
      width = 7,
      style = 'padding:0px;'
    ),
    column(
      uiOutput("tebela_resumo_brasil"),
      class = "summary_",
      width = 5,
      style = 'padding:0px;'
    ),
      column(
        sliderInput(
          "timeSlider_b",
          label      = "Selecione uma data",
          min        = min(data_evolution_estados$date),
          max        = max(data_evolution_estados$date),
          value      = max(data_evolution_estados$date),
          width      = "100%",
          timeFormat = "%d.%m.%Y",
          animate    = animationOptions(loop = TRUE)
        ),
        class = "slider",
        width = 12,
        style = 'padding-left:15px; padding-right:15px;'
      )
    )
  )
)
 

page_visao_geral_brasil <- dashboardPage(
  title   = "visao_geral_brasil",
  header  = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body    = body_visao_geral_brasil
)