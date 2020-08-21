# Parse Data		
parseData <- function(x, region) {
	
	if(region == "all") {
		ages <- x
	} else {
		ages <- subset(x, Region == region)
	}
	return(ages)
}