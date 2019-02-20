
library(leaflet)
library(shinythemes)
space <- read.csv(file = "space.csv", stringsAsFactors = F)

navbarPage(theme = shinytheme("flatly"), "Astronauts!", collapsible = T, 
  # MAIN TABS
  tabPanel(
    img(src = "http://www.clker.com/cliparts/l/R/b/J/X/D/astronaut-helmet-md.png", height = 25, width = 25),
    mainPanel(
      h4("Welcome to our Shiny app!", align = "center"),
      p("Our app uses a data set from Kaggle about NASA Astronauts from 1959 to present. A link to the data is posted below; this data
        set was last updated about a year ago (c.2017) and unfortunately, is not exhaustive. The data does not include international astronauts
        who were recruited from their countries' respective space agencies. This data set only contains information on U.S. astronauts 
        trained solely by NASA."), 
      p("The data set has many variables including name, birthday, birth place, 
        gender, alma mater, as well as quantitative information on the number of space flights and space walks the astronaut
        has accomplished and the hours for both of those feats."),
      p("We created a map using the birth places of the astronauts, to do 
        this we had to add on to the data set and find the longitude and latitude coordinates for each city in the dataset. Check out the 
        map by clicking on the Map tab."), 
      p("Additionally, we used the quantitative data in the set to create interactive histograms and scatterplots. Click on the Histogram tab
        to see how the flight and walk variables look when colored by gender or status of the astronauts. On the Scatterplot 
        tab, summary statistics and linear regression information is also available."),
      uiOutput("link")
    )
  ),
  tabPanel("Map", 
    h4("Map of All Astronauts in Data Set"),
    h5("Hover over and click on the astronaut helmets for more information! You can also double click to zoom."), 
    leafletOutput("mymap", height = 650, width = 1075)),
  tabPanel("Histogram",
    h4("Choose a variable to make a histogram!"),
    sidebarLayout(
      sidebarPanel(width = 4, 
        selectInput("xvar", "X Variable", choices = c("Number of Space Flights" = "Space.Flights",
                                                      "Number of Space Walks" = "Space.Walks",
                                                      "Hours of Space Walks" = "Space.Walk..hr."), 
                    selected = c("Hours of Space Walks" = "Space.Walk..hr.")),
        selectInput("color", "Color Variable", choices = names(space[c(4, 9)]), selected = names(space[9]))
      ),
      mainPanel(
        plotOutput("hist"),
        p("For summary statistics of your chosen X variable, go to the Scatterplot tab and click Summary Statistics.")),
      position = "left", fluid = T
      )
    ),
  tabPanel("Scatterplot",
    sidebarLayout(
      sidebarPanel(width = 4,
        selectInput("xvar2", "X Variable", choices = c("Number of Space Flights" = "Space.Flights",
                                                       "Hours of Space Flight" = "Space.Flight..hr.",
                                                       "Number of Space Walks" = "Space.Walks",
                                                       "Hours of Space Walks" = "Space.Walk..hr."), 
                    selected = c("Number of Space Flights" = "Space.Flights")),
        selectInput("yvar", "Y Variable", choices = c("Number of Space Flights" = "Space.Flights",
                                                      "Hours of Space Flight" = "Space.Flight..hr.",
                                                      "Number of Space Walks" = "Space.Walks",
                                                      "Hours of Space Walks" = "Space.Walk..hr."), 
                    selected = c("Hours of Space Flight" = "Space.Flight..hr.")) #,
        #selectInput("facet", "Grouping Variable", choices = names(space[c(4, 9)]), selected = names(space[9]))
        #these facets don't work
      ),
      mainPanel(
        # TABS FOR SCATTERPLOT PAGE
        tabsetPanel(
          tabPanel("Plot", h4("Choose variables to create a scatterplot using the dropdown menus on the left."),
            h5("Click on any point for more information!"),
            plotOutput("scatter", click = "scatter_click", width = 710),
            h5("Nearest 3 Astronauts within 5 Pixels:"),
            h6("If one or more rows are coming up with NAs, that means 
               there aren't 3 astronauts within 5 pixels of where you clicked."),
            verbatimTextOutput("info")),
          tabPanel("Summary Statistics", 
            mainPanel(
              h4("Here are the summary statistics for the x and y variables you chose."), 
              h5("The dropdown menus still work if you'd like to see information on other variables."),
              verbatimTextOutput("summary"),
              verbatimTextOutput("summ2")
            )
          ),
          tabPanel("Linear Model",
            mainPanel(
              h4("Test the relationship between the x and y variables you chose."),
              h5("(You can continue to use the dropdown menus.)"),
              tags$b("Linear regression model:"),
              textOutput("linear_mod"),
              p(" "), #this is just for aesthetic purposes
              #WE CAN ALSO STICK A P-VAL FOR THE SLOPE AND THE MODEL AND MAKE IF STATEMENTS TO DISPLAY CERTAIN SENTENCES
              tags$b("Correlation (r) :"),
              textOutput("correlation")
            )
          )
        )
      ),
      position = "left", fluid = T
    )         
  ),
  tabPanel(
    img(src = "https://www.freeiconspng.com/uploads/rocket-ship-png-12.png", height = 33, width = 21),
    mainPanel(
      p("Thanks for visiting our app! We think you're out of this world ;)"),
      img(src = "https://media.giphy.com/media/bDZGZzd7B7Wh2/giphy.gif", width = 800, height = 388)
    )
  )
)
           
