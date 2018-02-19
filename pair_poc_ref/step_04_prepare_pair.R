# Load up additional information
source('../import_files.R')
source('paired_paths.R')
source('../prepare_data/prepare_helper.R')

# Create the options list
library(optparse)
option_list <- list(
  make_option("--input", type="character", default="", help="file to run")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
inputPath = args[['input']]

#Load up the paired glucose values
fpaired_path=paired_path(inputPath)
load(fpaired_path)
results$value_diff=results$one_value-results$two_value
labValues<-data.frame(PatientID=results$pid, 
                      EncounterID=results$encid,
                        one_ascen=results$one_accession, 
                        one_collect=results$one_collect,
                        two_ascen=results$two_accession, 
                        VALUE=results$value_diff, 
                        COLLECTION_DATE=results$one_collect)

# Load up patient bday
patient_bday = import_patient_bday(labValues$PatientID)

# Load up encounters
encountersAll=appendEncounters(NA, labValues)

#Calculate timeOffset
print("LV: Calculate Time-Offest")
labValues = inner_join(labValues, patient_bday, by="PatientID")
labValues = labValues %>% mutate(timeOffset = as.numeric(
                                 as.Date(COLLECTION_DATE) - as.Date(DOB)))

#Process the columns for final output
print("LV: Select columns for output")
labValues = labValues %>% rename(pid = PatientID)
labValues = labValues %>% rename(l_val = VALUE)
labValues = labValues %>% select(pid, l_val, timeOffset, EncounterID)

#Load original parameters
load(originalDataFilePath)
input_val=attr(parameters, "resultCode")
toInclude=attr(parameters, "group")
output_filename=attr(parameters, "name")
attr(parameters, "pair_original_length") = originalDataFilePath
attr(parameters, "pair_diff_in_secs") = diff_in_secs 

#Get ancillary data
icdValues=prepare_diagnoses(labValues, patient_bday, encountersAll, toInclude)
otherLabs=prepare_other_labs(labValues, patient_bday, encountersAll, toInclude, input_val)
medValuess=prepare_medications(labValues, patient_bday, encountersAll, toInclude)

#Save the final results
save(parameters, labValues, icdValues, medValues, otherLabs, encountersAll, file=output_filename)

