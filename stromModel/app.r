library('shiny')
library('raster')
library('spatstat.utils')

ui <- fluidPage(

	titlePanel("Growth Model for Stromatoporoids"),
	
	sidebarLayout(
		sidebarPanel(					
			h3("Set Model Parameters"),
			h5("The model can take more than a minute to load. Please be patient after you hit the 'Run Model' button.", style="color:red"),
			br(),
			
			# Random Seed
			h4("Random Seed"),
			numericInput(inputId = "randseed",
				label = "Enter any real number",
				value = 3.141593,
				step =  0.000001),
			br(),
			
			# Geotropism
			h4("Geotropism"),
			numericInput(inputId = "geotrop",
				label = "Enter any positive number",
				value = 1,
				min=0,
				step=0.1),
			br(),
				
			# SEDIMENTATION INCREMENT
			h4("Sedimentation Increment"),
			br(),  
			sliderInput(inputId="sedIncr", 
				label = "Select a an integer between 0 and 50. If zero, no sedimentation will occur",
				min = 0, 
				max = 50,
				value = 0),
			br(),
			
			# SEDIMENTATION INTERVAL
			h4("Sedimentation Interval"),
			sliderInput(inputId="sedInt", 
				label = "Select a an integer between 0 and 50.",
				min = 0, 
				max = 50,
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
			submitButton("Run Model"),
#			actionButton("submitParams", "Run Model"),

			# data citation
			strong("Model Attribution:"),
			shiny::p("Swan, A. R. H. & Kershaw, S. 1994. A computer model for skeletal growth of stromatoporoids.", em("Palaeontology"), "37:397–408."),
			shiny::p("Model is modified from Matlab code wirtten by Tom Olszewski (",tags$a(href="https://serc.carleton.edu/NAGTWorkshops/paleo/activities/32376.html", "SERC"),")"),

			width=3,
		),
		
		mainPanel(					
			## Parameter Explanations
			h2("Explanation of Model Parameters"),
			br(),
			
			h4("Geotropism"),
			span("This determines whether the structure will preferentially grow up or laterally. Values greater than 1 increase the rate of vertical growth relative to horizontal growth (negative geotropism), while values between 0 and 1 decrease the rate of vertical growth relative to horizontal growth (positive geotropism)."),
			br(),
			
			h4("Sedimentation Increment"),
			span("This determines how much sediment deposited in a single depositional event. No deposition if zero."),
			br(), 
			
			h4("Sedimentation Interval"),
			span("This is the number of iterations between deposition events."),
			br(),
			
			h4("Sedimentation Startup"),
			span("The number of iterations before first depositional event."),
			
			
			## Number of Sites, species and occurrences (live and dead)
			h2("Modeled Stromatoporoid Morphology"),		
			fluidRow(
				plotOutput(outputId = "modelImage")
			), 
			
		)
	)
)	

server <- function(input, output, session) {	
	themodel <- reactive({
		# NUMBER OF TOTAL ITERATIONS
		# how long to run the model for
		total.iter <- 100

		# set raster size
		n.columns <- 201
		n.rows <- total.iter + 1
		row.numbers <- rev(n.columns * 1:(n.rows-1) + 1) # the first cell in each row--reversed so we count up from the bottom
		
		### SET MODEL PARAMETERS
		# RANDOM SEED
		# a random see starts the sequence of random numbers used by the model. 
		# Different values will produce slightly different results.
		set.seed(input$randseed) 

		# GEOTROPISM 
		# must be a positive number greater than zero. 
		# Values greater than 1 increase the rate of vertical growth relative to horizontal growth (negative geotropism). 
		# Values between 0 and 1 decrease the rate of vertical growth relative to horizontal growth.
		geotrop <- input$geotrop 

		# EFFECT OF SEDIMENT 
		# values greater than 1 increase the probability of accretion by cells adjacent to the sediment surface (i.e., the sponge grows faster along the sediment surface)
		eff.sed <- 0

		# SEDIMENTATION INCREMENT 
		# if deposition is occurring, how much is dumped in a single event. 
		sedIncr <- input$sedIncr
		#print(paste("sedIncr=",sedIncr, sep=""))

		# INTERVAL BETWEEN SEDIMENTATION INCREMENT 
		# number of iterations between deposition events. 
		sedInt <- input$sedInt
		#print(paste("sedInt=",sedInt, sep=""))

		# START-UP INTERVAL
		# number of iterations before first depositional event.
		startup <- input$startup


		# COLOR SWITCH
		# number of iterations before changing color
		col.switch <- 10

		### SET DATA OBJECTS AND PRINTING PREFERENCES

		# create raster for holding data
		growth <- raster(matrix(0, nrow=n.rows, ncol=n.columns), xmn=0, xmx=n.columns, ymn=0, ymx=n.rows)
		n.cells <- ncell(growth)
		growth.index <- 1:n.cells

		# set bottom row as sediment
		#growth[row.numbers[1]:(row.numbers[1]+n.columns-1)] <- 3
		
		# set initial growth cell
		growth[n.rows, median(1:n.columns)] <- 1


		#### THE MODEL
		# 0 = empty
		# 1 = filled black
		# 2 = filled gray
		# 3 = sediment

		t0 <- Sys.time()

		# initialize fill color to black (1)
		fill.color <- 1

		# get row numbers on which to make sediment deposit
		sed.bed <- 1
		sed.event <- 1
		if(sedIncr > 0) {
			sed.iter <- seq(startup, total.iter, sedInt) # the iterations in which sedimentation occurs
		} else {
			sed.iter <- rep(0, total.iter) # the iterations in which sedimentation occurs		
		}

		for(i in 1:total.iter) {
			# determine if fill color needs to be switched
			if(i %% col.switch == 0 && fill.color == 1) {
				fill.color <- 2
			} else if(i %% col.switch == 0 && fill.color == 2) {
				fill.color <- 1	
			}
	
			# get non-empty cells
			not.empty <- as.data.frame(adjacent(growth, growth.index[getValues(growth) > 0 & getValues(growth) < 3], sorted=TRUE))
			not.empty$value <- growth[not.empty[,2]]
			not.empty$rel.pos <- not.empty$from - not.empty$to
			not.empty <- subset(not.empty, value == 0)
			focal.cells <- unique(not.empty$from)
	
			# loop through non-empty cells
			for(j in focal.cells) {		
				# empty adjacent cells
				empty.adj <- subset(not.empty, from == j)
				empty.adj$rand <- runif(nrow(empty.adj)) # add column for random number
				empty.adj$P <- nrow(empty.adj)/(nrow(empty.adj)+1) # P for no geotrop.
				empty.adj$P.geo  <- 1 # ignore empty cells below if geotrop
				empty.adj$P.geo[abs(empty.adj$rel.pos) == 1] <- (1/geotrop)/((1/geotrop)+1) # P for lateral cells
				empty.adj$P.geo[empty.adj$rel.pos > 1] <- geotrop/(geotrop+1) # P for lateral cells
		
				empty.adj$new.value <- 0
				if(geotrop != 1) {
					empty.adj$new.value[empty.adj$rand <= empty.adj$P.geo] <- fill.color
				} else {
					empty.adj$new.value[empty.adj$rand <= empty.adj$P] <- fill.color
				}
				growth[empty.adj$to] <- empty.adj$new.value
			}
	
			# sedimentation
			# if enough iterations have passed
			# start at bottom row, lay down sed -- as many rows as requested
			if(sedIncr > 0 & sed.event <= length(sed.iter) & i == sed.iter[sed.event]) {
				for(j in 1:sedIncr) {
					if(sed.bed >= total.iter) break								
					# fill in from the right
					growth[row.numbers[sed.bed]:(row.numbers[sed.bed]+n.columns-1)][cumsum(growth[row.numbers[sed.bed]:(row.numbers[sed.bed]+n.columns-1)]) == 0] <- 3
					# fill in from the left
					growth[row.numbers[sed.bed]:(row.numbers[sed.bed]+n.columns-1)][revcumsum(growth[row.numbers[sed.bed]:(row.numbers[sed.bed]+n.columns-1)]) == 0] <- 3		
					sed.bed <- sed.bed + 1	
				}
				sed.event <- sed.event + 1
			}
	
			if(i %% 25 == 0) print(i)
		}
		t1 <- Sys.time()
		print(t1 - t0)

		#growth[growth == 0] <- NA
		growth
		
	})
	
	output$modelImage <- renderPlot({
		# get row numbers on which to make sediment deposit
		if(input$sedIncr > 0) plot.colors <- c("skyblue","black","darkgray","tan3") # blue water, black & gray alternating growth colors, tan sediment
		else plot.colors <- c("skyblue","black","darkgray") # blue water, black & gray alternating growth colors
		
		xLimits <- c(0, raster::ncol(themodel()))
		yLimits <- c(0, raster::nrow(themodel()))
		
		input$submitParams
		isolate({### PLOT
			# convert color matrix to raster and plot
			par(mar=c(0.2,0.2,0.2,0.2))
			plot(1:10, type="n", axes=FALSE, xlim=xLimits, ylim=yLimits, xlab="", ylab="")
			raster::plot(themodel(), col=plot.colors, legend=FALSE, add=TRUE)
		})
	})
}

shinyApp(ui = ui, server = server)

