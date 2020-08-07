body_sobre <- dashboardBody(
  fluidRow(
    fluidRow(
      column(
        box(
          title = div("Sobre o Projeto", style = "padding-left: 20px", class = "h2"),
          column(
            h3(" Painel COVID-19"),
            "Este painel coleta dados recentes sobre a situação da pandemia do corona vírus em nível nacional e global. 
            Os dados são coletados de diferentes fontes e compilados de forma contínua e dinâmica. 
            A informação mínima apresentada neste painel é do número acumulado de casos e de mortalidade em decorrência do sars-cov2, porém não se limita a isso.  
            A complexidade das informações depende da fonte que as informa.",
            tags$br(),
            
            h3("Recomendação das autoridades sanitárias"),
            "Siga sempre as recomendações sanitárias emitidas pelas autoridades responsáveis.
             Acesse o portal COVID-19 do", tags$a(href = "https://coronavirus.saude.gov.br", "Ministério da Saúde"), 
            "para manter-se informado", tags$a(href = "https://coronavirus.saude.gov.br/index.php/sobre-a-doenca", " sobre a doença"),
            ", saber as principais", tags$a(href = "https://www.saude.gov.br/component/tags/tag/novo-coronavirus-fake-news", " fake news"), "relacionadas ao COVID-19
            e quais são as mais recentes" , tags$a(href = "https://coronavirus.saude.gov.br/index.php/profissional-gestor","evidências científicas"), "sobre a pandemia",
            tags$br(),
            h3("Dados apresentados"),
            "Os dados globais são provenientes do repositório público disponibilizado pela", 
            tags$a(href="https://systems.jhu.edu/research/public-health/ncov/", "John Hopkins whiting school of engineering"), "- center for systems science and engineering.
            Os",tags$a(href="https://preprints.scielo.org/index.php/scielo/preprint/view/362/444", "dados nacionais"), "são provenientes das secretarias Estaduais e Municipais de saúde do Brasil através de seus repositórios públicos disponibilizados on-line",
            tags$br(),
            
            h3("Equipe"),
            h4("Dr.a Karen dos Santos Gonçalves."),
              "Doutora em Saúde Pública pela Escola Nacional de Saúde Pública Sergio Arouca (ENSP/FIOCRUZ) com período sanduíche no Swiss Tropical and Public Health Institute (Swiss TPH), University of Basel, Suíça (2016).
              Mestre em Saúde Pública e Meio Ambiente (ENSP - FIOCRUZ) (2010). 
              Graduada em Enfermagem pela Universidade Federal do Estado do Rio de Janeiro (UNIRIO) (2007).",
            tags$br(),
            tags$a(href = "http://lattes.cnpq.br/9281934708403879", "Currículo Lattes"),
            
            h4("Lucas de Oliveira do Couto."),
            "Mestre em Saúde Pública e Meio Ambiente pela Escola Nacional de Saúde Pública Sergio Arouca (ENSP/FIOCRUZ) (2019).
            Especialista em Gerenciamento de Projetos pela Universidade Católica de Petrópolis (2017).
            Graduado em Ciências Biológicas pela Universidade Estadual do Norte Fluminense Darcy Ribeiro (2016) e em Gestão Ambiental pela Universidade Metodista de São Paulo (2014).",
            tags$br(),
            tags$a(href = "http://lattes.cnpq.br/1219066399364287", "Currículo Lattes"),
            
            h4("Luiza Toledo de Oliveira Figueira."),
            "Mestre em Saúde Publica e Meio Ambiente pela Escola Nacional de Saúde Pública Sergio Arouca (ENSP/FIOCRUZ) (2019).
            Graduada em Ciências Biológicas: Microbiologia e Imunologia pela Universidade Federal do Rio de Janeiro (2016).
            Tem experiência na área de Microbiologia, com ênfase em microbiologia ambiental,doenças infecciosas e mudanças climáticas e seus impactos.
            Co-fundadora do site de divulgação científica ", tags$a(href = "http://www.cienciaexplica.com.br/","A Ciência Explica"),". Atua em projetos de divulgação científica.",
            tags$br(),
            tags$a(href = " http://lattes.cnpq.br/8541982161678237"),
            
            h4("Dr.a Sandra de Souza Hacon."),
            "Doutora em Geociências (Geoquímica Ambiental) pela Universidade Federal Fluminense (1996).
            Mestre em Controle da Poluição Ambiental - Mancherter University, Reino Unido (1981).
            Graduada em Ciências Biológicas pela Universidade Federal do Rio de Janeiro (1974).",
            tags$br(),
            tags$a(href = "http://lattes.cnpq.br/7653379361147439", "Currículo Lattes"),
            
            width = 12
          ),
          width = 12,
        ),
        width = 12,
        style = "padding: 15px"
      )
    )
  )
)


page_sobre <- dashboardPage(
  title = "sobre",
  header = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body = body_sobre
)

