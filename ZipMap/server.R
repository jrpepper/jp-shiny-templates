#SERVER.R

function(input, output, session) {
  
  #set options for filtering based on type(s) of offense
  filteredData <- reactive({
    #this will return the variable data when filteredData() is called anywhere in your code.
    data <- subset(zip.shape, zip.shape@data$value1 > input$value1Filer[1])
    data <- subset(data, data@data$value1 < input$value1Filer[2])
    
    #filter by map location
    if (!input$filterOnMap){
      return(data)
    }else{
      bounds <- input$map_bounds
      latRng <- range(bounds$north, bounds$south)
      lngRng <- range(bounds$east, bounds$west)
      
      data <- subset(data,
                     latitude >= latRng[1] & latitude <= latRng[2] &
                       longitude >= lngRng[1] & longitude <= lngRng[2])
    }
  })
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      setView(-122.4434463, 37.758238, zoom = 5)
  })
  
  #set function for making a color pallete
  zipColor <- colorNumeric("Blues", zip.shape@data$value1)
  
  #update map based on changed inputs
  observe({
    # start spinner    
    session$sendCustomMessage(type = "map_spin", "spin") 
    
      leafletProxy("map", data = filteredData()) %>%
        clearShapes() %>%
        clearControls() %>%
        addPolygons(weight=0, color=~zipColor(value1), fillOpacity=0.7,
                    popup=~paste("<strong>Zip: </strong>",zip,"<br>",
                                 "<strong>Value 1: </strong>",round(value1,2),"<br>",
                                 "<strong>Value 2: </strong>",round(value2,2))) %>%
        addLegend(title = "Zip Code with Value", pal = zipColor, values = ~value1, opacity = 0.9, position="bottomleft")

      # stop spinner    
      session$sendCustomMessage(type = "map_done", "done")
    }
  )
  
  #make histogram by value1
  output$value1Histo <- renderPlot({
    d2 <- filteredData()@data
    print(ggplot(d2, aes(x=value1)) + geom_histogram(colour = "black") +
      theme_minimal())
  })
  
  #make histogram by value2
  output$value2Histo <- renderPlot({
    d2 <- filteredData()@data
    print(ggplot(d2, aes(x=value2)) + geom_histogram(colour = "black") +
            theme_minimal())
  })
  
  #make line chart based on Date
  output$datePlot <- renderPlot({
    
    datevalues <-tapply(filteredData()@data$ZCTA5CE10, filteredData()@data$date, length)
    datevalues <- as.data.frame(datevalues)
    
    datevalues$Date <- as.Date(row.names(datevalues))
    
    print(ggplot( data = datevalues, aes( Date, datevalues )) +
            theme_minimal() +
            #geom_point(alpha=0.2) +
            #geom_line(alpha=0.3, size=.2) +
            geom_bar(stat="identity", alpha=0.3) +
            stat_smooth(size=2) +
            labs(x=NULL, y=NULL, title="Crimes by Date"))
    
  })
  
    
}