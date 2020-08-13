source("UI/ui_overview.R", local = TRUE)
source("UI/ui_visao_geral_brasil.R", local = TRUE)
source("UI/ui_graficos.R", local = TRUE)
source("UI/ui_mobilidade.R", local = TRUE)
source("UI/ui_simulacoes.R", local = TRUE)
source("UI/ui_sobre.R", local = TRUE)
source("UI/ui_Link_uteis.R", local = TRUE)
source("UI/ui_tabelafull.R", local = TRUE)

ui <- fluidPage(
  title = "Painel COVID-19",
  tags$style(type = "text/css", ".container-fluid {padding-left: 0px; padding-right: 0px !important;}"),
  tags$style(type = "text/css", ".navbar {margin-bottom: 0px;}"),
  tags$style(type = "text/css", ".content {padding: 0px;}"),
  tags$style(type = "text/css", ".row {margin-left: 0px; margin-right: 0px;}"),
  tags$style(HTML(".col-sm-12 { padding: 5px; margin-bottom: -15px; }")),
  tags$style(HTML(".col-sm-6 { padding: 5px; margin-bottom: -15px; }")),
  navbarPage(
    title       = div("Painel COVID-19 Brasil", style = "padding-left: 10px"),
    inverse = TRUE,
    collapsible = TRUE,
    fluid       = TRUE,
    tabPanel("Visão geral países", page_overview, value = "page-overview"),
    tabPanel("Visão geral Brasil", page_visao_geral_brasil, value = "page_visao_geral_brasil"),
    tabPanel("Tabela", page_tabelafull, value = "page_tabelafull"),
    tabPanel("Gráficos", page_graficos, value = "page_graficos"),
    tabPanel("Dados de mobilidade", page_mob, value = "page_mob"),
    tabPanel("Simulações", page_sim, value = "page_sim"),
    tabPanel("Sobre", page_sobre, value = "page_sobre"),
    tabPanel("Links úteis", page_linkuteis, value = "page_linkuteis")
  )
)
