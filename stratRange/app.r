library(shiny)
source("R/utils.r")

ui <- fluidPage(

	titlePanel("Stratigraphic Ranges from the PBDB"),
	
	sidebarLayout(
		sidebarPanel(					
			h3("Please be patient, page may take a few seconds to load", style="color:red"),
			h5("Wiat until you see graphs appear", style="color:red"),
			br(),
	
			# select environment
			selectInput(inputId = "taxa",
				label = "Environment:",
				choices = c("all","intertidal sand flat","subtidal eel grass"),
				selected = "all"),
			br(),
	
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

		)
	)
)	

server <- function(input, output, session) {
	

}

shinyApp(ui = ui, server = server)

