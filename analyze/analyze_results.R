library(optparse)
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
print(paste("LOADING: ", inputData, sep=""))
load(inputData)

#Get the reference file to use
theRef=args[['ref']]

#Build the excluded list of labs
finalExluded=combineExcludedLists(parameters)

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
print(paste("ANALYSIS_RESULTS:", resultLine, sep=""))

if(graphIt){
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

