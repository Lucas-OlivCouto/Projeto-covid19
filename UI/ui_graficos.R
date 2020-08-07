body <- dashboardBody(
  fluidRow(
          box(
          title = "Evolução global dos casos desde o surto",
          plotlyOutput("case_evolution"),
          column(
            checkboxInput("checkbox_logCaseEvolution", label = "Eixo Y logaritmico", value = FALSE),
            width = 3,
            style = "float: right; padding: 10px; margin-right: 50px"
          ),
          width = 6
        ),
        box(
          title = "Evolução nacional dos casos desde o surto",
          plotlyOutput("case_evol_estados"),
          column(
            checkboxInput("checkbox_logCaseEvolution_estados", label = "Eixo Y logaritmico", value = FALSE),
            width = 3,
            style = "float: right; padding: 10px; margin-right: 50px"
          ),
          width = 6
          )
         ),
        
      fluidRow(
        box(
          title = "Casos por País",
          plotlyOutput("case_evolution_byCountry"),
          fluidRow(
            column(
              uiOutput("selectize_casesByCountries"),
              width = 3,
            ),
            column(
              checkboxInput("checkbox_logCaseEvolutionCountry", label = "Eixo Y logaritmico", value = FALSE),
              checkboxInput("checkbox_per100kEvolutionCountry", label = "Por População", value = FALSE),
              width = 3,
              style = "float: right; padding: 10px; margin-right: 50px"
            )
          ),
          width = 6
        ),
        box(
          title = "Casos por Estado",
          plotlyOutput("case_evolution_byEstados"),
          fluidRow(
            column(
              uiOutput("selectize_casesByEstados"),
              width = 3,
            ),
            column(
              checkboxInput("checkbox_logCaseEvolutionEstados", label = "Eixo Y logaritmico", value = FALSE),
              checkboxInput("checkbox_per100kEvolutionEstados", label = "Por População", value = FALSE),
              width = 3,
              style = "float: right; padding: 10px; margin-right: 50px"
            )
          ),
          width = 6
        )
      ),
        
  fluidRow(
    box(
      title = "Novos casos",
      plotlyOutput("case_evol_estados_new"),
      column(
        uiOutput("selectize_casesByEstados_new"),
        width = 3,
      ),
      column(
        HTML("Nota: O calculo dos casos ativos é feito da seguinte forma: <i> número de casos confirmados - (número de óbitos + numero de recuperados) </i>. Portanto, os </i> casos ativos podem apresentar valores negativos em alguns dias. Sempre que no dia em questão o número de recuperados + o número de óbitos for maior que número de casos confirmados."),
        width = 7
      ),
      width = 6
    ),
  
  box(
          title = "Evolução dos casos desde o 10° / 100° desfecho",
          plotlyOutput("graf_evol_casos_apos_ncasos"),
          fluidRow(
            column(
              uiOutput("selectize_casesByEstadosAfter100th"),
              width = 3,
            ),
            column(
              uiOutput("selectize_casesSinceNth"),
              width = 3
            ),
            column(
              checkboxInput("checkbox_logCaseEvolution100thEstados", label = "Eixo Y logaritmico", value = FALSE),
              checkboxInput("checkbox_per100kEvolutionEstados100th", label = "Por População", value = FALSE),
              width = 3,
              style = "float: right; padding: 10px; margin-right: 50px"
            )
          ),
          width = 6
        )
  ),
      
        fluidRow(
        box(
          title = "Evolucao do tempo de duplicação por Estado",
          plotlyOutput("graf_temp_duplic"),
            column(
              uiOutput("selectize_doublingTime_estados"),
              width = 3,
            ),
            column(
              uiOutput("selectize_doublingTime_Variable_estados"),
              width = 3,
            ),
            column(width = 3),
            column(
              div("Nota: O tempo de duplicação é calculado com base na taxa de crescimento nos ultimos sete dias.",
                  style = "padding-top: 15px;"),
              width = 3
            )
          )
        )
      )
        
page_graficos <- dashboardPage(
  title   = "graficos",
  header  = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body    = body
) 