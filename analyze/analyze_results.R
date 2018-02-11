library(optparse)
source('../import_files.R')
source('analyze_helper.R')

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

#Load input data
inputData = args[['input']]
print(paste("LOADING: ", inputData, sep=""))
load(inputData)

#Build the output file name and check for availability
theResultFile = paste(dirname(inputData), "analysis_results.csv", sep="/")
writeToFile = file.exists(theResultFile)

#Build the excluded list of labs
finalExluded=combineExcludedLists(parameters)

#Combine excluded list with post analysis set to obtain the original set
originalSet=union(cleanLabValues %>% select(pid, l_val, timeOffset, EncounterID), finalExluded)

#Calculate some reference intervals from this badboy
resultsFivePercent=run_intervals(originalSet$l_val, 0.95, 0.90)
resultsTenPercent=run_intervals(originalSet$l_val, 0.90, 0.90)
preLimitReference = c(attr(resultsFivePercent, "lowerRefLimit"), 
                      attr(resultsTenPercent, "lowerRefLimit"),
                      attr(resultsTenPercent, "upperRefLimit"), 
                      attr(resultsFivePercent, "upperRefLimit"), 
                      attr(resultsFivePercent, "refInterval"),
                      attr(resultsFivePercent, "refInterval_Method"))

#Run the outlier detection
cleanLabValues = run_outliers(cleanLabValues, 2)
postHornLabValuesCnt = length(cleanLabValues$l_val)

#Run the 90% reference interval 
refInterval =  0.95
confInterval = 0.90
results=run_intervals(cleanLabValues$l_val, refInterval, confInterval)
if(writeToFile){
    write_line_append(parameters, postHornLabValuesCnt, preLimitReference, results)
}

#Run the 90% reference interval
refInterval = 0.90
confInterval = 0.90
results=run_intervals(cleanLabValues$l_val, refInterval, confInterval)
if(writeToFile){
    write_line_append(parameters, postHornLabValuesCnt, preLimitReference, results)
}

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
