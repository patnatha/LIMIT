source("import_csv.R")

#Parse input from command line
library(optparse)
option_list <- list(
    make_option("--input", type="character", default="", help="directory to load data from")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
input_dir = args[['input']]

#Load up the csv files
importDb=import_csv(input_dir)
patient_bday = importDb$patient_bday
diagnoses = importDb$diagnoses
encounter_all = importDb$encounter_all
encounter_location = importDb$encounter_location


#Get the diagnosis and pair with PtID to build the timeOffset
diagnosis_process=inner_join(diagnoses, patient_bday)
diagnosis_process=inner_join(diagnosis_process, encounter_all, by="EncounterID")
diagnosis_process=inner_join(diagnosis_process, encounter_location, by="EncounterID")

#Get the columns that we need
icdValuesDplyr = select(diagnosis_process, one_of(c("PatientID.x", "DOB", "EncounterID", "TermCodeMapped","TermNameMapped", "StartDate", "EndDate", "AdmissionTypeCode", "AdmissionTypeName", "PatientClassCode", "PatientClassName", "LocationCode", "LocationDesc")))
icdValuesDplyr = rename(icdValuesDplyr, PatientID = PatientID.x)

#Create the empty data frame
icdValues<-data.frame(timeOffset=as.Date(),
                      icd=as.character(),
                      pid=as.character()
                     )

labValues<-data.frame(timeOffset=as.Date(),
                      l_val=as.character(),
                      pid=as.character()
                     )


