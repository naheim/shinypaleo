library(shiny)
source("R/utils.r")

ui <- fluidPage(

	titlePanel("Time Averaging, Southern California"),
	
	sidebarLayout(

		sidebarPanel(
			## Title with selections
			fluidRow(
				h2(textOutput(outputId = "selections"), style="color:blue")
			),
			
			# Nuculana_taphria
			h2(em("Nuculana taphria")),
			img(src='Nuculana_taphria.jpg', height = "145px", width = "250px"), # actual size: height = "370px", width = "640px"
			h5("Scale bar is 1 mm", style="color:gray"),
			br(),
			
			h5("All plots and statistics presented on the left are for the region selected below"),
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
				# original image size: height = "1707px", width = "1800px"
				a(img(src='TomasovychEtAl2016_Fig1.png', height = "759px", width = "800px"), href="https://github.com/naheim/shinypaleo/blob/master/timeAveraging/www/TomasovychEtAl2016_Fig1.png?raw=true"),
			),
		)
	)
)

server <- function(input, output, session) {
	
	rawData <- read.delim(file="tomasovychAges.tsv")
	
	# Parse Data		
	if(intput$region == "all") {
		ages <- rawData
	} else {
		ages <- subset(rawData, Region == input$region)
	}
	
	# make selection header
	output$selections <- renderText({
		if(input$region == "all") {
			"Viewing Nuculana taphria specimens from all regions."
		} else {
			paste0("Viewing Nuculana taphria specimens from ", input$region)
		}
	}),
	
	# plot age distribution
	output$ageDist <- renderPlot({
		myAges <- ages[,match("Weighted.age", colnames(ages))]
		counter <- 500
		maxX <- max(myAges) + counter - (max(myAges) %% counter)
		myBreaks <- seq(0, maxX, counter)
		par(cex=1.5, las=1)
		hist(myAges, breaks = myBreaks, xlab="Age in years before 2003", ylab="Number of specimens", main="Age Distribution")
	}),
		
}

shinyApp(ui = ui, server = server)

