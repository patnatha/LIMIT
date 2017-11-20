library(optparse)
library(dplyr)

#Create the options list
option_list <- list(
  make_option("--med", type="character", default=NA, help="file to load Rdata"),
  make_option("--icd", type="character", default=NA, help="file to load Rdata")
)

#Parse the incoming options
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)

args <- parse_args(parser)
med_file = args[['med']]
icd_file = args[['icd']]

#Load up the results from limit algorithm using Meds
load(med_file)
medLabValues = cleanLabValues

#Load up the results from limit algorithm using ICDs
icd_results = load(icd_file)
icdLabValues = cleanLabValues

#Join the results
cleanLabValues=inner_join(icdLabValues, medLabValues, by=c("pid", "l_val", "timeOffset", "EncounterID"))

#Create the output directory name
saving=dirname(med_file)
name_parts=strsplit(basename(med_file), "_")[[1]]
finName=paste(paste(name_parts[1:length(name_parts)-1], collapse="_", sep=""), "_joined.Rdata", collapse="",sep="")
saving=paste(saving, "/", finName, sep="")

#Save the results to disk
parameters<-1:2
attr(parameters, "med_file") <- med_file
attr(parameters, "icd_file") <- icd_file
save(cleanLabValues, parameters, file=saving)

