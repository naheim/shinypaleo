library(shiny)
#library(DT)
ui <- fluidPage(

	titlePanel("Live-Dead Analysis, Mugu Lagoon, California"),
	
	sidebarLayout(

		sidebarPanel(
			h3("Make Selections"),
			br(),
			
			# select environment
			selectInput(inputId = "enviro",
				label = "Environment:",
				choices = c("all","intertidal sand flat","subtidal eel grass"),
				selected = "all"),
			br(),
			
			# select taxon
			selectInput(inputId = "taxa",
				label = "Taxon:",
				choices = c("all","Bivalvia","Gastropoda"),
				selected = "all"),
			br(),	
			# add more selections here
			
			width=3,
		),

		mainPanel(
			## Number of Sites, species and occurrences (live and dead)
			h3("Counts of Live and Dead Individuals"),		
			fluidRow(
				tableOutput(outputId = "env_stats")
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
	output$env_stats <- renderTable({
		# select taxa
		if(input$taxa == "Bivalvia") {
			tempLive <- liveCounts[,is.element(colnames(liveCounts), species$colName[species$Class == 'Bivalvia'])]
			tempDead <- deadCounts[,is.element(colnames(deadCounts), species$colName[species$Class == 'Bivalvia'])]
		} else if (input$taxa == "Gastropoda") {
			tempLive <- liveCounts[,is.element(colnames(liveCounts), species$colName[species$Class == 'Gastropoda'])]
			tempDead <- deadCounts[,is.element(colnames(deadCounts), species$colName[species$Class == 'Gastropoda'])]
		} else {
			tempLive <- liveCounts
			tempDead <- deadCounts
		}
		
		# select environment
		if(input$enviro == "intertidal sand flat") {
			tempLive <- tempLive[environments[2,] == "inter_barren",]
			tempDead <- tempDead[environments[2,] == "inter_barren",]
		} else if (input$enviro == "subtidal eel grass") {
			tempLive <- tempLive[environments[2,] == "sub_eelgrass",]
			tempDead <- tempDead[environments[2,] == "sub_eelgrass",]
		}
		
		nLiveSite <- rowSums(tempLive)
		nDeadSite <- rowSums(tempDead)
		
		nLiveSp <- colSums(tempLive)
		nDeadSp <- colSums(tempDead)
		
		nSites <- c('live'=length(nLiveSite[nLiveSite > 0]), 'dead'=length(nDeadSite[nDeadSite > 0]))
		nSpecies <- c('live'=length(nLiveSp[nLiveSp > 0]), 'dead'=length(nDeadSp[nDeadSp > 0]))
		nOccur <- c('live'=sum(tempLive), 'dead'=sum(tempDead))
		statTable <- rbind("Number of Sites"=nSites, "Number of Speices"=nSpecies, "Number of Occurrences"=nOccur)

	}, rownames=TRUE)
	
	output$livefile <- renderTable(liveCounts, rownames=TRUE)  
	
}

shinyApp(ui = ui, server = server)