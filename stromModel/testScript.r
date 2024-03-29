library('raster')
library('spatstat.utils')

# NUMBER OF TOTAL ITERATIONS
# how long to run the model for
total.iter <- 150

# set raster size
n.columns <- 451
n.rows <- total.iter + 2
row.numbers <- rev(n.columns * 1:(n.rows-1) + 1) # the first cell in each row--reversed so we count up from the bottom

### SET MODEL PARAMETERS
# RANDOM SEED
# a random see starts the sequence of random numbers used by the model. 
# Different values will produce slightly different results.
#seed <- set.seed(0) 

# GEOTROPISM 
# must be a positive number greater than zero. 
# Values greater than 1 increase the rate of vertical growth relative to horizontal growth (negative geotropism). 
# Values between 0 and 1 decrease the rate of vertical growth relative to horizontal growth.
geotrop <- 0.20 

# EFFECT OF SEDIMENT 
# values greater than 1 increase the probability of accretion by cells adjacent to the sediment surface (i.e., the sponge grows faster along the sediment surface)
eff.sed <- 0

# SEDIMENTATION INCREMENT 
# if deposition is occurring, how much is dumped in a single event. 
sed.incr <- 0

# INTERVAL BETWEEN SEDIMENTATION INCREMENT 
# number of iterations between deposition events. 
sed.int <- 0

# START-UP INTERVAL
# number of iterations before first depositional event.
startup <- 20



# COLOR SWITCH
# number of iterations before changing color
col.switch <- 8

### SET DATA OBJECTS AND PRINTING PREFERENCES

# create raster for holding data
growth <- raster(matrix(0, nrow=n.rows, ncol=n.columns), xmn=0, xmx=n.columns, ymn=0, ymx=n.rows)
n.cells <- ncell(growth)
growth.index <- 1:n.cells

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
if(sed.int > 0) {
	sed.iter <- seq(startup, total.iter, sed.int) # the iterations in which sedimentation occurs
	sed.bed <- 1
	sed.event <- 1
	plot.colors <- c("black","darkgray","tan3") # black & gray alternating growth colors, tan sediment
} else {
	# plot colors
	plot.colors <- c("black","darkgray") # black & gray alternating growth colors, tan sediment
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
		empty.adj$new.value[empty.adj$rand <= empty.adj$P.geo] <- fill.color
		
		growth[empty.adj$to] <- empty.adj$new.value
		
	}
	
	# sedimentation
	# if enough iterations have passed
	# start at bottom row, lay down sed -- as many rows as requested
	if(sed.int > 0 & i == sed.iter[sed.event]) {
		for(j in 1:sed.incr) {
			# fill in from the right
			growth[row.numbers[sed.bed]:(row.numbers[sed.bed]+n.columns-1)][cumsum(growth[row.numbers[sed.bed]:(row.numbers[sed.bed]+n.columns-1)]) == 0] <- 3
			# fill in from the left
			growth[row.numbers[sed.bed]:(row.numbers[sed.bed]+n.columns-1)][revcumsum(growth[row.numbers[sed.bed]:(row.numbers[sed.bed]+n.columns-1)]) == 0] <- 3		
			sed.bed <- sed.bed + 1
		}
		sed.event <- sed.event + 1
	}
	
	if(i %% 20 == 0) print(i)
}
t1 <- Sys.time()
print(t1 - t0)

growth.plot <- growth
growth.plot[growth.plot == 0] <- NA
growth.plot <- raster::trim(growth.plot, padding = 5)

### PLOT
# convert color matrix to raster and plot
par(mar=c(0.2,0.2,0.2,0.2))
plot(1:10, type="n", axes=F, xlim=c(0,n.columns), ylim=c(0,n.rows), xlab="", ylab="")
plot(growth.plot, col=plot.colors, legend=FALSE, add=TRUE)