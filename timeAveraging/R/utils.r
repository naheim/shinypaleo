# Parse Data		
parseData <- function(x, region) {	
	if(region == "all") {
		ages <- x
	} else {
		ages <- subset(x, Region == region)
	}
	return(ages)
}

topLabel <- function(region) {	
	if(region == "all") {
		topLabel <- "Viewing Nuculana taphria specimens from all regions."
	} else {
		topLabel <- paste0("Viewing specimens from the ", region, " region.")
	}
	return(topLabel)
}