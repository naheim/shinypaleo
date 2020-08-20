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

# Parse Data		
parseData <- function(x, taxon, env, species, environments) {
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