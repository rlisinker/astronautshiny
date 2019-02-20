library(shiny)
library(leaflet)
library(ggplot2)
library(giphyr)

space <- read.csv(file = "space.csv", stringsAsFactors = F)

function(input, output) {
  link <- a("NASA Astronauts, 1959-present", href = "https://www.kaggle.com/aongao/nasa-astronauts-1959-present/data")
  output$link <- renderUI({
    tagList("Link to dataset: ", link)
  })
  helmet_icon <- makeIcon(iconUrl = "http://www.clker.com/cliparts/l/R/b/J/X/D/astronaut-helmet-md.png", 
    iconWidth = 15, iconHeight = 15)
# MAP
  output$mymap <- renderLeaflet({
    leaflet(data = space) %>% addTiles() %>% 
      addMarkers(lng = jitter(space$Longitude, factor = 2), lat = jitter(space$Latitude, 
        factor = 2), icon = helmet_icon, popup = paste(space$Name, "<br>", "Birth Place: ", 
        space$Birth.Place, "<br>", "Birthday: ", space$Birth.Date, "<br>", "Gender: ", 
        space$Gender, "<br>", "Status: ", space$Status), label = paste(space$Name)) 
  })
  
# HISTOGRAM  
  output$hist <- renderPlot(
    ggplot(subset(space, eval(parse(text = input$xvar)) > 0,
          select = c(eval(parse(text = input$color)), eval(parse(text = input$xvar)))),
          aes(x=eval(parse(text=input$xvar)),  
          stat = "count", color = eval(parse(text = input$color)), fill = eval(parse(text = input$color)))) + 
      geom_histogram(alpha=.45, bins = 10) + geom_density() + xlab(input$xvar) + 
      labs(color = input$color, fill = input$color) + xlim(c(0, max(space[input$xvar])))
  )

# SCATTERPLOT  
  output$scatter <- renderPlot(
    ggplot(data = space, aes(x = eval(parse(text = input$xvar2)), y = eval(parse(text = input$yvar)))) +
      geom_point(size = 1.5) + #facet_grid(.~eval(parse(text = input$facet))) +
      xlab(input$xvar2) + ylab(input$yvar) +
      scale_x_discrete(drop = F) #+ geom_smooth(method = "lm") cool but not necessary
  )

# click information
  output$info <- renderPrint({
    # something is still wrong because i had to take out the facet option in the scatterplot
    # if i leave it in, it only registers for left most panel
    rows <- nearPoints(space, input$scatter_click, xvar = input$xvar2, yvar = input$yvar, 
                       #panelvar1 = input$facet, 
                       threshold = 5, maxpoints = 3, allRows = T, addDist = T)
    distances <- rows$dist_
    indices <- which(distances < 5)
    first_subset <- rows[indices, c(1, 15:18, 22)]
    second_sub <- first_subset[order(first_subset$dist_),]
    second_sub[1:3, c("Name", input$xvar2, input$yvar)]
  })
  
  # can we make them not as wide and on the same line as each other?
  output$summary <- renderPrint({
    summary(space[input$xvar2])
  })
  output$summ2 <- renderPrint({
    summary(space[input$yvar])
  })
  
  output$correlation <- renderText({
    cor(space[input$xvar2], space[input$yvar])[1,1]
  })
  
  output$linear_mod <- renderText({
    lin_mod <- lm(eval(parse(text = input$yvar)) ~ eval(parse(text = input$xvar2)), data = space)
    lm_summ <- summary(lin_mod) #make model summary an object
    lm_coeffs <- lm_summ$coefficients #model coefficients
    slope_est <- lm_coeffs[2, "Estimate"] #slope estimate
    y_int <- lm_coeffs["(Intercept)", "Estimate"] #intercept estimate
    paste(input$yvar, " = ", y_int, " + ", "(", slope_est, "*", input$xvar2, ")", sep = "")
    
    #will need to make these bois in a separate output statement 
    # std_error <- lm_coeffs[2, "Std.Error"] #standard eror of xvar
    # t_val <- slope_est/std_error #t stat
    # p_val <- 2*pt(-abs(t_val), df = nrow(space)-2)
    # f_stat <- lin_mod$fstatistic[1]
    # f <- summary(lin_mod)$fstatistic
    # model_pval <- pf(f[1], f[2], f[3], lower = FALSE)
  })
}

