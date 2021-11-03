library('shiny')

ui <- fluidPage(

	titlePanel("Macrostrat"),
	
	sidebarLayout(
		sidebarPanel(					
			h3("Set Plotting Options"),
			h5("The data can take about a minuteto load. Please be patient after you hit the 'Go' button.", style="color:red"),
			br(),
			
			# select project
			selectInput(inputId = "proj",
			            label = "Project:",
			            choices = c("N. America & Carribean","New Zealand"),
			            selected = "N. America & Carribean"),
			br(),
			
			# select environment
			selectInput(inputId = "enviro",
				label = "Environment:",
				choices = c("all","marine","non-marine"),
				selected = "all"),
			br(),
			
			# select taxa
			textInput(inputId = "taxa",
				label = "Enter a higher taxon (leave blank for all, seperate multiple by commas): "),
			br(),
			
			br(),	
			
#			submitButton(" Go "),
			actionButton("submitParams", " Go "),
			width=3,
		),
		
		mainPanel(					
			
			## Three Plots
			h2("Macrostrat Timeseries"),		
			fluidRow(
				plotOutput(outputId = "timeseries")
			), 
			
		)
	)
)	

server <- function(input, output, session) {	
	macrostrat <- reactive({
	  t0 <- Sys.time()
	  
	  # get inputs & timescale
	  if(input$proj == "N. America & Carribean") {
		  proj.id <- "1,7"
		  timescale <- read.csv(file=URLencode("https://macrostrat.org/api/defs/intervals?timescale=international ages&format=csv"), header=TRUE)
		  timescale <- subset(timescale, t_age >= 0.0117)
	  } else {
		  proj.id <- "5"
		  timescale <- read.csv(file=URLencode("https://macrostrat.org/api/defs/intervals?timescale=New Zealand ages&format=csv"), header=TRUE)
	  }
	  nBins <- nrow(timescale)
	  
	  if(input$enviro == "all") {
	    env.call <- ""
	  } else {
	    env.call <- paste0("&environ_class=",input$enviro)
	  }
	  
	  # read in packages
	  # note the use of URLencode, which is needed to convert the space in international ages to unicode
	  pkg.uri <- URLencode(paste0("https://macrostrat.org/api/sections?project_id=",proj.id,"&lith_class=sedimentary",env.call,"&interval_name=Phanerozoic&format=csv"))
		packages <- read.csv(file=pkg.uri, header=TRUE)
		sect.ids <- paste(unique(packages$section_id), collapse=",")
		units.uri <- URLencode(paste0("https://macrostrat.org/api/units?lith_class=sedimentary",env.call,"&section_id=",sect.ids,"&format=csv"))
		units <- read.csv(file=units.uri, header=TRUE)
    unit.ids <- paste(unique(units$unit_id), collapse=",")
		pbdb.uri <- URLencode(paste0("https://macrostrat.org/api/fossils?lith_class=sedimentary",env.call,"&section_id=",sect.ids,"&format=csv"))
		fossils <- read.csv(file=pbdb.uri, header=TRUE)
		
		summaryData <- data.frame('interval'=timescale$name, 'ageBottom'=timescale$b_age, 'ageTop'=timescale$t_age, 'ageMid'=apply(cbind(timescale$b_age, timescale$t_age), 1, mean), 'nPkg'=NA, 'nColl'=NA, 'nFossiliferous'=NA, 'nTrunc'=NA, 'nInit'=NA)

		for(i in 1:nBins) {
			tempPkg <- subset(packages, b_age > timescale$t_age[i] & t_age < timescale$b_age[i])
			summaryData$nPkg[i] <- nrow(tempPkg)
			summaryData$nColl[i] <- sum(tempPkg$pbdb_collections)
			summaryData$nFossiliferous[i] <- nrow(subset(tempPkg, pbdb_collections > 0))
	
			tempTrunc <- subset(tempPkg, t_age >= timescale$t_age[i] & t_age < timescale$b_age[i])
			summaryData$nTrunc[i] <- nrow(tempTrunc)
	
			tempInit <- subset(tempPkg, b_age > timescale$t_age[i] & b_age <= timescale$b_age[i])
			summaryData$nInit[i] <- nrow(tempInit)
	
		}
		t1 <- Sys.time()
		print(t1 - t0)
		
		summaryData
	})
	
	output$timeseries <- renderPlot({
		sumData <- macrostrat()
		drop.ints <- rev(cumsum(rev(sumData$nPkg)))
		sumData <- sumData[drop.ints > 0,]
		
		x.lim <- c(max(sumData$ageBottom), min(sumData$ageTop))
		
	  input$submitParams
		isolate({### PLOT
			# convert color matrix to raster and plot
		  par(mfrow=c(1,3), las=1, pch=16, cex=1.3)
		  plot(sumData$ageMid, sumData$nPkg, type="l", xlim=x.lim, xlab="Geologic time (Ma)", ylab="Number of marine packages", main="Packages")
		  plot(sumData$ageMid, sumData$nColl, type="l", xlim=x.lim, xlab="Geologic time (Ma)", ylab="Number of PBDB collections", main="Fossil Collections")
		  plot(sumData$ageMid, sumData$nFossiliferous/sumData$nPkg, type="l", xlim=x.lim, xlab="Geologic time (Ma)", ylab="Proportion of fossilifeous packages", main="Proportion Fossiliferous")
		  
		})
	})
}

shinyApp(ui = ui, server = server)

