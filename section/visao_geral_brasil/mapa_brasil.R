library("htmltools")

addLabel_b <- function(data_evolution_estados) {
  data_evolution_estados$label <- paste0(
    '<b>', data_evolution_estados$state, '</b><br>
    <table style="width:120px;">
    <tr><td>confirmados:</td><td align="right">', data_evolution_estados$confirmed, '</td></tr>
    <tr><td>recuperados:</td><td align="right">', data_evolution_estados$recovered, '</td></tr>
    <tr><td>obitos:</td><td align="right">', data_evolution_estados$deceased, '</td></tr>
    <tr><td>ativos:</td><td align="right">', data_evolution_estados$active, '</td></tr>
    </table>'
  )
  data_evolution_estados$label <- lapply(data_evolution_estados$label, HTML)
  
  return(data_evolution_estados)
}

map_brasil <- leaflet(addLabel_b(data_latest_estados)) %>%
  setView(-47.86, -15.83, zoom = 3) %>%
  addTiles() %>%
  addProviderTiles(providers$CartoDB.Positron, group = "Light") %>%
  addProviderTiles(providers$HERE.satelliteDay, group = "Satellite") %>%
  addLayersControl(
    baseGroups    = c("Light", "Satellite"),
    overlayGroups = c("confirmados", "recuperados", "óbitos", "ativos")
  ) %>%
  
  hideGroup("recuperados") %>%
  hideGroup("óbitos") %>%
  hideGroup("ativos") %>%
  
  addEasyButton(easyButton(
    icon    = "glyphicon glyphicon-globe", title = "Resetar zoom",
    onClick = JS("function(btn, map_brasil){ map_brasil.setView([20, 0], 2); }"))) %>%
  addEasyButton(easyButton(
    icon    = "glyphicon glyphicon-map_brasil-marker", title = "Locate Me",
    onClick = JS("function(btn, map_brasil){ map_brasil.locate({setView: true, maxZoom: 6}); }")))

observe({
  req(input$timeSlider_b, input$mapa_brasil_zoom)
  zoomLevel_b               <- input$mapa_brasil_zoom
  data_evolution_estados   <- data_atdate_estados(input$timeSlider_b) %>% addLabel_b()
  
  
  leafletProxy("mapa_brasil", data = data_evolution_estados) %>%
    clearMarkers() %>%
    addCircleMarkers(
      lng          = ~long,
      lat          = ~lat,
      radius       = ~log(confirmed^(zoomLevel_b / 2)),
      stroke       = FALSE,
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "confirmados"
    ) %>%
    addCircleMarkers(
      lng          = ~long,
      lat          = ~lat,
      radius       = ~log(recovered^(zoomLevel_b)),
      stroke       = FALSE,
      color        = "#00b3ff",
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group = "recuperados"
    ) %>%
    addCircleMarkers(
      lng          = ~long,
      lat          = ~lat,
      radius       = ~log(deceased^(zoomLevel_b)),
      stroke       = FALSE,
      color        = "#E7590B",
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "óbitos"
    ) %>%
    addCircleMarkers(
      lng          = ~long,
      lat          = ~lat,
      radius       = ~log(active^(zoomLevel_b / 2)),
      stroke       = FALSE,
      color        = "#f49e19",
      fillOpacity  = 0.5,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "ativos"
    )
})

output$mapa_brasil <- renderLeaflet(map_brasil)


