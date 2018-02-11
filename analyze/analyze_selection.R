library(optparse)
library(data.table)
library(dplyr)

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
input_dir = args[['input']]

theResultFile = paste(input_dir, "analysis_selection.csv", sep="/")
newLine = c("filename", "ANOVA F Statistic", "ANOVA P-Value", "Tukeys Group", "Tukeys Mean Diff", "Tukeys P-Value")
write(newLine,ncolumns=length(newLine),sep=",",file=theResultFile, append=FALSE)

filelist = list.files(input_dir, pattern = "selected.Rdata", full.names = TRUE, recursive=TRUE)
listToCombine = c()
for (tfile in filelist){
    listToCombine = c(listToCombine, tfile)
}
listToCombine = data.table(path=listToCombine)
listToCombine = listToCombine %>% mutate(filename = basename(path))

for(uniqueFile in unique(listToCombine$filename)){
    print(paste("RUNNING: ", uniqueFile, sep=""))

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
    }

    #Run analysis of variance
    res.aov = aov(l_val ~ group, data=aovData)
    aovPValue = unlist(summary(res.aov))["Pr(>F)1"]    
    aovFValue = unlist(summary(res.aov))["F value1"]

    #Run Tukeys 
    tukeys = TukeyHSD(res.aov)
    tukeyData = data.table(group=row.names(tukeys$group), tukeys$group)
    
    #Write the results
    for(i in 1:nrow(tukeyData)){
        tGrp = tukeyData[i,]$group
        tDiff = tukeyData[i,]$diff
        tPVal = tukeyData[i,]$p
        newLine = c(uniqueFile, aovFValue, aovPValue, tGrp, tDiff, tPVal)
        write(newLine,ncolumns=length(newLine),sep=",",file=theResultFile, append=TRUE)
    }
}


