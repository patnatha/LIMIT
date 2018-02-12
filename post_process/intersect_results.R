library(optparse)
library(dplyr)

#Create the options list
option_list <- list(
  make_option("--med", type="character", default=NA, help="file to load Rdata"),
  make_option("--icd", type="character", default=NA, help="file to load Rdata"),
  make_option("--lab", type="character", default=NA, help="file to load Rdata")
)

#Parse the incoming options
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)

args <- parse_args(parser)
med_file = args[['med']]
icd_file = args[['icd']]
lab_file = args[['lab']]
print(paste("Loading:", icd_file, "<=>",med_file, "<=>",lab_file, sep=" "))

#Load up the results from limit algorithm using Meds
load(med_file)
medRC = attr(parameters, "resultCode")
medSelection = attr(parameters, "singular_value")
medLabValues = cleanLabValues
medPreTimeOffest = attr(parameters, "day_time_offset_pre")
medPostTimeOffest = attr(parameters, "day_time_offset_post")
medResultCode = attr(parameters, "resultCode")
medRace = attr(parameters, "race")
medGroup = attr(parameters, "group")
medSex = attr(parameters, "sex")
medStartTime = attr(parameters, "age")[1]
medEndTime = attr(parameters, "age")[2]
medLabPre = attr(parameters, "pre-limit_count")
medLabPost = nrow(cleanLabValues)
medExcludedPatients = excludedPatients
excludedMeds = rbind(excludedICDs, excludedICDNames, excludedPval)
excludedMedLabs = excludedCounts

#Load up the results from limit algorithm using ICDs
icd_results = load(icd_file)
icdRC = attr(parameters, "resultCode")
icdSelection = attr(parameters, "singular_value")
icdPreTimeOffest = attr(parameters, "day_time_offset_pre")
icdPostTimeOffest = attr(parameters, "day_time_offset_post")
icdResultCode = attr(parameters, "resultCode")
icdRace = attr(parameters, "race")
icdGroup = attr(parameters, "group")
icdSex = attr(parameters, "sex")
icdStartTime = attr(parameters, "age")[1]
icdEndTime = attr(parameters, "age")[2]
icdLabValues = cleanLabValues
icdLabPre = attr(parameters, "pre-limit_count")
icdLabPost = nrow(cleanLabValues)
icdExcludedPatients = excludedPatients
excludedICDS = rbind(excludedICDs, excludedICDNames, excludedPval)
excludedICDLabs = excludedCounts

#Load up the results from limit algorithm using Other Labs
lab_results = load(lab_file)
labRC = attr(parameters, "resultCode")
labSelection = attr(parameters, "singular_value")
labPreTimeOffest = attr(parameters, "day_time_offset_pre")
labPostTimeOffest = attr(parameters, "day_time_offset_post")
labResultCode = attr(parameters, "resultCode")
labRace = attr(parameters, "race")
labGroup = attr(parameters, "group")
labSex = attr(parameters, "sex")
labStartTime = attr(parameters, "age")[1]
labEndTime = attr(parameters, "age")[2]
labLabValues = cleanLabValues
labLabPre = attr(parameters, "pre-limit_count")
labLabPost = nrow(cleanLabValues)
labExcludedPatients = excludedPatients
excludedLabs = rbind(excludedICDs, excludedICDNames, excludedPval)
excludedLabLabs = excludedCounts

#Check for match input codes
intersect_it = FALSE
if(length(labRC) == length(icdRC) &&
   length(intersect(labRC, icdRC)) == length(labRC) &&
   length(labRC) == length(medRC) &&
   length(intersect(labRC, medRC)) == length(labRC) &&
   length(icdRC) == length(medRC) &&
   length(intersect(icdRC, medRC) == length(icdRC))){
    intersect_it = TRUE
}
if(!intersect_it){
    print("ERROR: not matching input values")
    stop()
}

#Join the results
print(paste("Joining: ", basename(icd_file), " <=> ", basename(med_file), " <=> ", basename(lab_file), sep=""))
cleanLabValues=intersect(icdLabValues, intersect(medLabValues, labLabValues))
print(paste("INTERSECTION: ", nrow(icdLabValues), "(ICD) + ", nrow(medLabValues), "(MED) + ", nrow(labLabValues), "(LAB) = ", nrow(cleanLabValues), sep=""))

#Create the output directory name
saving=dirname(med_file)
name_parts=strsplit(basename(med_file), "_")[[1]]
finName=paste(paste(name_parts[1:length(name_parts)-1], collapse="_", sep=""), "_joined.Rdata", collapse="",sep="")
saving=paste(saving, "/", finName, sep="")

#Save the results to disk
parameters<-1:1
attr(parameters, "resultCodes") <- icdRC
attr(parameters, "joined_count") = nrow(cleanLabValues)

attr(parameters, "med_file") <- med_file
attr(parameters, "med_selection") <- medSelection
attr(parameters, "med_pre_offset") <- medPreTimeOffest
attr(parameters, "med_post_offset") <- medPostTimeOffest
attr(parameters, "med_result_code") <- medResultCode
attr(parameters, "med_sex") <- medSex
attr(parameters, "med_race") <- medRace
attr(parameters, "med_group") <- medGroup
attr(parameters, "med_start_time") <- medStartTime
attr(parameters, "med_end_time") <- medEndTime 
attr(parameters, "med_pre_limit") <- medLabPre 
attr(parameters, "med_post_limit") <- medLabPost
attr(parameters, "med_excluded") <- excludedMeds
attr(parameters, "med_excluded_pid") <- medExcludedPatients
attr(parameters, "med_excluded_labs") <- excludedMedLabs

attr(parameters, "icd_file") <- icd_file
attr(parameters, "icd_selection") <- icdSelection
attr(parameters, "icd_pre_offset") <- icdPreTimeOffest
attr(parameters, "icd_post_offset") <- icdPostTimeOffest
attr(parameters, "icd_result_code") <- icdResultCode
attr(parameters, "icd_sex") <- icdSex
attr(parameters, "icd_race") <- icdRace
attr(parameters, "icd_group") <- icdGroup
attr(parameters, "icd_start_time") <- icdStartTime
attr(parameters, "icd_end_time") <- icdEndTime
attr(parameters, "icd_pre_limit") <- icdLabPre
attr(parameters, "icd_post_limit") <- icdLabPost
attr(parameters, "icd_excluded") <- excludedICDS
attr(parameters, "icd_excluded_pid") <- icdExcludedPatients
attr(parameters, "icd_excluded_labs") <- excludedICDLabs

attr(parameters, "lab_file") <- lab_file
attr(parameters, "lab_selection") <- labSelection
attr(parameters, "lab_pre_offset") <- labPreTimeOffest
attr(parameters, "lab_post_offset") <- labPostTimeOffest
attr(parameters, "lab_result_code") <- labResultCode
attr(parameters, "lab_sex") <- labSex
attr(parameters, "lab_race") <- labRace
attr(parameters, "lab_group") <- labGroup
attr(parameters, "lab_start_time") <- medStartTime
attr(parameters, "lab_end_time") <- medEndTime
attr(parameters, "lab_pre_limit") <- labLabPre
attr(parameters, "lab_post_limit") <- labLabPost
attr(parameters, "lab_excluded") <- excludedLabs
attr(parameters, "lab_excluded_pid") <- labExcludedPatients
attr(parameters, "lab_excluded_labs") <- excludedLabLabs

save(cleanLabValues, parameters, file=saving)

