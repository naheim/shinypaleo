library(shiny)
ui <- fluidPage(

	titlePanel("Live-Dead Analysis, Mugu Lagoon, California"),
	
	fluidRow(
		selectInput(inputId = "n_breaks",
				  label = "Number of bins in histogram (approximate):",
				  choices = c(10, 20, 35, 50),
				  selected = 20),

		checkboxInput(inputId = "individual_obs",
					label = strong("Show individual observations"),
					value = FALSE),

		checkboxInput(inputId = "density",
					label = strong("Show density estimate"),
					value = FALSE),
	), 
	
	fluidRow(
		plotOutput(outputId = "main_plot", height = "300px"),
	),
	
	fluidRow(
	tableOutput(outputId = "livefile"),
	), 
	
	# Display this only if the density is shown
	conditionalPanel(condition = "input.density == true",
	sliderInput(inputId = "bw_adjust",
				label = "Bandwidth adjustment:",
				min = 0.2, max = 2, value = 1, step = 0.2)
	)


)

server <- function(input, output) {
	
	liveCounts <- read.delim(file="warmeLive.tsv")[,1:match("Hemigrapsus_oregonensis", colnames(liveCounts))]
	deadCounts <- read.delim(file="warmeDead.tsv")[,1:match("Hemigrapsus_oregonensis", colnames(liveCounts))]
	output$livefile <- renderTable(liveCounts, rownames=TRUE)  
	
	output$main_plot <- reactivePlot(width = 400, height = 300, function() {

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