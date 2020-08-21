library(shiny)
source("R/utils.r")

ui <- fluidPage(

	titlePanel("Time Averaging, Southern California"),
	
	sidebarLayout(

		sidebarPanel(
			
			# Nuculana_taphria
			h1("<em>Nuculana taphria</em>"),
			h5("Scale bar is 1 mm")
			img(src='Nuculana_taphria.jpg', height = "370px", width = "640px")
			br(),
			
			h5("All plots and statistics presented on the left are for the combination of environment and taxa selected below"),
			br(),
			
			# select region
			selectInput(inputId = "region",
				label = "Region:",
				choices = c("all","Palos Verdes","San Diego","San Pedro","Santa Barbara"),
				selected = "all"),
			br(),	
			
			# add more selections here
			width=3,
		),

		mainPanel(
			## Title with selections
			fluidRow(
				h2(textOutput(outputId = "selections"), style="color:blue")
			),
			
			## Age distribution of shells
			h3("1. Age distribution of shells"),		
			fluidRow(
				tableOutput(outputId = "ageDist")
			), 
			
			
			## Locality Map
			fluidRow(
				h3("Map of Southern California with Sample Locations"),
				strong("Click on Map to download a larger version."),
				a(img(src='TomasovychEtAl2016_Fig1.png', height = "1707px", width = "1800px"), href="https://github.com/naheim/shinypaleo/blob/master/timeAveraging/www/TomasovychEtAl2016_Fig1.png?raw=true"),
			),
		)
	)
)

server <- function(input, output, session) {
	
	rawData <- read.delim(file="tomasovychAges.tsv")
	
	# Parse Data		
	ages <- reactive({
		req(input$region, input$depth)
		parseData(rawData, input$region)
	})
	
	# make selection header
	output$selections <- renderText({
		if(input$region == "all") {
			label <- "Viewing Nuculana taphria specimens from all regions."
		} else 
			label <- paste0("Viewing Nuculana taphria specimens from ", input$region.")
		}
		label
	})
	
	# plot age distribution
	output$ageDist <- renderPlot({
		counter <- 500
		myBreaks <- seq(0, max(ages()$Weighted.age) + counter - max(ages()$Weighted.age) %% counter, counter)
		par(cex=1.5, las=1)
		hist(ages()$Weighted.age, breaks = myBreaks, xlab="Age in years before 2003", ylab="Number of specimens", main="Age Distribution")
	})
		
}

shinyApp(ui = ui, server = server)

