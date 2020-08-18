library(shiny)
library(DT)
ui <- fluidPage(

	titlePanel("Live-Dead Analysis, Mugu Lagoon, California"),
	
	sidebarLayout(

		sidebarPanel(
			h3("Make Selections"),
			br(),
			
			# select environment
			selectInput(inputId = "enviro",
				label = "Environment:",
				choices = c("all","intertidal sand flat","subtidal ell grass"),
				selected = "all"),
			br(),
					
			# add more selections here
			
			width=3,
		),

		mainPanel(
			## Number of Sites, species and occurrences (live and dead)
			h3("Counts of Live and Dead Individuals"),
			fluidRow(
				textOutput(outputId = "env_stats")
			), 
			
			## Locality Map
			fluidRow(
				h3("Map of Mugu Lagoon with Sample Locations"),
				strong("Click on Map to download a larger version."),
				a(img(src='Warme1971_Map2.png', height = 805, width = 1000), href="https://github.com/naheim/shinypaleo/blob/master/liveDead/www/Warme1971_Map2.png?raw=true"),
			),
			
			## Data table
			fluidRow(
				tableOutput(outputId = "livefile"),
			), 
		)
	)
)

server <- function(input, output) {
	species <- read.delim(file="warmeSpecies.tsv")
	species <- subset(species, Phylum == 'Mollusca') # include only mollusca
	environments <- read.delim(file="warmeHeader.tsv")
	
	liveCounts <- read.delim(file="warmeLive.tsv")
	# drop non-molluscan taxa and those not identified to species
	liveCounts <- liveCounts[,is.element(colnames(liveCounts), species$colName) & !grepl("_sp", colnames(liveCounts))]
	
	deadCounts <- read.delim(file="warmeDead.tsv")
	# drop non-molluscan taxa and those not identified to species
	deadCounts <- deadCounts[,is.element(colnames(deadCounts), species$colName) & !grepl("_sp", colnames(deadCounts))]
	
	# Get env stats	
	output$env_stats <- renderText({
		if(input$enviro == "intertidal sand flat") {
			tempLive <- liveCounts[environments[2,] == "inter_barren",]
			tempDead <- deadCounts[environments[2,] == "inter_barren",]
		} else if (input$enviro == "subtidal ell grass") {
			tempLive <- liveCounts[environments[2,] == "sub_eelgrass",]
			tempDead <- deadCounts[environments[2,] == "sub_eelgrass",]
		} else {
			tempLive <- liveCounts
			tempDead <- deadCounts
		}
		
		nSitesLive <- nrow(tempLive)
		nSitesDead <- nrow(tempDead)
		nSpciesLive <- ncol(tempLive)
		nSpciesDead <- ncol(tempDead)
		nOccurLive <- sum(tempLive)
		nOccurDead <- sum(tempDead)
		
		paste0("You have chosen ", input$enviro, " environments!", nSitesLive, " $#")
	})
	
	output$livefile <- renderTable(liveCounts, rownames=TRUE)  
	
}

shinyApp(ui = ui, server = server)