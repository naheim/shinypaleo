library(shiny)

ui <- fluidPage(

	titlePanel("Growth Model for Stromatoporoids"),
	
	sidebarLayout(
		sidebarPanel(					
			h3("Set Model Parameters"),
			h5("The model can take a little bit of time to load. Please be patient after you hit the 'Run Model' button.", style="color:red"),
			br(),
	
			# Geotropism
			h4("Geotropism"),
			numericInput(inputId = "geotrop",
				label = "Enter a positive number greater than zero",
				value = 1,
				min=0,
				step=0.1),
			br(),
			
			# SEDIMENTATION INTERVAL
			h4("Sedimentation Interval"),
			sliderInput(inputId="sedInt", 
				label = "Select a an integer between 0 and 10.",
				min = 0, 
				max = 10,
				value = 0),
			br(),
			
			# SEDIMENTATION INCREMENT
			h4("Sedimentation Increment"),
			br(),  
			sliderInput(inputId="sedIncr", 
				label = "Select a an integer between 0 and 10.",
				min = 0, 
				max = 10,
				value = 0),
			br(),
			
			# SEDIMENTATION STARTUP
			h4("Sedimentation Startup"),
			br(),  
			
			sliderInput(inputId="startup", 
				label = "Select a an integer between 0 and 100.",
				min = 0, 
				max = 100,
				value = 0),
			br(),
			
			br(),						
			actionButton("submit", "Run Model"),
			width=3,
		),
		
		mainPanel(					
			## Parameter Explanations
			h2("Explanation of Model Parameters"),
			br(),
			
			h4("Geotropism"),
			span("This determines whether the structure will preferentially grow up or laterally. Values greater than 1 increase the rate of vertical growth relative to horizontal growth (negative geotropism), while values between 0 and 1 decrease the rate of vertical growth relative to horizontal growth (positive geotropism)."),
			br(),
			
			h4("Sedimentation Interval"),
			span("This is the number of iterations between deposition events. No deposition if set to zero."),
			br(), 
			
			h4("Sedimentation Increment"),
			span("This determines how much sediment deposited in a single depositional event."),
			br(),
			
			h4("Sedimentation Startup"),
			span("The number of iterations before first depositional event."),
			
			
			## Number of Sites, species and occurrences (live and dead)
			h2("Modeled Stromatoporoid Morphology"),		
			fluidRow(
				plotOutput(outputId = "rangePlot"),
				h5("Call to Paleobiology Database API:"),
				textOutput(outputId = "uriCall")
			), 
			
		)
	)
)	

server <- function(input, output, session) {	
	pbdbCall <- reactive({
		req(input$taxa, input$taxonReso)
		taxa <- trimws(gsub(", ", ",", input$taxa))
		uri <- URLencode(paste0("https://paleobiodb.org/data1.2/taxa/list.tsv?base_name=",taxa,"&rank=",tolower(input$taxonReso),"&taxon_status=accepted&rel=all_parents&show=class,app&order=hierarchy,firstapp"))
		pbdbReturn <- read.delim(file=uri)	
	})
	
	
	pbdb <- reactive({
		req(pbdbCall())
		validate(
			need(is.element("n_occs", colnames(pbdbCall())), "Error: Check spelling of taxon names that the taxa entered\nare at least the level of resolution selected.")
		)
		pbdbReturn <- subset(pbdbCall(), n_occs >= 1 )
		validate(
			need(nrow(pbdbReturn) > 0, "Error: Check spelling of taxon names that the taxa entered\nare at least the level of resolution selected.")
		)
		pbdbReturn
	})
	
	output$uriCall <- renderText({
		input$submitTaxa
		isolate({
			taxa <- trimws(gsub(", ", ",", input$taxa))
			uri <- URLencode(paste0("https://paleobiodb.org/data1.2/taxa/list.tsv?base_name=",taxa,"&rank=",tolower(input$taxonReso),"&taxon_status=accepted&rel=all_parents&show=class,app&order=hierarchy,firstapp"))
		})
	})
	
	output$rangePlot <- renderPlot({
		input$submitTaxa
		isolate({
			nTaxa <- nrow(pbdb())
			par(mar=c(7.5,4,0.5,0.5), las=2, cex=1.5)
			plot(1:10, type="n", xlim=c(1,nTaxa), ylim=rev(range(c(pbdb()$firstapp_max_ma, pbdb()$lastapp_min_ma), na.rm=TRUE)), xaxt="n", ylab="Geologic time (Ma)", xlab="")
			segments(1:nTaxa, pbdb()$firstapp_max_ma, 1:nTaxa, pbdb()$lastapp_min_ma, lwd=5)
			axis(side=1, at=1:nTaxa, labels=pbdb()$taxon_name)
		})
	})
	
	output$rangeTable <- renderTable({
		input$submitTaxa
		isolate({
			if(input$taxonReso == "species") {
				hier <- c("Phylum","Class","Order","Family","Genus","Species")
			} else if(input$taxonReso == "genus") {
				hier <- c("Phylum","Class","Order","Family","Genus")
			} else if(input$taxonReso == "family") {
				hier <- c("Phylum","Class","Order","Family")
			} else if(input$taxonReso == "order") {
				hier <- c("Phylum","Class","Order",)
			} else if(input$taxonReso == "class") {
				hier <- c("Phylum","Class",)
			} else {
				hier <- c("Phylum")
			}
			pbdbTable <- pbdb()[,match(c("taxon_name",tolower(hier),"n_occs","early_interval","firstapp_max_ma","late_interval","lastapp_min_ma"), colnames(pbdb()))]
			pbdbTable$late_interval[is.na(pbdbTable$late_interval)] <- pbdbTable$early_interval[is.na(pbdbTable$late_interval)]
			colnames(pbdbTable) <- c("Name", hier,"Number Occs.","FAD ","FAD Ma","LAD","LAD Ma")
			pbdbTable
		})
	})
}

shinyApp(ui = ui, server = server)

