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

#Load up the results from limit algorithm using Meds
load(med_file)
medLabValues = cleanLabValues
medResultCode = attr(parameters, "resultCode")
medStartTime = attr(parameters, "resultStart")
medEndTime = attr(parameters, "resultEnd")
medLabPre = attr(parameters, "pre-limit_count")
medPreQuantile = attr(parameters, "pre-limit_quantiles")
medLabPost = nrow(cleanLabValues)
medPostQuantile = as.numeric(quantile(cleanLabValues$l_val, c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE))
medExcludedPatients = excludedPatients
excludedMeds = rbind(excludedICDs, excludedICDNames)

#Load up the results from limit algorithm using ICDs
icd_results = load(icd_file)
icdResultCode = attr(parameters, "resultCode")
icdStartTime = attr(parameters, "resultStart")
icdEndTime = attr(parameters, "resultEnd")
icdLabValues = cleanLabValues
icdLabPre = attr(parameters, "pre-limit_count")
icdPreQuantile = attr(parameters, "pre-limit_quantiles")
icdLabPost = nrow(cleanLabValues)
icdPostQuantile = as.numeric(quantile(cleanLabValues$l_val, c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE))
icdExcludedPatients = excludedPatients
excludedICDS = rbind(excludedICDs, excludedICDNames)

#Load up the results from limit algorithm using Other Labs
lab_results = load(lab_file)
labResultCode = attr(parameters, "resultCode")
labStartTime = attr(parameters, "resultStart")
labEndTime = attr(parameters, "resultEnd")
labLabValues = cleanLabValues
labLabPre = attr(parameters, "pre-limit_count")
labPreQuantile = attr(parameters, "pre-limit_quantiles")
labLabPost = nrow(cleanLabValues)
labPostQuantile = as.numeric(quantile(cleanLabValues$l_val, c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE))
labExcludedPatients = excludedPatients
excludedLabs = rbind(excludedICDs, excludedICDNames)

#Join the results
cleanLabValues=inner_join(icdLabValues, medLabValues, by=c("pid", "l_val", "timeOffset", "EncounterID"))
cleanLabValues=inner_join(cleanLabValues, labLabValues, by=c("pid", "l_val", "timeOffset", "EncounterID"))

#Create the output directory name
saving=dirname(med_file)
name_parts=strsplit(basename(med_file), "_")[[1]]
finName=paste(paste(name_parts[1:length(name_parts)-1], collapse="_", sep=""), "_joined.Rdata", collapse="",sep="")
saving=paste(saving, "/", finName, sep="")

#Save the results to disk
parameters<-1:1
attr(parameters, "med_file") <- med_file
attr(parameters, "med_result_code") <- medResultCode
attr(parameters, "med_start_time") <- medStartTime
attr(parameters, "med_end_time") <- medEndTime 
attr(parameters, "med_pre_limit") <- medLabPre 
attr(parameters, "med_pre_quantile") <- icdPreQuantile
attr(parameters, "med_post_limit") <- medLabPost
attr(parameters, "med_post_quantile") <- medPostQuantile 
attr(parameters, "med_excluded") <- excludedMeds
attr(parameters, "med_excluded_pid") <- medExcludedPatients

attr(parameters, "icd_file") <- icd_file
attr(parameters, "icd_result_code") <- icdResultCode
attr(parameters, "icd_start_time") <- icdStartTime
attr(parameters, "icd_end_time") <- icdEndTime
attr(parameters, "icd_pre_limit") <- icdLabPre
attr(parameters, "icd_pre_quantiles") <- icdPreQuantile
attr(parameters, "icd_post_limit") <- icdLabPost
attr(parameters, "icd_post_quantile") <- icdPostQuantile
attr(parameters, "icd_excluded") <- excludedICDS
attr(parameters, "icd_excluded_pid") <- icdExcludedPatients

attr(parameters, "lab_file") <- lab_file
attr(parameters, "lab_result_code") <- labResultCode
attr(parameters, "lab_start_time") <- medStartTime
attr(parameters, "lab_end_time") <- medEndTime
attr(parameters, "lab_pre_limit") <- labLabPre
attr(parameters, "lab_pre_quantiles") <- labPreQuantile
attr(parameters, "lab_post_limit") <- labLabPost
attr(parameters, "lab_post_quantile") <- labPostQuantile
attr(parameters, "lab_excluded") <- excludedLabs
attr(parameters, "lab_exclude_pid") <- labExcludedPatients

save(cleanLabValues, parameters, file=saving)

