library(optparse)
library(dplyr)
library(boot)

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata")
)

#Parse the incoming options
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

#Load input data
inputData = args[['input']]
print(paste("LOADING: ", inputData, sep=""))
load(inputData)

#Build the list of excluded lab values
finalExludedTone=list()
if(length(attr(parameters, "lab_excluded_labs")) == 0){
    attr(parameters, "lab_excluded_labs") <- data.frame(
                 pid=character(),
                 l_val=numeric(),
                 timeOffset=numeric(),
                 EncounterID=character(),
                 stringsAsFactors=FALSE)
}

if(length(attr(parameters, "med_excluded_labs")) == 0){
    attr(parameters, "med_excluded_labs") <- data.frame(
                 pid=character(),
                 l_val=numeric(),
                 timeOffset=numeric(),
                 EncounterID=character(),
                 stringsAsFactors=FALSE)
}

if(length(attr(parameters, "icd_excluded_labs")) == 0){
    attr(parameters, "icd_excluded_labs") <- data.frame(
                 pid=character(),
                 l_val=numeric(),
                 timeOffset=numeric(),
                 EncounterID=character(),
                 stringsAsFactors=FALSE)
}

#Combine the excluded list with the cleaned lab values
finalExluded=union(
    attr(parameters, "icd_excluded_labs") %>% select(pid, l_val, timeOffset, EncounterID), 
    attr(parameters, "med_excluded_labs") %>% select(pid, l_val, timeOffset, EncounterID), 
    attr(parameters, "lab_excluded_labs") %>% select(pid, l_val, timeOffset, EncounterID))
originalSet=union(cleanLabValues %>% select(pid, l_val, timeOffset, EncounterID), finalExluded)

#Build the output file name
theResultFile = paste(dirname(inputData), "analysis_results.csv", sep="/")
writeToFile = file.exists(theResultFile)

#Run the Horn.outliers algorithm
horn.outliers = function(data){
    boxcox = car::powerTransform(data$l_val)
    lambda = boxcox$lambda
    transData = data$l_val^lambda
    descriptives = summary(transData)
    Q1 = descriptives[[2]]
    Q3 = descriptives[[5]]
    IQR = Q3 - Q1
    out = transData[transData <= (Q1 - 1.5 * IQR) | transData >= (Q3 + 1.5 * IQR)]
    sub = transData[transData > (Q1 - 1.5 * IQR) & transData < (Q3 + 1.5 * IQR)]
    lineInSand=(list(outliers = out^(1/lambda), subset = sub^(1/lambda)))
    return(data %>% filter(l_val > min(lineInSand$subset) & l_val < max(lineInSand$subset)))
}

run_outliers = function(theData, runsCnt){
    #Iterated the horn outliers algorithm
    runs=1
    outliered = horn.outliers(theData)

    while(nrow(outliered) != nrow(theData) & runs < runsCnt){
        print(paste("Horn Outliers: ", runs, " (", nrow(theData), " - ", nrow(outliered), ")", sep=""))
    print(paste("Lab Values Quartiles: ", paste(round(as.numeric(quantile(outliered$l_val, c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)), digits=2),collapse=" "), sep=""))

        theData = outliered
        outliered = horn.outliers(theData)
        runs=runs+1
    }
    theData = outliered
    return(theData)
}

#Run the boot parametric confidence interval
nonparRI = function (data, indices = 1:length(data), refConf = 0.95)
{
    d = data[indices]
    results = c(quantile(d, (1 - refConf)/2, type = 6), quantile(d,
    1 - ((1 - refConf)/2), type = 6))
    return(results)
}

print(paste("Lab Values Count: ", length(cleanLabValues$l_val)))
print(paste("Unique Patient Count: ", length(unique(cleanLabValues$pid))))
print(paste("Lab Values Quantiles: ", paste(round(as.numeric(quantile(cleanLabValues$l_val, c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)), digits=2),collapse=" "), sep=""))

#Run the outlier detection
postJoinedLabValuesCnt = attr(parameters, "icd_med_lab_joined_count")
postCombinedLabValuesCnt = length(cleanLabValues$l_val)
cleanLabValues = run_outliers(cleanLabValues, 3)
postHornLabValuesCnt = length(cleanLabValues$l_val)

print(paste("Lab Values Count: ", length(cleanLabValues$l_val)))
print(paste("Unique Patient Count: ", length(unique(cleanLabValues$pid))))
print(paste("Lab Values Quartiles: ", paste(round(as.numeric(quantile(cleanLabValues$l_val, c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)), digits=2),collapse=" "), sep=""))

#Define the boot non-parametric function
run_booty <- function(refConf){
    bootresult = boot(data = cleanLabValues$l_val, 
                      statistic = nonparRI, refConf = refConf, R = 5000)

    #get the confidence intervals from the boot result
    limitConf = 0.90
    bootresultlower = boot.ci(bootresult, conf = limitConf, type = "basic", index = 1)
    bootresultupper = boot.ci(bootresult, conf = limitConf, type = "basic", index = 2)

    #Get the upper and lower limits for limits for displaying
    lowerRefLowLimit = bootresultlower$basic[4]
    if(is.null(lowerRefLowLimit)){ lowerRefLowLimit = "NA" }
    lowerRefUpperLimit = bootresultlower$basic[5]
    if(is.null(lowerRefUpperLimit)){ lowerRefUpperLimit = "NA" }
    upperRefLowLimit = bootresultupper$basic[4]
    if(is.null(upperRefLowLimit)){ upperRefLowLimit = "NA" }
    upperRefUpperLimit = bootresultupper$basic[5]
    if(is.null(upperRefUpperLimit)){ upperRefUpperLimit = "NA" }

    print(paste("Lab Values Parametric Quantiles: ", paste(round(((1 - refConf)/2.0)*100, digits=1), "% <=CI=> ", round(100-(((1 - refConf)/2.0)*100), digits=1),"%: (", lowerRefLowLimit, "-", lowerRefUpperLimit, ") <=> (", upperRefLowLimit, "-", upperRefUpperLimit, ")", sep="")), sep="")
    
    results<-1:1
    attr(results, "lowerRefLowLimit") = lowerRefLowLimit
    attr(results, "lowerRefUpperLimit") = lowerRefUpperLimit
    attr(results, "upperRefLowLimit") = upperRefLowLimit
    attr(results, "upperRefUpperLimit") = upperRefUpperLimit
    return(results)
}

#Run the boot parametric confidence interval
results=run_booty(0.95)
lowerRefLowLimit95 = attr(results, "lowerRefLowLimit")
lowerRefUpperLimit95 = attr(results, "lowerRefUpperLimit")
upperRefLowLimit95 = attr(results, "upperRefLowLimit")
upperRefUpperLimit95 = attr(results, "upperRefUpperLimit")
results=run_booty(0.90)
lowerRefLowLimit90 = attr(results, "lowerRefLowLimit")
lowerRefUpperLimit90 = attr(results, "lowerRefUpperLimit")
upperRefLowLimit90 = attr(results, "upperRefLowLimit")
upperRefUpperLimit90 = attr(results, "upperRefUpperLimit")

#Write the results to file if exists
if(writeToFile){
    newLine = c(basename(inputData),
                paste(attributes(parameters)$icd_result_code, collapse="_"),
                gsub(",","_",attributes(parameters)$icd_group),
                attributes(parameters)$icd_sex,
                attributes(parameters)$icd_race,
                attributes(parameters)$icd_start_time,
                attributes(parameters)$icd_end_time,
                attributes(parameters)$icd_selection,
                attributes(parameters)$icd_pre_limit,
                attr(parameters, "icd_post_limit"),
                attr(parameters, "med_post_limit"),
                attr(parameters, "lab_post_limit"),
                postJoinedLabValuesCnt,
                postCombinedLabValuesCnt,
                postHornLabValuesCnt,
                attr(parameters, "icd_pre_quantiles"),
                as.numeric(quantile(cleanLabValues$l_val, c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)),
                lowerRefLowLimit95, lowerRefUpperLimit95, upperRefLowLimit95, upperRefUpperLimit95,
                lowerRefLowLimit90, lowerRefUpperLimit90, upperRefLowLimit90, upperRefUpperLimit90)
    write(newLine,ncolumns=length(newLine),sep=",",file=theResultFile, append=TRUE)
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

