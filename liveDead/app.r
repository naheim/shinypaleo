library(shiny)
source("R/utils.r")

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
			h3("Counts of Live and Dead Individuals & Species"),		
			fluidRow(
				tableOutput(outputId = "env_stats")
			), 
			
			## Live - Dead cross plots
			fluidRow(
				h3("Comparisons of Live and Death Assemblages"),
				plotOutput(outputId = "liveDeadPlots", height = "500px", width = "1000px")
			),
			
			## aggregate Live - Dead similarity
			fluidRow(
				h3("Similarity between live and death pooled assembalges"),
				tableOutput(outputId = "liveDeadSimPooled")
			),
			
			## Live - Dead similarity
			fluidRow(
				h3("Similarity between live and death assembalges"),
				plotOutput(outputId = "liveDeadSim", height = "500px", width = "1000px")
			),
			
			## Locality Map
			fluidRow(
				h3("Map of Mugu Lagoon with Sample Locations"),
				strong("Click on Map to download a larger version."),
				a(img(src='Warme1971_Map2.png', height = "805px", width = "1000px"), href="https://github.com/naheim/shinypaleo/blob/master/liveDead/www/Warme1971_Map2.png?raw=true"),
			),
			
			## Data table
			fluidRow(
				tableOutput(outputId = "livefile"),
			), 
		)
	)
)

server <- function(input, output, session) {
	
	species <- read.delim(file="warmeSpecies.tsv")
	species <- subset(species, Phylum == 'Mollusca') # include only mollusca
	environments <- read.delim(file="warmeHeader.tsv")
	
	liveIn <- read.delim(file="warmeLive.tsv")
	# drop non-molluscan taxa and those not identified to species
	liveIn <- liveIn[,is.element(colnames(liveIn), species$colName) & !grepl("_sp", colnames(liveIn))]
	# drop minor environments
	liveIn <- liveIn[is.element(environments[2,], c("inter_barren","sub_eelgrass")),]
	
	deadIn <- read.delim(file="warmeDead.tsv")
	# drop non-molluscan taxa and those not identified to species
	deadIn <- deadIn[,is.element(colnames(deadIn), species$colName) & !grepl("_sp", colnames(deadIn))]
	# drop minor environments
	deadIn <- deadIn[is.element(environments[2,], c("inter_barren","sub_eelgrass")),]
	environments <- environments[,is.element(environments[2,], c("inter_barren","sub_eelgrass"))]
	
	tempCounts <- dropEmpty(liveIn, deadIn)
	liveCounts <- tempCounts$live
	deadCounts <- tempCounts$dead
	
	# Parse Data		
	tempLive <- reactive({
		req(input$taxa, input$enviro)
		parseData(liveCounts, input$taxa, input$enviro, species, environments)
	})
	tempDead <- reactive({
		req(input$taxa, input$enviro)
		parseData(deadCounts, input$taxa, input$enviro, species, environments)
	})
	

	# Get stats		
	output$env_stats <- renderTable({
		nLiveSite <- rowSums(tempLive())
		nDeadSite <- rowSums(tempDead())
		
		nLiveSp <- colSums(tempLive())
		nDeadSp <- colSums(tempDead())
		
		nSites <- c('live'=length(nLiveSite[nLiveSite > 0]), 'dead'=length(nDeadSite[nDeadSite > 0]))
		nSpecies <- c('live'=length(nLiveSp[nLiveSp > 0]), 'dead'=length(nDeadSp[nDeadSp > 0]))
		nOccur <- c('live'=sum(tempLive()), 'dead'=sum(tempDead()))
		
		statTable <- rbind("Number of Sites"=nSites, "Number of Speices"=nSpecies, "Number of Occurrences"=nOccur)

	}, rownames=TRUE)
	
	# plot live vs. dead
	output$liveDeadPlots <- renderPlot({
		nLiveSite2 <- rowSums(tempLive())
		nDeadSite2 <- rowSums(tempDead()) 
		nLiveSite <- nLiveSite2[nLiveSite2 > 0 & nDeadSite2 > 0] 
		nDeadSite <- nDeadSite2[nLiveSite2 > 0 & nDeadSite2 > 0] 
		
		nLiveSp2 <- colSums(tempLive())
		nDeadSp2 <- colSums(tempDead())
		nLiveSp <- nLiveSp2[nLiveSp2 > 0 & nDeadSp2 > 0] 
		nDeadSp <- nDeadSp2[nLiveSp2 > 0 & nDeadSp2 > 0] 
		
		par(pch=16, mfrow=c(1,2), cex=1.5, las=1)
		plot(nLiveSp, nDeadSp, xlab="Number of live species", ylab="Number of dead species", main="Species", log="xy")
		abline(a=0, b=1, lty=2)
		plot(nLiveSite, nDeadSite, xlab="Number of live specimens", ylab="Number of dead specimens", main="Specimens", log="xy")
		abline(a=0, b=1, lty=2)
	})
	
	# pooled similarity
	output$liveDeadSimPooled <- renderTable({
		sim <- simCalc(colSums(tempLive()), colSums(tempDead()))
		sim2 <- data.frame("Percent Similarity"=sim$pctSim, "Jaccard Similarity"=sim$jaccard)
		
	}, rownames=FALSE)
	
	# plot similarity
	output$liveDeadSim <- renderPlot({
		sim <- simCalc(tempLive(), tempDead())
		par(pch=16, cex.axis=1.5, cex.lab=1.5, las=1, mfrow=c(1,2))
		hist(sim$pctSim, breaks=seq(0,1,0.1), xlab="Percent similarity", ylab="Number of sites", main="Similarity-Abundance")
		box()
		hist(sim$jaccard, breaks=seq(0,1,0.1), xlab="Jaccard similarity index", ylab="Number of sites", main="Similarity-Species")
		box()
		
	})
	
	output$livefile <- renderTable(liveCounts, rownames=TRUE)  
	
}

shinyApp(ui = ui, server = server)












