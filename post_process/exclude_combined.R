library(optparse)
library(dplyr)

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata")
)

parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
input_dir = args[['input']]

masterExcludePidList = list()
masterExcludeICD = list()
masterExcludeMED = list()
masterExcludeLAB = list()
uniquePIDs = list()
filelist = list.files(input_dir, pattern = ".Rdata", full.names = TRUE)
for (tfile in filelist){
    #Load up the file
    tempLoadJoined = load(tfile)

    #Create master exclusion list
    tempExclude = unique(c(attr(parameters, "lab_exclude_pid"), attr(parameters, "icd_excluded_pid"), attr(parameters, "med_excluded_pid")))
    print(paste(basename(tfile), " to exclude: ", length(tempExclude), sep=""))
    masterExcludePidList = c(masterExcludePidList, tempExclude)

    masterExcludeICD = c(masterExcludeICD, attr(parameters, "icd_excluded")[1,])
    masterExcludeMED = c(masterExcludeMED, attr(parameters, "med_excluded")[1,])
    masterExcludeLAB = c(masterExcludeLAB, attr(parameters, "lab_excluded")[1,])

    #Keep track of total unique PIDs
    uniquePIDs = c(uniquePIDs, cleanLabValues$pid)
    uniquePIDs = unique(uniquePIDs)
}

masterExcludeICD = unique(masterExcludeICD)
masterExcludeMED = unique(masterExcludeMED)
masterExcludeLAB = unique(masterExcludeLAB)
print(paste("Unique ICDs to Exclude: ", length(masterExcludeICD), sep=""))
print(paste("Unique Meds to Exclude: ", length(masterExcludeMED), sep=""))
print(paste("Unique Labs to Exclude: ", length(masterExcludeLAB), sep=""))

masterExcludePidList = unique(masterExcludePidList)
print(paste("Unique PIDs to Exclude: ", length(masterExcludePidList), sep=""))
print(paste("Unique Clean PIDs: ", length(uniquePIDs), sep=""))

stop()
for (tfile in filelist){
    #Load up the file
    tempLoadJoined = load(tfile)

    oldCleanLabValuesLen = nrow(cleanLabValues)
    cleanLabValues = cleanLabValues %>% filter(!pid %in% masterExcludePidList)
    newCleanLabValuesLen = nrow(cleanLabValues)
    print(paste(basename(tfile), " to filter: ", oldCleanLabValuesLen, " => ", newCleanLabValuesLen, sep=""))
    save(cleanLabValues, parameters, file=tfile)
}

