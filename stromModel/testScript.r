library('raster')
library('spatstat.utils')

# CUSTOM FUNCTIONS
adj.vals <- function(cellpos, rasobj, refcell, include.sed=FALSE) {
	# adjacent returns cells relative to focal: left, right, top, bottom
	neighbors <- data.frame(adjacent(rasobj, cellpos)) # get adjacent cells
	neighbors$pos <- c("left","right","top","bottom") # add positions
	neighbors$vals <- rasobj[neighbors$to] # get values
	ref <- subset(neighbors, to == refcell) # get focal cell
	neighbors <- subset(neighbors, to != refcell) # remove focal cell
	
	if(include.sed == FALSE) {
		if(ref$pos == "bottom" & sum(neighbors$vals) == 0) {
			x <- "above_all_empty"
		} else if(is.element(ref$pos, c("right","left")) & sum(neighbors$vals) == 0) {
			x <- "lateral_all_empty"
		} else {
			x <- "other"
		}
	} else {
		if(ref$pos == "bottom" & sum(is.element(neighbors$vals, c(0,3))) == 3) {
			x <- "above_all_empty"
		} else if(is.element(ref$pos, c("right","left")) & sum(is.element(neighbors$vals, c(0,3))) == 3) {
			x <- "lateral_all_empty"
		} else {
			x <- "other"
		}
	}
	#print(neighbors)
	return(x)	
}

# NUMBER OF TOTAL ITERATIONS
# how long to run the model for
total.iter <- 50

# set raster size
n.columns <- 201
n.rows <- total.iter + 1
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
geotrop <- 0.2 

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
startup <- 20



# COLOR SWITCH
# number of iterations before changing color
col.switch <- 4

### SET DATA OBJECTS AND PRINTING PREFERENCES
# plot colors
if(sed.int > 0) {
	plot.colors <- c("black","darkgray","tan3") # black & gray alternating growth colors, tan sediment
} else {
	plot.colors <- c("black","darkgray") # black & gray alternating growth colors--no sediment
}

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
sed.iter <- seq(startup, total.iter, sed.int) # the iterations in which sedimentation occurs
sed.bed <- 1
sed.event <- 1

for(i in 1:total.iter) {
	# determine if fill color needs to be switched
	if(i %% col.switch == 0 && fill.color == 1) {
		fill.color <- 2
	} else if(i %% col.switch == 0 && fill.color == 2) {
		fill.color <- 1	
	}
	
	# get non-empty cells
	not.empty <- as.data.frame(adjacent(growth, growth.index[getValues(growth) > 0 & getValues(growth) < 3], sorted=TRUE)) # get cells that are adjacent to non-empty cells -- excluding sediment
	not.empty$value <- growth[not.empty[,2]] # add vector of current value of adjacent cell
	not.empty$rel.pos <- not.empty$from - not.empty$to # gets the relative position of adjacent cell to focal cell: 1=left, -1=right; << -1 = below, >> 1 = above
	
	if(eff.sed == 1 & sed.incr > 0) {
		not.empty <- subset(not.empty, value == 0) # remove all non-empty cells
	} else {
		not.empty <- subset(not.empty, value == 0 | value == 3) # remove all non-empty cells that are not sediment
	}
	focal.cells <- unique(not.empty$from) # vector of focal cells
	
	# loop through non-empty cells
	for(j in focal.cells) {		
		# empty adjacent cells
		empty.adj <- subset(not.empty, from == j) # non empty cells adjacent to focal cell
		
		if(eff.sed == 1 & sed.incr > 0) {
			x <- growth[c(empty.adj[,2]-n.columns)]
			if(x == 3) x <- 0
			empty.adj$above.val <- x
			
			x <- growth[empty.adj[,2]-1]
			x[x==3] <- 0
			y <- growth[empty.adj[,2]+1]
			y[y==3] <- 0
			empty.adj$lat.val <- x+y
		} else {
			empty.adj$above.val <- growth[c(empty.adj[,2]-n.columns)]
			empty.adj$lat.val <- growth[empty.adj[,2]-1] + growth[empty.adj[,2]+1]
		}
		
		
		
		#empty.adj$neigh.val <- sapply(empty.adj[,2], adj.vals, rasobj=growth, refcell=j)
		empty.adj$rand <- runif(nrow(empty.adj)) # add column for random number		
		P <- nrow(empty.adj)/(nrow(empty.adj)+1) # P for no geotrop.
		empty.adj$P <- P
		
		empty.adj$P.geo  <- 1 # ignore empty cells below if geotrop
		#empty.adj$P.geo[abs(empty.adj$rel.pos) == 1 & empty.adj$neigh.val == "lateral_all_empty"] <- (1/geotrop)/((1/geotrop)+1) # P for lateral cells
		#empty.adj$P.geo[abs(empty.adj$rel.pos) == 1 & empty.adj$neigh.val == "other"] <- P # P for lateral cells with 
		#empty.adj$P.geo[empty.adj$rel.pos > 1 & empty.adj$neigh.val == "above_all_empty"] <- geotrop/(geotrop+1) # P for cells above cells
		#empty.adj$P.geo[empty.adj$rel.pos > 1 & empty.adj$neigh.val == "other"] <- P # P for cells above cells
		
		empty.adj$new.value <- 0
		empty.adj$new.value[empty.adj$rand <= empty.adj$P.geo] <- fill.color
		
		growth[empty.adj$to] <- empty.adj$new.value
		
	}
	
	# sedimentation
	# if enough iterations have passed
	# start at bottom row, lay down sed -- as many rows as requested
	if(i == sed.iter[sed.event]) {
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







