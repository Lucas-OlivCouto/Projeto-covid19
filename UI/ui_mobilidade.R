body_mob <- dashboardBody(
  fluidPage(
    headerPanel("Reporte de mobilidade para o brasil"),
    fluidRow(
      column(3,
             selectInput("provinceInput", h4("Selecione um estado:"), 
                         choices = province_choices,
                         selected = "todos os estados"),
             dateRangeInput("dateInput", h4("Selecione uma data:"),
                            start = min(df$date), 
                            end = max(df$date),
                            min = min(df$date), 
                            max = max(df$date), 
                            startview = "week",
                            language = "PT",
                            separator = " a "),
             actionButton(inputId = "resetInput", 
                          label = "Reestabelecer as datas", 
                          icon = icon("undo")),
             br(),
             br(),
             h4("Sobre os dados:"),
             HTML("<p> Os dados são do Google (veja a fonte abaixo) e
            mostre como as visitas e a duração delas variam em lugares diferentes em comparação
            com uma linha de base. <p>"),
             HTML("<p> As alterações para cada dia são comparadas a uma linha de base para o mesmo dia da semana:
            o valor base é a mediana, para o dia da semana correspondente, durante um período de 5
            semanas que foi de 3 de janeiro a 6 de fevereiro de 2020. <p> "),
             br(),
             h4("Fonte:"),
             em("Google LLC 'Google COVID-19 Community Mobility Reports'"),
             HTML("<a href=https://www.google.com/covid19/mobility/> https://www.google.com/covid19/mobility/ </a>"),
             paste("Consultado:", as.character(Sys.Date()))
      ),
      
      column(9,
             plotlyOutput("provincePlot"),
             br(),
             h4("Detalles de cada serie:"),
             HTML("<p> <b> grocery_and_pharmacy</b>: lugares como mercados, armazéns, feiras e farmácias. <p>"),
             HTML("<p> <b> parks</b>: lugares como parques, parques nacionais, praias, cais, praças e jardins públicos. <p>"),
             HTML("<p> <b> residential</b>: áreas residenciais. <p>"),
             HTML("<p> <b> retail_and_recreation</b>: lugares como restaurantes, cafés, lojas, parques temáticos, museus, bibliotecas e cinemas. <p>"),
             HTML("<p> <b> transit_stations</b>: locais de transporte público, como estações de metrô, ônibus e trens. <p>"),
             HTML("<p> <b> workplaces</b>: locais de trabalho. <p>")
             
      )
    )
  )
)

page_mob <- dashboardPage(
  title   = "mobilidade",
  header  = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body    = body_mob
) 