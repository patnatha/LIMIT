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
inputData = args[['input']]
load(inputData)

#Build the output file name
theResultFile = paste(dirname(inputData), "analysis_results.csv", sep="/")
writeToFile = file.exists(theResultFile)

if(exists("parameters")){
    print("PARAMETERS")
    print(attributes(parameters))
}

if(exists("origLabValuesLength")){
    print(paste("Original LabValues Length:", toString(origLabValuesLength), sep=""))
}

print(paste("Lab Values Quartiles: ", paste(round(as.numeric(quantile(cleanLabValues$l_val, c(0.025, 0.05, 0.50, 0.95, 0.975), na.rm = TRUE)), digits=2),collapse=" "), sep=""))
print(paste("Lab Values Median: ", median(cleanLabValues$l_val, na.rm = FALSE)))

#Run the boot parametric confidence interval
nonparRI = function (data, indices = 1:length(data), refConf = 0.95)
{
    d = data[indices]
    results = c(quantile(d, (1 - refConf)/2, type = 6), quantile(d,
    1 - ((1 - refConf)/2), type = 6))
    return(results)
}
refConf = 0.975
limitConf = 0.95
bootresult = boot(data = cleanLabValues$l_val, statistic = nonparRI, refConf = refConf, R = 5000)

#get the confidence intervals from the boot result
bootresultlower = boot.ci(bootresult, conf = limitConf, type = "basic", index = 1)
bootresultupper = boot.ci(bootresult, conf = limitConf, type = "basic", index = 2)

#Get the upper and lower limits for limits for displaying
lowerRefLowLimit = round(bootresultlower$basic[4], digits=3)
lowerRefUpperLimit = round(bootresultlower$basic[5], digits=3)
upperRefLowLimit = round(bootresultupper$basic[4], digits=3)
upperRefUpperLimit = round(bootresultupper$basic[5], digits=3)

print(paste("Lab Values Parametric Quartiles: ", paste(round(100 - (refConf*100), digits=1), "% <=CI=> ", round(refConf*100, digits=1),"%: (", lowerRefLowLimit, "-", lowerRefUpperLimit, ") <=> (", upperRefLowLimit, "-", upperRefUpperLimit, ")", sep="")), sep="")


print(paste("Lab Values Count: ", length(cleanLabValues$l_val)))
print(paste("Unique Patient Count: ", length(unique(cleanLabValues$pid))))

#Write the results to file if exists
if(writeToFile){
    newLine = c(inputData, lowerRefLowLimit, lowerRefUpperLimit, upperRefLowLimit, upperRefUpperLimit, mean(cleanLabValues$l_val, na.rm = TRUE))
    write(newLine,ncolumns=6,sep=",",file=theResultFile, append=TRUE)
}

#Create a histogram of the results
#jpeg('hist.jpg')
#minval=round(min(as.numeric(cleanLabValues$l_val))) - 1
#maxval=round(max(as.numeric(cleanLabValues$l_val))) + 1
#hist(as.numeric(cleanLabValues$l_val), breaks=seq(minval, maxval, by=0.5), xlim=c(5,25))
#dev.off()

