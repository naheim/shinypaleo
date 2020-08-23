# drop empty species and sites
dropEmpty <- function(live, dead) {
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

simCalc <- function(live, dead) {
	if(class(live) == "numeric") {
		n <- 1
		sim <- data.frame(matrix(NA, nrow=n, ncol=3, dimnames=list("1", c("pctSim","jaccard","chao.jaccard"))))
	} else {
		n <- nrow(live)
		sim <- data.frame(matrix(NA, nrow=n, ncol=3, dimnames=list(rownames(live), c("pctSim","jaccard","chao.jaccard"))))
	}
	for(i in 1:n) {
		if(class(live) == "numeric") {
			x <- live 
			y <- dead
		} else {
			x <- live[i,] 
			y <- dead[i,]
		}
		comm <- rbind(x[x > 0 | y > 0], y[x > 0 | y > 0])
		sim$pctSim[i] <- 2*sum(apply(comm, 2, min)) / (sum(comm[1,]) + sum(comm[2,]))
		nCommon <- ncol(data.frame(comm[,comm[1,] > 0 & comm[2,] > 0])) # common
		nTotal <- ncol(comm) # all present
		sim$jaccard[i] <- nCommon / nTotal
		
		# Chao–Jaccard for two assemblages = UV/(U + V − UV)
		common <- (comm/rowSums(comm))[,comm[1,] > 0 & comm[2,] > 0]
		if(class(common)[1] == "numeric") {
			U <- common[1]
			V <- common[2]
		} else {
			U <- sum(common[1,])
			V <- sum(common[2,])
		}
		sim$chao.jaccard[i] <- U*V / (U+V-U*V)
	}
	return(sim)
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