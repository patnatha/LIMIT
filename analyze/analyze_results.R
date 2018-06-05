library(optparse)
library('stringr')
source('../import_files.R')
source('analyze_helper.R')

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata"),
  make_option("--ref", type="character", default=NA, help="which to reference against"),
  make_option("--graph", action="store_true", default=FALSE)
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

#Load the graphing results
graphIt=(args[['graph']])

#Load input data
inputData = args[['input']]

if(endsWith(inputData, "combined.Rdata") || endsWith(inputData, "joined.Rdata")){
    method="full"
} else if(endsWith(inputData, "icd.Rdata")){
    method="icd"
} else if(endsWith(inputData, "med.Rdata")){
    method="med"
} else if(endsWith(inputData, "lab.Rdata")){
    method="lab"
}

print(paste("LOADING: ", inputData, sep=""))
load(inputData)

#Get the reference file to use
theRef=args[['ref']]
theRef = strsplit(theRef, ",")[[1]]

#Build the excluded list of labs
finalExluded=combineExcludedLists(parameters, method)

#Combine excluded list with post analysis set to obtain the original set
originalSet=union(cleanLabValues %>% select(pid, l_val, timeOffset, EncounterID), finalExluded)
originalSet=run_outliers(originalSet, 1)

#Calculate some reference intervals from this badboy
resultsFivePercent=run_intervals(originalSet$l_val, 0.95, 0.90)
preLimitReference = c(attr(resultsFivePercent, "lowerRefLimit"), 
                      attr(resultsFivePercent, "upperRefLimit"), 
                      attr(resultsFivePercent, "refInterval"),
                      attr(resultsFivePercent, "refInterval_Method"))

#Run the outlier detection
cleanLabValues = run_outliers(cleanLabValues, 1)
postHornLabValuesCnt = length(cleanLabValues$l_val)

#Run the 95% reference interval 
results=run_intervals(cleanLabValues$l_val, 0.95, 0.90)

#Get all the results into one line 
resultLine=write_line_append(parameters, postHornLabValuesCnt, preLimitReference, results, theRef)

#Print out the final results
print(paste("ANALYSIS_RESULTS:", resultLine, sep=""))

if(graphIt){
    if(T){
        resSplit=strsplit(resultLine, ",")[[1]]
        ciLowLow = as.numeric(resSplit[[34]])
        ciLowHigh = as.numeric(resSplit[[35]])
        ciHighLow = as.numeric(resSplit[[36]])
        ciHighHigh = as.numeric(resSplit[[37]])

        limLow = as.numeric(resSplit[[21]])
        limHigh = as.numeric(resSplit[[22]])

        limLowLow = as.numeric(resSplit[[25]])
        limLowHigh = as.numeric(resSplit[[26]])
        limHighLow = as.numeric(resSplit[[27]])
        limHighHigh = as.numeric(resSplit[[28]])

        if(is.na(ciLowLow) || ciLowLow == "NA"){
            theYMin=round(limLow * 0.50)
            ciLowLow = 0
            ciLowHigh = 0
        } else {
            theYMin=round(min(ciLowLow, limLow, limLowLow) * 0.50)
        }

        if(is.na(ciHighHigh) || ciHighHigh == "NA"){
            theYMax=round(limHigh * 1.50)
        } else {
            theYMax=round(max(ciHighHigh, limHigh, limHighHigh) * 1.50)
        }

        resultCode = resSplit[[2]]
        group = resSplit[[3]]
        sex = resSplit[[4]]
        race = resSplit[[5]]
        startTime = as.numeric(resSplit[[6]])
        if(startTime >= 3650){
            startTime = paste(startTime / 365, "years", sep="-")
        } else {
            startTime = paste(startTime, "days", sep="-")
        }
        endTime = as.numeric(resSplit[[7]])
        if(endTime >= 3650){
            endTime = paste(endTime / 365, "years", sep="-")
        } else {
            endTime = paste(endTime, "days", sep="-")
        }
        tTitle = paste(resultCode, race, sex, group, paste("(", startTime, "<=", endTime, ")", sep=""), sep="_")

        jpeg(filename=paste(dirname(inputData), "/graphs/", tools::file_path_sans_ext(basename(inputData)), "_original_barplot.jpg", sep=""))
        edges <- matrix(c(ciLowLow, ciLowHigh - ciLowLow, 
                          ciHighLow - ciLowHigh,  ciHighHigh - ciHighLow,
                          limLowLow, limLowHigh - limLowLow,
                          limHighLow - limLowHigh, limHighHigh - limHighLow), 
                          nrow=4, ncol=2, byrow=F)
        df.bar <- barplot(edges, 
                col=c(adjustcolor("red", alpha.f = 0.0),
                      adjustcolor("red", alpha.f = 0.8), 
                      adjustcolor("yellow", alpha.f = 0.0),
                      adjustcolor("yellow", alpha.f = 0.8)),
                border=NA, ylab=c("Units"), 
                names.arg = c("Gold Standard CI", "LIMIT CI"),
                xlab=c("CI (Red-Low, Yellow-High) | LIMIT (Green-Low, Blue-High)"), 
                ylim=range(pretty(c(theYMin, theYMax))), 
                main=tTitle, width=c(0.1))
        points(x = df.bar, y = c(limLow, limLow), col="green", pch=16, cex=3)
        points(x = df.bar, y = c(limHigh, limHigh), col="blue", pch=16, cex=3)
        dev.off()
    } else {
        #Find the max and min values
        theYMin=round(min(originalSet$l_val), digits=0) - 1
        theYMax=round(max(originalSet$l_val), digits=0) + 1
        theXMin=round(min(originalSet$timeOffset), digits=0) - 1
        theXMax=round(max(originalSet$timeOffset), digits=0) + 1

        #Build some plots
        jpeg(filename=paste(dirname(inputData), "/graphs/", tools::file_path_sans_ext(basename(inputData)), "_original_scatterplot.jpg", sep=""))
        origPlot=plot(originalSet$timeOffset, originalSet$l_val, main="Original Scatterplot", xlab="Time (Days)", ylab="Lab Value", col="red", xlim=c(theXMin, theXMax), ylim=c(theYMin, theYMax))
        dev.off()

        jpeg(filename=paste(dirname(inputData), "/graphs/", tools::file_path_sans_ext(basename(inputData)), "_limit_scatterplot.jpg",  sep=""))
        limitPlot=plot(cleanLabValues$timeOffset, cleanLabValues$l_val, main="Final Scatterplot", xlab="Time (Days)", ylab="Lab Value", col="red", xlim=c(theXMin, theXMax), ylim=c(theYMin, theYMax))
        dev.off()

        jpeg(filename=paste(dirname(inputData), "/graphs/", tools::file_path_sans_ext(basename(inputData)), "_excluded_scatterplot.jpg", sep=""))
        excPlot=plot(finalExluded$timeOffset, finalExluded$l_val, main="LIMIT Excluded Scatterplot", xlab="Time (Days)", ylab="Lab Value", col="green", xlim=c(theXMin, theXMax), ylim=c(theYMin, theYMax))
        dev.off()
    }
}

