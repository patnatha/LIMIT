library("RSQLite")
library("stringr")
source("../import_files.R")

#Parse input from command line
library(optparse)
option_list <- list(
    make_option("--input", type="character", default=NA, help="directory to load data from"),
    make_option("--output", type="character", default=NA, help="the output directory"),
    make_option("--singular-value", type="character", default=NA, help="how to select per pid")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

#Load the prepared data
input_val = args[['input']]
print(paste("Loading Data: ", input_val, sep=""))
load(input_val)

#Parse the output directory and create if doesn't exists
output_directory = args[['output']]
if(is.na(output_directory)){
    output_directory = dirname(input_val)
}

#Parse the name from input if exists
theBasename = basename(input_val)
output_filename = str_replace(paste(output_directory, theBasename, sep="/"), ".Rdata", "_selected.Rdata")
output_filename = gsub("//", "/", output_filename)
if(exists(output_filename)){
    print("ERROR: output file already exists")
    stop()
}

# Parse the singular_value parameter
singular_value = args[['singular-value']]
if(is.na(singular_value)){
    singular_value = "all"
} else if(singular_value != "random" && singular_value != "most_recent" && 
          singular_value != "all" && singular_value != "latest"){
    print("ERROR: incorrect singular_value")
    stop()
} else {
    singular_value = singular_value
}
attr(parameters, "singular_value") <- singular_value

# Obtain only one value for each PID
oldLabValuesLen = nrow(labValues)
if(singular_value == "most_recent"){
    print("SELECT THE FIRST LAB VALUE AS A REP FOR EACH PID") #OXYMORON for most_recent
    mostRecentLabValues = labValues %>% group_by(pid) %>% summarise(timeOffset=min(timeOffset))
    labValues = labValues %>% inner_join(mostRecentLabValues, by=c("pid", "timeOffset")) %>% group_by(pid) %>% sample_n(1)
    remove(mostRecentLabValues)
} else if(singular_value == "latest"){
    print("SELECT THE LATEST VALUE AS A REP FOR EACH PID")
    mostRecentLabValues = labValues %>% group_by(pid) %>% summarise(timeOffset=max(timeOffset))
    labValues = labValues %>% inner_join(mostRecentLabValues, by=c("pid", "timeOffset")) %>% group_by(pid) %>% sample_n(1)
    remove(mostRecentLabValues)
} else if(singular_value == "random"){
    print("SELECT RANDOM LAB VALUES AS REP FOR EACH PID")
    labValues = labValues %>% group_by(pid) %>% sample_n(1) %>% select(pid, l_val, EncounterID, timeOffset)
} else {
    print("SELECT ALL LAB FOR EACH PID")
}

#Down sampling code
pidSampleMax = 500000
uniquePIDs = unique(labValues$pid)
if(length(uniquePIDs) > pidSampleMax){
    print(paste("LV: Down Sample PIDs, ", length(uniquePIDs), " => ", format(pidSampleMax, scientific=FALSE), sep=""))
    randomlySelectedPIDs = sample(uniquePIDs, pidSampleMax)
    labValues = labValues %>% filter(pid %in% randomlySelectedPIDs)
    remove(randomlySelectedPIDs)
}
remove(uniquePIDs)

print(paste("SELECTED: ", oldLabValuesLen, " => ", nrow(labValues), sep=""))
save(parameters, labValues, icdValues, medValues, otherLabs, file=output_filename)
print(paste("SAVED: ", output_filename, sep=""))
