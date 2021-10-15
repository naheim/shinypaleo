library('raster')

# set raster size
n.columns <- 21
n.rows <- 21

### SET MODEL PARAMETERS
# RANDOM SEED
# a random see starts the sequence of random numbers used by the model. 
# Different values will produce slightly different results.
seed <- set.seed(0) 

# GEOTROPISM 
# must be a positive number greater than zero. 
# Values greater than 1 increase the rate of vertical growth relative to horizontal growth (negative geotropism). 
# Values between 0 and 1 decrease the rate of vertical growth relative to horizontal growth.
geotrop <- 1 

# EFFECT OF SEDIMENT 
# values greater than 1 increase the probability of accretion by cells adjacent to the sediment surface (i.e., the sponge grows faster along the sediment surface)
eff.sed <- 1.5

# SEDIMENTATION INCREMENT 
# if deposition is occurring, how much is dumped in a single event. 
sed.incr <- 1

# INTERVAL BETWEEN SEDIMENTATION INCREMENT 
# number of iterations between deposition events. 
sed.int <- 5

# START-UP INTERVAL
# number of iterations before first depositional event.
startup <- 10

# COLOR SWITCH
# number of iterations before changing color
col.switch <- 8

# NUMBER OF TOTAL ITERATIONS
# how long to run the model for
total.iter <- 20

### SET DATA OBJECTS AND PRINTING PREFERENCES
# plot colors
plot.colors <- c("white","black","darkgray","tan3") # white = empty, black&gray alternating growth colors, tan sediment

# create raster for holding data
growth <- raster(matrix(0, nrow=n.rows, ncol=n.columns), xmn=0, xmx=n.columns, ymn=0, ymx=n.rows)
n.cells <- ncell(growth)

# set initial growth cell
growth[n.rows, median(1:n.columns)] <- 1


#### THE MODEL
# 0 = empty
# 1 = filled black
# 2 = filled gray
# 3 = sediment

# initialize fill color to black (1)
fill.color <- 1
for(i in 1:total.iter) {
	# determine if fill color needs to be switched
	if(total.iter %% col.switch == 0 && fill.color == 1) {
		fill.color <- 2
	} else if(total.iter %% col.switch == 0 && fill.color == 2) {
		fill.color <- 1	
	}
	
	# loop through rows and columns
	for(j in n.cells:1) {
		
		# get adjacent cells: left, right, top, bottom
		temp.adj <- adjacent(growth, j)[,2]
		
		# bottom j+1
		n.open <- vector(mode="numeric", length=4) # vector for determining which adjacent cells are open
		if(j+1 > 0 & j+1 <= n.rows ) {
			if(growth[j+1,k] == 0) n.open[1] <- 1
		}
		# left k-1
		if(k-1 > 0 & k-1 <= n.columns) {
			if(growth[j,k-1] == 0) n.open[2] <- 1			
		}
		# top j-1
		if(j-1 > 0 & j-1 <= n.rows) {
			if(growth[j-1,k] == 0) n.open[3] <- 1
		}
		# right k+1
		if(k+1 > 0 & k+1 <= n.columns) {
			if(growth[j,k+1] == 0) n.open[4] <- 1			
		}
		
		# check probabilities of filling
		p.fill <- sum(n.open)/(sum(n.open)+1) # geotropism
		
		# generate random number for each open cell
		check.probs <- runif(4) * n.open
		
		if(n.open[1] == 1 & check.probs[1] <= p.fill) growth[j+1,k] <- fill.color
		if(n.open[2] == 1 & check.probs[2] <= p.fill) growth[j,k-1] <- fill.color
		if(n.open[3] == 1 & check.probs[3] <= p.fill) growth[j-1,k] <- fill.color
		if(n.open[4] == 1 & check.probs[4] <= p.fill) growth[j,k+1] <- fill.color
	}
}


### PLOT
# convert color matrix to raster and plot
plot(growth, col=plot.colors, legend=FALSE, axes=FALSE)







