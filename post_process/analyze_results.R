library(optparse)
library(dplyr)
library(boot)

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata"),
  make_option("--graph", action="store_true", default=FALSE),
  make_option("--ref-interval", type="character", default="2.5", help="reference interval")
)

#Parse the incoming options
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

#Load input data
inputData = args[['input']]
load(inputData)

#Parse input arguments
toGraph = args[['graph']]
refConf = 1 - ((as.numeric(args[['ref-interval']]) * 2) / 100.0)

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

run_outliers = function(theData){
    #Iterated the horn outliers algorithm
    runs=1
    outliered = horn.outliers(theData)
    print(paste("Horn Outliers: ", runs, " (", nrow(theData), " - ", nrow(outliered), ")", sep=""))
    while(nrow(outliered) != nrow(theData) & runs < 3){
        theData = outliered
        outliered = horn.outliers(theData)
        runs=runs+1
        print(paste("Horn Outliers: ", runs, " (", nrow(theData), " - ", nrow(outliered), ")", sep=""))
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

postJoinedLabValuesCnt = attr(parameters, "icd_med_lab_joined_count")
postCombinedLabValuesCnt = length(cleanLabValues$l_val)
print(paste("Lab Values Count: ", length(cleanLabValues$l_val)))
print(paste("Unique Patient Count: ", length(unique(cleanLabValues$pid))))
print(paste("Lab Values Quantiles: ", paste(round(as.numeric(quantile(cleanLabValues$l_val, c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)), digits=2),collapse=" "), sep=""))

#Run the outlier detection
cleanLabValues = run_outliers(cleanLabValues)

postHornLabValuesCnt = length(cleanLabValues$l_val)
print(paste("Lab Values Count: ", length(cleanLabValues$l_val)))
print(paste("Unique Patient Count: ", length(unique(cleanLabValues$pid))))
print(paste("Lab Values Quartiles: ", paste(round(as.numeric(quantile(cleanLabValues$l_val, c(0.025, 0.05, 0.50, 0.95, 0.975), na.rm = TRUE)), digits=2),collapse=" "), sep=""))

#Run the boot parametric confidence interval
bootresult = boot(data = cleanLabValues$l_val, statistic = nonparRI, refConf = refConf, R = 5000)

#get the confidence intervals from the boot result
limitConf = 0.95
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

#Write the results to file if exists
if(writeToFile){
    newLine = c(basename(inputData), 
                attributes(parameters)$icd_result_code,
                gsub(",","_",attributes(parameters)$icd_group),
                attributes(parameters)$icd_sex,
                attributes(parameters)$icd_race,
                attributes(parameters)$icd_start_time,
                attributes(parameters)$icd_end_time,
                attributes(parameters)$icd_pre_limit, 
                attr(parameters, "icd_post_limit"),
                attr(parameters, "med_post_limit"), 
                attr(parameters, "lab_post_limit"),
                postJoinedLabValuesCnt,
                postCombinedLabValuesCnt,
                postHornLabValuesCnt,
                attr(parameters, "icd_pre_quantiles"),
                as.numeric(quantile(cleanLabValues$l_val, c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)),
                lowerRefLowLimit, lowerRefUpperLimit, upperRefLowLimit, upperRefUpperLimit, refConf)
    write(newLine,ncolumns=length(newLine),sep=",",file=theResultFile, append=TRUE)
}

