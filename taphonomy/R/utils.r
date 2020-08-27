# drop empty species and sites
dropEmpty <- function(live, dead, easteregg=NULL) {
	# drop empty species
	temp1 <- colSums(live)
	temp2 <- colSums(dead)
	live <- live[, temp1 > 0 | temp2 > 0]
	dead <- dead[, temp1 > 0 | temp2 > 0]
	
	# drop empty sites
	temp1 <- rowSums(live)
	temp2 <- rowSums(dead)
	live <- live[temp1 > 0 | temp2 > 0, ]
	dead <- dead[temp1 > 0 | temp2 > 0, ]

	return(list('live'=live, 'dead'=dead))
}

# Parse Data -- live dead	
parseDataLiveDead <- function(x, taxon, env, species, environments) {
	if(env == "subtidal eel grass") {
		myEnv <- "sub_eelgrass"
	} else if(env == "intertidal sand flat") {
		myEnv <- "inter_barren"
	}
	
	# select taxa
	if(taxon != "all") {
		xReduced <- x[,is.element(colnames(x), species$colName[species$Class == taxon])]
	} else {
		xReduced <- x
	}
	
	# select environment
	if(env != "all") {
		xReduced <- xReduced[environments[2,] == myEnv,]
	}
	
	return(xReduced)
}

simMeasures <- function(x,y) {
	comm <- rbind(x[x > 0 | y > 0], y[x > 0 | y > 0])
	common <- comm[,comm[1,] > 0 & comm[2,] > 0]
	commonPct <- (comm/rowSums(comm))[,comm[1,] > 0 & comm[2,] > 0]
	
	# bray-curtis
	bray.curtis <- sum(abs(x-y))/sum(comm)
	if(is.null(dim(common))) {
		U <- commonPct[1]
		V <- commonPct[2]
		bray.curtis2 <- 1 - 2*min(common)/sum(comm)
	} else {
		U <- sum(commonPct[1,])
		V <- sum(commonPct[2,])
		bray.curtis2 <- 2*sum(apply(common, 2, min))/sum(comm)
	}

	# pct Sim
	pctSim <- 2*sum(apply(comm, 2, min)) / (sum(comm[1,]) + sum(comm[2,]))
	nCommon <- ncol(data.frame(comm[,comm[1,] > 0 & comm[2,] > 0])) # common
	nTotal <- ncol(comm) # all present

	#jaccard
	jaccard <- nCommon / nTotal

	# Chao–Jaccard for two assemblages = UV/(U + V − UV)
	chao.jaccard <- U*V / (U+V-U*V)
	
	sim <- c(bray.curtis2, bray.curtis, pctSim, jaccard, chao.jaccard)
	names(sim) <- c('bray.curtis2','bray.curtis','pctSim','jaccard','chao.jaccard')
	return(sim)
}

simCalc <- function(live, dead=NULL, easteregg=NULL) {
	if(is.null(dead)) {
		combos <- combn(1:nrow(live),2)
		sim <- sapply(seq.int(ncol(combos)), function(i) simMeasures(live[combos[1,i],], live[combos[2,i],]), simplify=TRUE)
		#sim <- combn(live, 2, simMeasures(live))	
	} else if(is.element(class(live), c("integer","numeric"))) {
		sim <- simMeasures(live, dead)
	} else {
		sim <- sapply(seq.int(nrow(live)), function(i) simMeasures(live[i,], dead[i,]), simplify=TRUE)
	}
	return(as.data.frame(t(sim)))
}

# Parse Data--time averaging
parseDataTimeAvg <- function(x, region) {	
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
	#pDeath <- 0.9
	
	species <- read.delim(file="warmeSpecies.tsv")
	species <- subset(species, Phylum == 'Mollusca') # include only mollusca
	
	deadIn <- read.delim(file="warmeLive.tsv")
	# drop non-molluscan taxa and those not identified to species
	deadIn[,species$Class == 'Bivalvia'] <- floor(deadIn[,species$Class == 'Bivalvia']/2)
	deadIn <- deadIn[,is.element(colnames(deadIn), species$colName) & !grepl("_sp", colnames(deadIn))]
	
	metaComm <- rep(names(colSums(deadIn)), colSums(deadIn))
	#print(paste("The metacommunity has ",length(metaComm)," individuals & ",length(unique(metaComm)), " species."))
	liveCom <- table(factor(sample(metaComm, 200, replace=TRUE), levels=unique(metaComm)))
	deadCom <- table(factor(sample(metaComm, 2000, replace=TRUE), levels=unique(metaComm)))
	initAssemb <- rbind(liveCom, deadCom)

	initLive <- rep(names(liveCom), liveCom)
	initDead <- rep(names(deadCom), deadCom)
	
	# initial conditions	
	initSim <- simCalc(initAssemb[1,initAssemb[1,]>0 | initAssemb[2,]>0], initAssemb[2,initAssemb[1,]>0 | initAssemb[2,]>0])
	
	initStats <- data.frame("deadN"=length(initDead),"liveN"=length(initLive),"deadS"=length(unique(initDead)),"liveS"=length(unique(initLive)),"deadS_liveS"=length(unique(sample(initDead,100)))/length(unique(sample(initLive,100))),"jaccard"=initSim$jaccard,"chao.jaccard"=initSim$chao.jaccard,"bray.curtis"=initSim$bray.curtis,"deltaSimInit"=NA)
	
	liveCom <- rep(names(liveCom), liveCom)
	deadCom <- rep(names(deadCom), deadCom)
	
	livingAssemb <- sample(liveCom, length(liveCom))
	deathAssemb <- sample(deadCom, length(deadCom))
	
	output <- data.frame(matrix(NA, nrow=nT, ncol=9, dimnames=(list(1:nT, c("deadN","liveN","deadS","liveS","deadS_liveS","jaccard","chao.jaccard","bray.curtis","deltaSimInit")))))
	
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
		output$deadS_liveS[i] <- length(unique(sample(deathAssemb,100)))/length(unique(sample(livingAssemb,100)))
		output$liveN[i] <- length(livingAssemb)
		output$deadN[i] <- length(deathAssemb)
		output$liveS[i] <- length(unique(livingAssemb))
		output$deadS[i] <- length(unique(deathAssemb))
		output$jaccard[i] <- simStats$jaccard
		output$chao.jaccard[i] <- simStats$chao.jaccard
		output$bray.curtis[i] <- simStats$bray.curtis
		
		# delta similarity from init
		deltaSim <- simCalc(initAssemb[1,initAssemb[1,]>0 | finalLive > 0], finalLive[initAssemb[1,]>0 | finalLive > 0])
		output$deltaSimInit[i] <- deltaSim$chao.jaccard
	}
	output <- rbind(initStats, output)
	#print(tail(output))
	return(output)
}