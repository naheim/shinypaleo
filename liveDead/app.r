library(shiny)
ui <- fluidPage(

	titlePanel("Live-Dead Analysis, Mugu Lagoon, California"),
	
	sidebarLayout(

		sidebarPanel(
			h3("Make Selections"),
			br(),
			
			selectInput(inputId = "n_breaks",
				label = "Number of bins in histogram (approximate):",
				choices = c(10, 20, 35, 50),
				selected = 20),
			br(),
					
			sliderInput("obs", "Number of observations:",  min = 1, max = 1000, value = 500),
			
			width=3,
		),

		mainPanel(
			fluidRow(

				column(3, checkboxInput(inputId = "individual_obs",
					label = strong("Show individual observations"),
					value = FALSE),
				),

				column(3, checkboxInput(inputId = "density",
					label = strong("Show density estimate"),
					value = FALSE),
				)
			), 
	
			fluidRow(
				plotOutput(outputId = "main_plot", height = "300px"),
			),
			
			# Display this only if the density is shown
			conditionalPanel(condition = "input.density == true",
			sliderInput(inputId = "bw_adjust",
						label = "Bandwidth adjustment:",
						min = 0.2, max = 2, value = 1, step = 0.2)
			),
			
			
			fluidRow(
				h3("Map of Mugu Lagoon with Sample Locations"),
				strong("Click on Map to download a larger version."),
				a(img(src='Warme1971_Map2.png', height = 805, width = 1000), href="https://github.com/naheim/shinypaleo/blob/master/liveDead/www/Warme1971_Map2.png?raw=true"),
			),
			
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
	
	
	output$livefile <- renderTable(liveCounts, rownames=TRUE)  
	
	output$main_plot <- renderPlot(width = 400, height = 300, {

		hist(faithful$eruptions,
		  probability = TRUE,
		  breaks = as.numeric(input$n_breaks),
		  xlab = "Duration (minutes)",
		  main = "Geyser eruption duration BOOM!")

		if (input$individual_obs) {
		  rug(faithful$eruptions)
		}

		if (input$density) {
		  dens <- density(faithful$eruptions, adjust = input$bw_adjust)
		  lines(dens, col = "blue")
		}

	}
	)

}

shinyApp(ui = ui, server = server)