fluidPage(
  tags$head(
    includeScript("spin.min.js")
  ),
  navbarPage("NYC Map", id="nav",
             tabPanel("Map", icon = icon("map-marker"),
                      div(class="outer",
                          tags$style(type = "text/css",
                                     ".outer {position: fixed; top: 50px; left: 0; right: 0;
                                     bottom: 0; overflow: hidden; padding: 0}"),
                          leafletOutput("map", width="100%", height="100%"),
                          
                          #this code adds a spinny thing when your map is loading
                          tags$script("Shiny.addCustomMessageHandler('map_spin',
                                      function(s) {
                                      var spinner = new Spinner().spin();
                                      $( 'div#map' ).append(spinner.el);
                                      });"),
                          
                          absolutePanel(top = 30, right = 30, draggable=TRUE,
                                        wellPanel(style = "background-color: #ffffff; width: 350px",
                                                  tabsetPanel(
                                                    tabPanel("Controls", 
                                                             br(),
                                                             sliderInput('value1Filer', 'Filter by Value1:',
                                                                         min = min(zip.shape@data$value1) %>% round(),
                                                                         max = max(zip.shape@data$value1) %>% round(),
                                                                         value = c(min(zip.shape@data$value1) %>% round(), max(zip.shape@data$value1) %>% round()),
                                                                         dragRange = FALSE),
                                                             checkboxInput('filterOnMap', 'Filter results with map map/zoom?')
                                                    ),
                                                    tabPanel("Graphs",
                                                             plotOutput("value1Histo", height="200px"),
                                                             plotOutput("datePlot", height="200px")
                                                    )
                                                  )
                                        )
                          )
                          )
  ),
  tabPanel("About",
           icon = icon("question"),
           
           #content on left hand side of the page
           h1("About"),
           br(),
           p("This tool was created by Josh Pepper, a medical student and public health researcher at the UCSF-UC Berkeley Joint Medical Program."),
           br(),
           span("You can reach him at jrpepper@gmail.com or on his website at"),a("http://www.jrpepperconsulting.com", href="http://www.jrpepperconsulting.com", target="_blank")
  ),
  tags$script("Shiny.addCustomMessageHandler('map_done',
              function(s) {
              $('.spinner').remove();
              });")
  )
  )