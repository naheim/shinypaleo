library(shiny)

ui <- fluidPage(

	titlePanel("Growth Model for Stromatoporoids"),
	
	sidebarLayout(
		sidebarPanel(					
			h3("Enter the names of taxa"),
			h5("If you see an error message, you have misspelled one or more of your taxon names.", style="color:red"),
			br(),
	
			# select environment
			textInput(inputId = "taxa",
				label = "Enter a taxon or multiple taxa separated by a comma:",
				value = "Olenellus, Redlichia, Elrathia, Flexicalymene, Phacops, Kathwaia"),
			br(),
			
			# select taxonomic resolution
			selectInput(inputId = "taxonReso",
				label = "Taxonomic resolution:",
				choices = c("Phylum","Class","Order","Family","Genus","Species"),
				selected = "Genus"),
			br(),
			br(),
									
			actionButton("Run Model", "submit"),
			width=3,
		),
		
		mainPanel(					
			## Number of Sites, species and occurrences (live and dead)
			h3("Modeled Stromatoporoid Morphology"),		
			fluidRow(
				plotOutput(outputId = "rangePlot"),
				h5("Call to Paleobiology Database API:"),
				textOutput(outputId = "uriCall")
			), 
			
			h3("Data Table"),		
			fluidRow(
				tableOutput(outputId = "rangeTable")
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

