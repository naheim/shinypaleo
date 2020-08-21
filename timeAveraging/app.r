library(shiny)
#source("R/utils.r")

ui <- fluidPage(

	titlePanel("Time Averaging, Southern California"),
	
	sidebarLayout(

		sidebarPanel(
			h3("Make Selections"),
			br(),
			
			h5("All plots and statistics presented on the left are for the combination of environment and taxa selected below"),
			br(),
			
			# select region
			selectInput(inputId = "region",
				label = "Region:",
				choices = c("all","Palos Verdes","San Diego","San Pedro","Santa Barbara"),
				selected = "all"),
			br(),
			
			# select depth range
			selectInput(inputId = "depth",
				label = "Depth Range (meters):",
				choices = c("all","23-31","40-48","51-58","89"),
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
			
			## Number of Sites, species and occurrences (live and dead)
			h3("Counts of Live and Dead Individuals & Species"),		
			fluidRow(
				tableOutput(outputId = "env_stats")
			), 
			
			## Live - Dead cross plots
			fluidRow(
				h3("Comparisons of Living and Death Assemblages"),
				plotOutput(outputId = "liveDeadPlots", height = "500px", width = "1000px")
			),
			
			## aggregate Live - Dead similarity
			fluidRow(
				h3("Similarity between pooled living and death assembalges"),
				tableOutput(outputId = "liveDeadSimPooled")
			),
			
			## Live - Dead similarity
			fluidRow(
				h3("Similarity between live and death assembalges"),
				plotOutput(outputId = "liveDeadSim", height = "500px", width = "1000px")
			),
			
			## Live - Dead comparison of two sites
			fluidRow(
				h3(textOutput(outputId = "compSelections")),
				strong("Species Counts"),
				tableOutput(outputId = "siteList")
			),
			
			fluidRow(
				strong("Live-dead similarity"),
				tableOutput(outputId = "siteListSim")
			),
			
			## Locality Map
			fluidRow(
				h3("Map of Mugu Lagoon with Sample Locations"),
				strong("Click on Map to download a larger version."),
				a(img(src='Warme1971_Map2.png', height = "805px", width = "1000px"), href="https://github.com/naheim/shinypaleo/blob/master/liveDead/www/Warme1971_Map2.png?raw=true"),
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
	
	# make selection header
	output$selections <- renderText({
		paste0("Viewing ", input$taxa, " species in ", input$enviro, " environments.")
	})
	
	# make header in main section showing comparison
	output$compSelections <- renderText({
		paste0(input$site1, " vs. ", input$site2)
	})
	
	# make species lists for two sites
	output$siteList <- renderTable({
		req(input$site1, input$site2)
		newLive <- tempLive()[match(c(input$site1, input$site2), rownames(tempLive())),]
		newDead <- tempDead()[match(c(input$site1, input$site2), rownames(tempDead())),]
		
		nLiveSp2 <- colSums(newLive)
		nDeadSp2 <- colSums(newDead)
		
		newLive2 <- newLive[,nLiveSp2 > 0 | nDeadSp2 > 0] 
		newDead2 <- newDead[,nLiveSp2 > 0 | nDeadSp2 > 0]

		spNames <- sub("_", " ", colnames(newLive2))
		siteTable <- data.frame('Class'=species$Class[match(spNames, species$taxonName)], 'Species'=spNames, 'live1'=as.integer(newLive2[1,]), 'dead1'=as.integer(newDead2[1,]), 'live2'=as.integer(newLive2[2,]), 'dead2'=as.integer(newDead2[2,]), check.names=FALSE)
		colnames(siteTable)[3:6] <- c(paste0(input$site1,":live"), paste0(input$site1,":dead"),paste0(input$site2,":live"), paste0(input$site2,":dead"))
		# add total
		siteTable <- rbind(siteTable, c("","Total Counts", colSums(siteTable[,3:6])))
	})
	
	# similarities for two sites
	output$siteListSim <- renderTable({
		req(input$site1, input$site2)
		newLive <- tempLive()[match(c(input$site1, input$site2), rownames(tempLive())),]
		newDead <- tempDead()[match(c(input$site1, input$site2), rownames(tempDead())),]
		
		nLiveSp2 <- colSums(newLive)
		nDeadSp2 <- colSums(newDead)
		
		newLive2 <- newLive[,nLiveSp2 > 0 | nDeadSp2 > 0] 
		newDead2 <- newDead[,nLiveSp2 > 0 | nDeadSp2 > 0]
		sim <- simCalc(newLive2, newDead2)[,-1]
		colnames(sim) <- c("Jaccard similarity index", "Chao-Jaccard similarity index")
		sim
	}, rownames=TRUE)
	

	
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
		sim <- data.frame("Jaccard similarity index"=sim$jaccard, "Chao-Jaccard similarity index"=sim$chao.jaccard, check.names = FALSE)
		sim
	}, rownames=FALSE)
	
	# plot similarity
	output$liveDeadSim <- renderPlot({
		sim <- simCalc(tempLive(), tempDead())
		par(pch=16, cex.axis=1.5, cex.lab=1.5, las=1, mfrow=c(1,2))
		hist(sim$jaccard, breaks=seq(0,1,0.05), xlab="Jaccard similarity index", ylab="Number of sites", main="Similarity-Species")
		box()
		hist(sim$chao.jaccard, breaks=seq(0,1,0.05), xlab="Chao-Jaccard similarity index", ylab="Number of sites", main="Similarity-Abundance")
		box()
		
	})
	
	## generate dynamic menus for selecting two sites for comparison
	output$site1 <- renderUI({
		sites <- rownames(tempLive())
		selectInput(inputId = "site1",
			label = "Site 1:",
			choices = sites)
	})
	
	output$site2 <- renderUI({
		req(input$site1)
		sites <- rownames(tempLive())
		sites <- sites[!is.element(sites, input$site1)]
		selectInput(inputId = "site2",
			label = "Site 2:",
			choices = sites,
			selected = "site_2")
	})
	
	
		
}

shinyApp(ui = ui, server = server)
