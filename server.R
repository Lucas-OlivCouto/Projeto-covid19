server <- function(input, output, session) {
  sourceDirectory("section", recursive = TRUE)
   
  
  # Trigger once an hour
  dataLoadingTrigger <- reactiveTimer(3600000)
  
  observeEvent(dataLoadingTrigger, {
    updatedata_brasil()
    updatedata_global()
  })
  
  observe({
    data_brasil <- data_atdate_estados(input$timeSlider_b)
    data_paises <- data_atDate(input$timeSlider)
  })
}

