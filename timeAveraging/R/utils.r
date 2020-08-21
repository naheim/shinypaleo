# Parse Data		
parseData <- function(x, region) {	
	if(region == "all") {
		ages <- x
	} else if(region == "all but San Diego") {
		ages <- subset(x, Region != "San Diego")
	} else {
		ages <- subset(x, Region == region)
	}
	return(ages)
}

topLabel <- function(region) {	
	if(region == "all") {
		topLabel <- "Viewing specimens from all regions."
	} else if(region == "all but San Diego") {
		topLabel <- "Viewing specimens from all regions, except San Diego."
	} else {
		topLabel <- paste0("Viewing specimens from the ", region, " region.")
	}
	return(topLabel)
}