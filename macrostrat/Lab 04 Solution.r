# read in packages
packages.marine <- read.csv(file="https://macrostrat.org/api/sections?project_id=1,7&lith_class=sedimentary&environ_class=marine&interval_name=Phanerozoic&format=csv", header=TRUE)

# read in timescale (international ages)
# note the use of URLencode, which is needed to convert the space in international ages to unicode
timescale <- read.csv(file=URLencode("https://macrostrat.org/api/defs/intervals?timescale=international ages&format=csv"), header=TRUE)
nBins <- nrow(timescale)

summaryData <- data.frame('interval'=timescale$name, 'ageMid'=apply(cbind(timescale$b_age, timescale$t_age), 1, mean), 'nPkg'=NA, 'nColl'=NA, 'nFossiliferous'=NA, 'nTrunc'=NA, 'nInit'=NA)

for(i in 1:nBins) {
	tempPkg <- subset(packages.marine, b_age > timescale$t_age[i] & t_age < timescale$b_age[i])
	summaryData$nPkg[i] <- nrow(tempPkg)
	summaryData$nColl[i] <- sum(tempPkg$pbdb_collections)
	summaryData$nFossiliferous[i] <- nrow(subset(tempPkg, pbdb_collections > 0))
	
	tempTrunc <- subset(tempPkg, t_age >= timescale$t_age[i] & t_age < timescale$b_age[i])
	summaryData$nTrunc[i] <- nrow(tempTrunc)
	
	tempInit <- subset(tempPkg, b_age > timescale$t_age[i] & b_age <= timescale$b_age[i])
	summaryData$nInit[i] <- nrow(tempInit)
	
}

quartz(height=6, width=12)
par(mfrow=c(1,3), las=1, pch=16)
plot(summaryData$ageMid, summaryData$nPkg, type="l", xlim=c(541,0), xlab="Geologic time (Ma)", ylab="Number of marine packages")
plot(summaryData$ageMid, summaryData$nColl, type="l", xlim=c(541,0), xlab="Geologic time (Ma)", ylab="Number of PBDB collections")
plot(summaryData$ageMid, summaryData$nFossiliferous/summaryData$nPkg, type="l", xlim=c(541,0), xlab="Geologic time (Ma)", ylab="Proportion of fossilifeous packages")



### Now for non-marine rocks -- hint you can copy and paste above code, then just replace the environ_class in the packages call (and delete the timescale, you can use the one from above)
### I also gave my summary data frame a new name, just to keep both
# read in packages
packages.nonmarine <- read.csv(file="https://macrostrat.org/api/sections?project_id=1,7&lith_class=sedimentary&environ_class=non-marine&interval_name=Phanerozoic&format=csv", header=TRUE)


summaryDataTerr <- data.frame('interval'=timescale$name, 'ageMid'=apply(cbind(timescale$b_age, timescale$t_age), 1, mean), 'nPkg'=NA, 'nColl'=NA, 'nFossiliferous'=NA, 'nTrunc'=NA, 'nInit'=NA)

for(i in 1:nBins) {
	tempPkg <- subset(packages.nonmarine, b_age > timescale$t_age[i] & t_age < timescale$b_age[i])
	summaryDataTerr$nPkg[i] <- nrow(tempPkg)
	summaryDataTerr$nColl[i] <- sum(tempPkg$pbdb_collections)
	summaryDataTerr$nFossiliferous[i] <- nrow(subset(tempPkg, pbdb_collections > 0))
	
	tempTrunc <- subset(tempPkg, t_age >= timescale$t_age[i] & t_age < timescale$b_age[i])
	summaryDataTerr$nTrunc[i] <- nrow(tempTrunc)
	
	tempInit <- subset(tempPkg, b_age > timescale$t_age[i] & b_age <= timescale$b_age[i])
	summaryDataTerr$nInit[i] <- nrow(tempInit)
	
}

quartz(height=6, width=12)
par(mfrow=c(1,3), las=1, pch=16)
plot(summaryDataTerr$ageMid, summaryDataTerr$nPkg, type="l", xlim=c(541,0), xlab="Geologic time (Ma)", ylab="Number of non-marine packages")
plot(summaryDataTerr$ageMid, summaryDataTerr$nColl, type="l", xlim=c(541,0), xlab="Geologic time (Ma)", ylab="Number of PBDB collections")
plot(summaryDataTerr$ageMid, summaryDataTerr$nFossiliferous/summaryDataTerr$nPkg, type="l", xlim=c(541,0), xlab="Geologic time (Ma)", ylab="Proportion of fossilifeous packages")
