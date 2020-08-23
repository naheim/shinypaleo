# Parse Data		
source("../liveDead/R/utils.r")

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

taModel <- function(nT, pDest, pImmig, pDeath) {
	#nT <- 100
	#pDest <- 0.02
	#pImmig <- 0.25
	#pDeath <- 0.1
	
	species <- read.delim(file="../liveDead/warmeSpecies.tsv")
	species <- subset(species, Phylum == 'Mollusca') # include only mollusca
	
	liveIn <- read.delim(file="../liveDead/warmeLive.tsv")
	# drop non-molluscan taxa and those not identified to species
	liveIn <- liveIn[,is.element(colnames(liveIn), species$colName) & !grepl("_sp", colnames(liveIn))]
	
	deadIn <- read.delim(file="../liveDead/warmeDead.tsv")
	# drop non-molluscan taxa and those not identified to species
	deadIn[,deadIn$Class == 'Bivalvia'] <- floor(deadIn[,species$Class == 'Bivalvia']/2)
	deadIn <- deadIn[,is.element(colnames(deadIn), species$colName) & !grepl("_sp", colnames(deadIn))]
	
	metaComm <- rep(names(colSums(deadIn)), colSums(deadIn))

	liveCom <- colSums(liveIn[match(c("site_25","site_26","site_27","site_28"), rownames(liveIn)),])
	deadCom <- colSums(deadIn[match(c("site_25","site_26","site_27","site_28"), rownames(deadIn)),])

	# initial conditions
	initAssemb <- rbind(liveCom, deadCom)
	initSim <- simCalc(initAssemb[1,initAssemb[1,]>0 | initAssemb[2,]>0], initAssemb[2,initAssemb[1,]>0 | initAssemb[2,]>0])
	initStats <- data.frame("deadS_liveS"=length(unique(deadCom))/length(unique(liveCom)),"jaccard"=initSim$jaccard,"chao.jaccard"=initSim$chao.jaccard)
	
	liveCom <- rep(names(liveCom), liveCom)
	deadCom <- rep(names(deadCom), deadCom)
	
	livingAssemb <- sample(liveCom, length(liveCom))
	deathAssemb <- sample(deadCom, length(deadCom))
	
	output <- data.frame(matrix(NA, nrow=nT, ncol=3, dimnames=(list(1:nT, c("deadS_liveS","jaccard","chao.jaccard")))))
	
	for(i in 1:nT) {
		# decay death assemblage
		deathCount <- table(deathAssemb)
		pTemp <- runif(length(deathAssemb))
		destroyed <- table(factor(deathAssemb[pTemp < pDest], levels=names(deathCount)))
		deathAssemb <- rep(names(deathCount - destroyed), deathCount - destroyed)
		
		# add new dead individuals to death assemblage
		pTemp <- runif(length(livingAssemb))
		died <- livingAssemb[pTemp < pDeath]
		deathAssemb <- c(deathAssemb, died)
		deathAssemb <- sample(deathAssemb, length(deathAssemb))
		
		#remove dead individuals from living assemblage
		livingCount <- table(livingAssemb)
		diedCount <- table(factor(died, levels=names(livingCount)))
		livingAssemb <- rep(names(livingCount - diedCount), livingCount - diedCount)
		
		# add new births and immigrations
		birth_immig <- runif(length(died))
		born <- sample(livingAssemb, length(birth_immig[birth_immig < 1-pImmig]), replace=TRUE) 
		immigrants <- sample(metaComm, length(died)-length(born))
		if(length(born) > 0) {
			livingAssemb <- c(livingAssemb, born)
		}
		if(length(immigrants) > 0) {
			livingAssemb <- c(livingAssemb, immigrants)
		}
		livingAssemb <- sample(livingAssemb, length(livingAssemb))
		
		# get stats
		finalLive <- as.numeric(table(factor(livingAssemb, levels=unique(metaComm))))
		finalDead <- as.numeric(table(factor(deathAssemb, levels=unique(metaComm))))
			
		simStats <- simCalc(finalLive, finalDead)
		output$deadS_liveS[i] <- length(unique(deathAssemb))/length(unique(livingAssemb))
		output$jaccard[i] <- simStats$jaccard
		output$chao.jaccard[i] <- simStats$chao.jaccard


	}
	output <- rbind(initStats, output)
	#return(output)
}