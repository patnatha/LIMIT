library(optparse)
library(data.table)
library(dplyr)
library(stringr)
source('../import_files.R')

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
input_dir = args[['input']]

theResultFile = paste(input_dir, "analysis_selection.csv", sep="/")
writtenFirstList = FALSE

filelist = list.files(input_dir, pattern = "selected_combined.Rdata", full.names = TRUE, recursive=TRUE)
listToCombine = c()
for (tfile in filelist){
    listToCombine = c(listToCombine, tfile)
}
listToCombine = data.table(path=listToCombine)
listToCombine = listToCombine %>% mutate(filename = basename(path))

for(uniqueFile in unique(listToCombine$filename)){
    print(paste("RUNNING: ", uniqueFile, sep=""))

    #Find the original filename
    basefilename = str_replace(uniqueFile, "_selected", "")
    filelist = list.files(input_dir, pattern = basefilename, full.names = TRUE, recursive=TRUE)
    load(filelist[[1]])
    originalMean = mean(as.numeric(labValues$l_val), na.rm=TRUE)
    originalCnt = length(as.numeric(labValues$l_val))
    print(paste(basefilename, ": ", originalMean, sep=""))
    remove(labValues)

    #Get the list of files to combine
    subSetToCompare = listToCombine %>% filter(filename == uniqueFile)
    aovData = NA
    for(i in 1:nrow(subSetToCompare)){
        tPath = subSetToCompare[i,]$path
        load(tPath)
        selectionVal = as.character(attr(parameters, "singular_value"))
        labValues$l_val = as.numeric(labValues$l_val)
        labValues = labValues %>% filter(!is.na(l_val))
        labValues = data.frame(group=selectionVal, labValues)

        if(typeof(aovData) == "logical"){
            aovData = labValues
        } else {
            aovData = rbind(aovData, labValues)
        }
        remove(labValues)
    }

    #Run analysis of variance
    res.aov = aov(l_val ~ group, data=aovData)
    aovPValue = unlist(summary(res.aov))["Pr(>F)1"]    
    aovFValue = unlist(summary(res.aov))["F value1"]
     
    #Run Tukeys 
    tukeys = TukeyHSD(res.aov)
    tukeyData = data.table(group=row.names(tukeys$group), tukeys$group)
    tukeyData = tukeyData[order(tukeyData$group),]
    
    additionalCols = c() 
    newLine = c(uniqueFile, originalCnt, originalMean, aovFValue, aovPValue)
    for(i in 1:nrow(tukeyData)){
        tGrp = tukeyData[i,]$group
        tDiff = tukeyData[i,]$diff
        tCIL = tukeyData[i,]$lwr
        tCIU = tukeyData[i,]$upr
        tPVal = tukeyData[i,]$p

        additionalCols = c(additionalCols, "group", "diff", "CI Low", "CI High", "p")
        newLine = c(newLine, tGrp, tDiff, tCIL, tCIU, tPVal)
    }

    if(!writtenFirstList){
        #Write the first line   
        firstLine = c("filename", "Count", "Original Mean", "ANOVA F Statistic", "ANOVA P-Value", additionalCols)
        write(firstLine,ncolumns=length(firstLine),sep=",",file=theResultFile, append=FALSE)
        writtenFirstList = TRUE
    }

    #Get the gold standard reference
    tResultCode=toupper(attributes(parameters)$icd_result_code[[1]])
    tSex=tolower(attributes(parameters)$icd_sex)
    tRace=tolower(attributes(parameters)$icd_race)
    tStime=attributes(parameters)$icd_start_time
    tEtime=attributes(parameters)$icd_end_time
    
    #Append the Gold Standard to the new line
    newLine = c(newLine) 
    write(newLine,ncolumns=length(newLine),sep=",",file=theResultFile, append=TRUE)
}

