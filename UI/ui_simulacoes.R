body_sim <- dashboardBody(
  fluidPage(
    fluidRow(
   img(src='working_on_it.gif', style = "display: block; margin-left: auto; margin-right: auto;")
    )
   ,
  )
)
    
    

page_sim <- dashboardPage(
  title   = "Simulações",
  header  = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body    = body_sim
) 



