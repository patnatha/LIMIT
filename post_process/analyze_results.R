library(optparse)
library(dplyr)
library(boot)

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata"),
  make_option("--graph", action="store_true", default=FALSE)
)

#Parse the incoming options
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)

args <- parse_args(parser)
inputData = args[['input']]
load(inputData)

toGraph = args[['graph']]

#Build the output file name
theResultFile = paste(dirname(inputData), "analysis_results.csv", sep="/")
writeToFile = file.exists(theResultFile)

if(exists("parameters")){
    print("PARAMETERS")
    print(attributes(parameters))
}

if(exists("origLabValuesLength")){
    print(paste("Original LabValues Length: ", toString(origLabValuesLength), sep=""))
}

print(paste("Lab Values Quartiles: ", paste(round(as.numeric(quantile(cleanLabValues$l_val, c(0.025, 0.05, 0.50, 0.95, 0.975), na.rm = TRUE)), digits=2),collapse=" "), sep=""))
print(paste("Lab Values Median: ", median(cleanLabValues$l_val, na.rm = FALSE)))

if(toGraph){
    #Create a histogram of the results
    jpeg('pre_process_hist.jpg')
    minval=round(min(as.numeric(cleanLabValues$l_val))) - 1
    maxval=round(max(as.numeric(cleanLabValues$l_val))) + 1
    hist(as.numeric(cleanLabValues$l_val), breaks=seq(minval, maxval, by=0.5), xlim=c(5,25))
    dev.off()
}

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

#Iterated the horn outliers algorithm
runs=1
outliered = horn.outliers(cleanLabValues)
print(paste("Horn Outliers: ", runs, " (", nrow(cleanLabValues), " - ", nrow(outliered), ")", sep=""))
while(nrow(outliered) != nrow(cleanLabValues) & runs < 10){
    cleanLabValues = outliered
    outliered = horn.outliers(cleanLabValues)
    runs=runs+1
    print(paste("Horn Outliers: ", runs, " (", nrow(cleanLabValues), " - ", nrow(outliered), ")", sep=""))
}
cleanLabValues = outliered

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
refConf = 0.95
bootresult = boot(data = cleanLabValues$l_val, statistic = nonparRI, refConf = refConf, R = 5000)

#get the confidence intervals from the boot result
limitConf = 0.95
bootresultlower = boot.ci(bootresult, conf = limitConf, type = "basic", index = 1)
bootresultupper = boot.ci(bootresult, conf = limitConf, type = "basic", index = 2)

#Get the upper and lower limits for limits for displaying
lowerRefLowLimit = bootresultlower$basic[4]
lowerRefUpperLimit = bootresultlower$basic[5]
upperRefLowLimit = bootresultupper$basic[4]
upperRefUpperLimit = bootresultupper$basic[5]

print(paste("Lab Values Parametric Quartiles: ", paste(round(((1 - refConf)/2.0)*100, digits=1), "% <=CI=> ", round(100-(((1 - refConf)/2.0)*100), digits=1),"%: (", lowerRefLowLimit, "-", lowerRefUpperLimit, ") <=> (", upperRefLowLimit, "-", upperRefUpperLimit, ")", sep="")), sep="")


print(paste("Lab Values Count: ", length(cleanLabValues$l_val)))
print(paste("Unique Patient Count: ", length(unique(cleanLabValues$pid))))

#Write the results to file if exists
if(writeToFile){
    newLine = c(basename(inputData), attributes(parameters)$icd_pre_limit, length(cleanLabValues$l_val), lowerRefLowLimit, lowerRefUpperLimit, upperRefLowLimit, upperRefUpperLimit, mean(cleanLabValues$l_val, na.rm = TRUE))
    write(newLine,ncolumns=8,sep=",",file=theResultFile, append=TRUE)
}

if(toGraph){
    #Create a histogram of the results
    jpeg('post_process_hist.jpg')
    minval=round(min(as.numeric(cleanLabValues$l_val))) - 1
    maxval=round(max(as.numeric(cleanLabValues$l_val))) + 1
    hist(as.numeric(cleanLabValues$l_val), breaks=seq(minval, maxval, by=0.5), xlim=c(5,25))
    dev.off()
}
