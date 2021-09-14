library(shiny)
source("R/utils.r")

ui <- fluidPage(

	titlePanel("Taphonomy, with examples from Southern California"),
	
	tabsetPanel(type = "tabs", 
		tabPanel("Live-Dead Data", fluid = TRUE,
			sidebarLayout(
				sidebarPanel(					
					h3("Please be patient, page may take up to 30 seconds to load", style="color:red"),
					h5("Wiat until you see graphs appear", style="color:red"),
					br(),
			
					h5("All plots and statistics presented on the right are for the combination of environment and taxa selected below"),
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
			
					# select two columns to compare
					strong("Select two sites to compare (see map) (this only changes part 5.)"),
					p("Always select site 1 first."),
					fluidRow(
						column(6,
							uiOutput("site1")
						),
						column(6,
							uiOutput("site2")
						),
					),
			
					# data citation
					strong("Data Source:"),
					shiny::p("Warme, J. E. 1971. Paleoecological aspects of a modern coastal lagoon.", em("University of California Publications in Geological Sciences"), "87:1-110."),
					
					width=3,
		
				),
				
				mainPanel(					
					## Title with selections
					fluidRow(
						h2(textOutput(outputId = "liveDeadSelections"), style="color:blue")
					),
			
					## Number of Sites, species and occurrences (live and dead)
					h3("1. Counts of Live and Dead Individuals & Species"),		
					fluidRow(
						div(tableOutput(outputId = "env_stats"), style = "font-size:120%")
					), 
			
					## Live - Dead cross plots
					fluidRow(
						h3("2. Comparisons of Living and Death Assemblages"),
						plotOutput(outputId = "liveDeadPlots", height = "550px", width = "1000px"),
						h5("These two plots compare the numbers of species (left) and individuals (right) in the living and \
						death assemblages. Each point is a site. The dashed line is the 1-to-1 line: samples that fall on the \
						line have the same value in the living and death assemblages. Note that both axes are shown on a log-scale. \
						This means that each change of one unit on the axis represents a factor-of-ten change in the data. \
						We often plot data on a log-scale when the data span a large range in values and most are small.")
						
					),
			
					## aggregate Live - Dead similarity
					fluidRow(
						h3("3. Similarity between pooled living and death assembalges"),
						div(tableOutput(outputId = "liveDeadSimPooled"), style = "font-size:120%")
					),
			
					## Live - Dead similarity
					fluidRow(
						h3("4. Similarity between live and death assembalges"),
						plotOutput(outputId = "liveDeadSim", height = "500px", width = "500px"),
						h5("Histogram of live-dead Jaccard similarities for individual sites. Mean value in red.")
					),
			
					## Live - Dead comparison of two sites
					fluidRow(
						h3(textOutput(outputId = "compSelections")),
						strong("Species Counts"),
						tableOutput(outputId = "siteList")
					),
			
					fluidRow(
						strong("Live-dead similarity"),
						div(tableOutput(outputId = "siteListSim"), style = "font-size:120%")
					),
					
					## 6 similarity among living and among death assemblages
					fluidRow(
						h3("6. Similarity between sites within living and death assemblages"),
						strong("Mean values in red."),
						plotOutput(outputId = "liveDeadSim2", width="500px", height="1000px")
					),
			
					## Locality Map
					fluidRow(
						h3("Map of Mugu Lagoon with Sample Locations"),
						strong("Click on Map to download a larger version."),
						a(img(src='Warme1971_Map2.png', height = "805px", width = "1000px"), href="https://github.com/naheim/shinypaleo/blob/master/liveDead/www/Warme1971_Map2.png?raw=true", target="_blank"),
					)
		
				)
			)	
		),	
		
		tabPanel("TIme-Averaging Data", fluid = TRUE,
			sidebarLayout(
				sidebarPanel(
					# Nuculana_taphria
					h2(em("Nuculana taphria")),
					img(src='Nuculana_taphria.jpg', height = "145px", width = "250px"), # actual size: height = "370px", width = "640px"
					h5("Scale bar is 1 mm", style="color:gray"),
					h5("Image source: Tomašových et al. (2019).", style="color:gray"),
					br(),
		
					h5("All plots and statistics presented on the left are for the region selected below"),
					br(),
		
					# select region
					selectInput(inputId = "region",
						label = "Region:",
						choices = c("all","Palos Verdes","San Diego","San Pedro","Santa Barbara","all but San Diego"),
						selected = "all"),
					br(),
		
					# data citation
					strong("Data Source:"),
					shiny::p("Tomašových, A., Kidwell, S., & Barber, R. 2016. Inferring skeletal production from time-averaged assemblages: skeletal loss pulls the timing of production pulses towards the modern period.", em("Paleobiology"), "42(1), 54-76.", a(href="https://dx.doi.org/10.1017/pab.2015.30", "DOI: 10.1017/pab.2015.30", target="_blank")),
					
					# add more selections here
					width=3
				),
				mainPanel(
					## Title with selections
					fluidRow(
						h2(textOutput(outputId = "timeAvgeSelections"), style="color:blue"),
					),
		
					## Age distribution of shells
					h3("1. Age distribution of shells"),		
					fluidRow(
						plotOutput(outputId = "ageDist"),
					), 
		
					## Age vs. Depth
					h3("2. Age vs. Depth"),		
					fluidRow(
						plotOutput(outputId = "ageDepth", height = "600px", width = "600px"),
					), 
		
					## Age vs. Size
					h3("3. Age vs. Size"),		
					fluidRow(
						plotOutput(outputId = "ageSize", height = "600px", width = "600px"),
					),
				
					## Locality Map
					fluidRow(
						h3("Map of Southern California with Sample Locations"),
						strong("Click on Map to download a larger version."),
						# original image size: height = "1707px", width = "1800px"
						a(img(src='TomasovychEtAl2016_Fig1.png', height = "759px", width = "800px"), href="https://github.com/naheim/shinypaleo/blob/master/timeAveraging/www/TomasovychEtAl2016_Fig1.png?raw=true", target="_blank"),
					),
				)
			)
		),
			
		tabPanel("Time-Averaging Model", fluid = TRUE,
			sidebarLayout(
				sidebarPanel( 
					h3("Please be patient, page may take a few seconds to load", style="color:red"),
					h5("Wiat until you see graphs appear", style="color:red"),
					br(),
					
					# select immigration probability
					sliderInput(inputId = "immig",
						label="Probability of immigration:",
						min = 0.1, max = 0.9,
						value = 0.1),
					br(),	
		
					# select level of averaging--shell lifetime
					sliderInput(inputId = "timeavg",
						label="Years shells persist in death assemblage:",
						min = 2, max = 100,
						value = 80),
								
					# giving credit
					shiny::p("Model inspired by", a(href="https://people.ucsc.edu/~mclapham/", "Matthew Clapham", target="_blank"), "and written by Noel Heim"),
										
					# add more selections here
					width=3
				),
				mainPanel(
					## model results
					h3("Time-averaging and diversity"),		
					fluidRow(
						plotOutput(outputId = "modelResults", height = "1100px", width = "900px"),
					)
					
				)
			)	
		)
	)
)

server <- function(input, output, session) {
	#########
	#
	# Live-Dead Tab
	#
	#########
	species <- read.delim(file="warmeSpecies.tsv")
	species <- subset(species, Phylum == 'Mollusca') # include only mollusca
	environments <- read.delim(file="warmeHeader.tsv")
	
	liveIn <- read.delim(file="warmeLive.tsv")
	# drop non-molluscan taxa and those not identified to species
	liveIn <- liveIn[,is.element(colnames(liveIn), species$colName) & !grepl("_sp", colnames(liveIn))]
	# drop minor environments
	liveIn <- liveIn[is.element(environments[2,], c("inter_barren","sub_eelgrass")),]
	
	deadIn <- read.delim(file="warmeDead.tsv")
	deadIn[,species$Class == 'Bivalvia'] <- floor(deadIn[,species$Class == 'Bivalvia']/2)
	# drop non-molluscan taxa and those not identified to species
	deadIn <- deadIn[,is.element(colnames(deadIn), species$colName) & !grepl("_sp", colnames(deadIn))]
	# drop minor environments
	deadIn <- deadIn[is.element(environments[2,], c("inter_barren","sub_eelgrass")),]
	environments <- environments[,is.element(environments[2,], c("inter_barren","sub_eelgrass"))]
	
	tempCounts <- dropEmpty(liveIn, deadIn, "thisegg")
	liveCounts <- tempCounts$live
	deadCounts <- tempCounts$dead
	
	# Parse Live-Dead Data		
	tempLive <- reactive({
		req(input$taxa, input$enviro)
		parseDataLiveDead(liveCounts, input$taxa, input$enviro, species, environments)
	})
	tempDead <- reactive({
		req(input$taxa, input$enviro)
		parseDataLiveDead(deadCounts, input$taxa, input$enviro, species, environments)
	})
	
	# make selection header
	output$liveDeadSelections <- renderText({
		paste0("Viewing ", input$taxa, " species in ", input$enviro, " environments.")
	})
	
	# make header in main section showing comparison
	output$compSelections <- renderText({
		paste0("5. ", input$site1, " vs. ", input$site2)
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
	}, digits=0)
	
	
	# similarities for two sites
	output$siteListSim <- renderTable({
		req(input$site1, input$site2)
		newLive <- tempLive()[match(c(input$site1, input$site2), rownames(tempLive())),]
		newDead <- tempDead()[match(c(input$site1, input$site2), rownames(tempDead())),]
		
		nLiveSp2 <- colSums(newLive)
		nDeadSp2 <- colSums(newDead)
		
		newLive2 <- newLive[,nLiveSp2 > 0 | nDeadSp2 > 0] 
		newDead2 <- newDead[,nLiveSp2 > 0 | nDeadSp2 > 0]
		sim <- simCalc(newLive2, newDead2)
		sim <- data.frame(sim[,match(c("chao.jaccard"), colnames(sim))])
		colnames(sim) <- c("Chao-Jaccard similarity index")
		rownames(sim) <- c(input$site1, input$site2)
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
		
		statTable <- rbind("Number of Sites"=nSites, "Number of Speices"=nSpecies, "Number of Individuals"=nOccur)

	}, rownames=TRUE, digits=0)
	
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
		plot(nLiveSite, nDeadSite, xlab="Number of live individuals", ylab="Number of dead individuals", main="Individuals", log="xy")
		abline(a=0, b=1, lty=2)
	})
	
	# pooled similarity
	reactive({print(colSums(tempLive()))})
	
	output$liveDeadSimPooled <- renderTable({
		sim <- simCalc(colSums(tempLive()), colSums(tempDead()))
		sim <- data.frame("Chao-Jaccard similarity index"=sim$chao.jaccard, check.names = FALSE)
		sim
	}, rownames=FALSE)
	
	# plot similarity
	output$liveDeadSim <- renderPlot({
		sim <- simCalc(tempLive(), tempDead())
		par(cex.axis=1.5, cex.lab=1.5, las=1, mfrow=c(1,1))
		hist(sim$chao.jaccard, breaks=seq(0,1,0.05), xlab="Chao-Jaccard similarity index", ylab="Number of sites", main="Live-Dead Similarity")
		abline(v=mean(sim$chao.jaccard, na.rm=T), lwd=1.5, col='red')
		box()	
	})
	
	# plot similarity among live and dead samlpes
	output$liveDeadSim2 <- renderPlot({
		simLive <- simCalc(tempLive(), NULL)
		simDead <- simCalc(tempDead(), NULL)
		par(cex.axis=1.5, cex.lab=1.5, las=1, mfrow=c(2,1))
		hist(simLive$chao.jaccard, breaks=seq(0,1,0.05), xlab="Chao-Jaccard similarity index", ylab="Number of sites", main="Live-Live Similarity")
		abline(v=mean(simLive$chao.jaccard, na.rm=T), lwd=1.5, col='red')
		box()
		hist(simDead$chao.jaccard, breaks=seq(0,1,0.05), xlab="Chao-Jaccard similarity index", ylab="Number of sites", main="Dead-Dead Similarity")
		abline(v=mean(simDead$chao.jaccard, na.rm=T), lwd=1.5, col='red')
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
	
	
	#########
	#
	# Time-Averaging Tabs
	#
	#########
	rawData <- read.delim(file="tomasovychAges.tsv")
	
	# Parse Data		
	ages <- reactive({
		parseDataTimeAvg(rawData, input$region)
	})
	
	topLab <- reactive ({
		topLabel(input$region)
	})
	
	# make selection header
	output$timeAvgeSelections <- renderText({
		topLab()
	})
	
	# plot age distribution
	output$ageDist <- renderPlot({
		myAges <- ages()[,match("Weighted.age", colnames(ages()))]
		counter <- 500
		maxX <- max(myAges) + counter - (max(myAges) %% counter)
		myBreaks <- seq(0, maxX, counter)
		par(cex=1.5, las=1)
		hist(myAges, breaks = myBreaks, xlab="Age (years before 2003)", ylab="Number of individuals", main="Age Distribution")
		box()
	})	
	
	# plot age vs. depth
	output$ageDepth <- renderPlot({
		myAges <- ages()[,match("Weighted.age", colnames(ages()))]
		myDepth <- ages()[,match("Depth", colnames(ages()))]
		par(cex=1.5, las=1, pch=16)
		plot(myDepth[myAges>0], myAges[myAges>0], log="y", xlab="Water depth (m)", ylab="Age (years before 2003)")
	})
	
	# plot age vs. size
	output$ageSize <- renderPlot({
		myAges <- ages()[,match("Weighted.age", colnames(ages()))]
		mySize <- ages()[,match("Height.complete.specimens", colnames(ages()))]
		par(cex=1.5, las=1, pch=16)
		plot(mySize[myAges>0], myAges[myAges>0], log="y", xlab="Shell height (mm)", ylab="Age (years before 2003)")
	})
	
	# simple time-averaging model
	output$modelResults <- renderPlot({
		modRes <- taModel(nT=500, pDest=(1/input$timeavg), pImmig=input$immig, pDeath=0.6)
		
		layout(matrix(c(1:3,3), nrow=2, ncol=2, byrow=TRUE))
		par(pch=16, las=1, cex=1.5)
		plot(1:10, type="n", xlim=c(0.5,1.5), ylim=c(0,6.25), xaxt="n", xlab="", ylab="Richness inflation")
		abline(h=1, lty=2)
		boxplot(modRes$output$deadS/modRes$output$liveS, range=0, lwd=1.25, lty=1, add=TRUE)
		plot(modRes$output$chao.jaccard, 1:nrow(modRes$output), xlim=c(0,1), xlab="Live-dead similarity", ylab="Years", type="l", lwd=1.25)
		#mtext(paste("Variance in composition: ", signif(var(modRes$chao.jaccard),2), sep="", adj=0), side=3, cex=1.5)
		#lines(modRes$deltaSimInit, 1:nrow(modRes), lwd=1.25, col='red')
		
		if(max(modRes$deathAge) <= 100) {
			myBreaks <- seq(0,max(modRes$deathAge) + (max(modRes$deathAge) %% 2), 2)
		} else {
			myBreaks <- seq(0,max(modRes$deathAge), length.out=100)
		}
		hist(modRes$deathAge, breaks=myBreaks, xlab="Age (years)", ylab="Number of shells", main="Age Distribution")
		box()
	})
}

shinyApp(ui = ui, server = server)

