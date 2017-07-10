source("../import_files.R")

#Parse input from command line
library(optparse)
option_list <- list(
    make_option("--input", type="character", default=NULL, help="directory to load data from"),
    make_option("--output", type="character", default="", help="filepath output"),
    make_option("--name", type="character", default=NULL, help="name of this set analysis")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
input_dir = args[['input']]

#Parse the output directory and create if doesn't exists
output_directory = args[['output']]
if(!dir.exists(output_directory)){
    print("The output directory doesn't exists")
    stop()
}

if(args[['name']] == NULL){
	output_filename = gsub("//", "/", paste(output_directory, basename(input_dir), sep="/"))
}
else{
	#Create the final output filename
	output_filename = gsub("//", "/", paste(output_directory, args[['name']], sep="/"))
	output_filename = paste(output_filename, '.Rdata', sep="")
	if(file.exists(output_filename)){
		print("The output filename already exists")
		stop()
	}
}
print(paste("Writing to: ", output_filename, sep=""))

#Load up the csv files
importDb=import_files(input_dir)
patient_bday = importDb$patient_bday
diagnoses = importDb$diagnoses
encounter_all = importDb$encounter_all
encounter_location = importDb$encounter_location
lab_values = importDb$lab_values
med_admin=importDb$med_admin

#Build the lab values dataset
labValuesDplyr=inner_join(lab_values, patient_bday)
labValuesDplyr = select(labValuesDplyr, one_of(c("PatientID", "EncounterID", "DOB", "COLLECTION_DATE", "ORDER_CODE", "ORDER_NAME", "VALUE", "UNIT", "RANGE")))
labValuesDplyr = rename(labValuesDplyr, pid = PatientID)
labValuesDplyr = rename(labValuesDplyr, l_val = VALUE)
labValuesDplyr = labValuesDplyr %>% mutate(timeOffset = as.numeric(as.Date(COLLECTION_DATE) - as.Date(DOB)))
labValues<-labValuesDplyr %>% select(pid, l_val, timeOffset, COLLECTION_DATE, EncounterID) %>% as.data.frame()

#Get the diagnosis and pair with PtID to build the timeOffset
diagnosis_process = inner_join(diagnoses, patient_bday, by="PatientID")
encounter_earliest = encounter_location %>%
                        mutate(StartDate = ifelse(StartDate == "", EndDate, StartDate)) %>%
                        group_by(EncounterID) %>%
                        summarise(StartDate = min(as.Date(StartDate)))
icdValuesDplyr = inner_join(diagnosis_process, encounter_earliest, by="EncounterID")
icdValuesDplyr = rename(icdValuesDplyr, pid = PatientID)
icdValuesDplyr = rename(icdValuesDplyr, icd = TermCodeMapped)
icdValuesDplyr = rename(icdValuesDplyr, icd_name = TermNameMapped)
icdValuesDplyr = icdValuesDplyr %>%
                    mutate(timeOffset =
                        as.numeric(as.Date(StartDate)
                        -
                        as.Date(DOB)))
icdValues<-icdValuesDplyr %>% select(pid, icd, timeOffset, EncounterID) %>% as.data.frame()

#Get Medications that were administered
medsAdminDyplyr = med_admin %>% filter(MedicationStatus == "Given")
medsAdminDyplyr = inner_join(medsAdminDyplyr, patient_bday, by="PatientID")
medsAdminDyplyr = rename(medsAdminDyplyr, pid = PatientID)
medsAdminDyplyr = rename(medsAdminDyplyr, icd = MedicationTermID)
medsAdminDyplyr = rename(medsAdminDyplyr, icd_name = MedicationName)
medsAdminDyplyr = medsAdminDyplyr %>% 
                    mutate(timeOffset = 
                        as.numeric(as.Date(DoseStartTime) 
                        - 
                        as.Date(DOB)))
medValues<-medsAdminDyplyr %>% select(pid, icd, timeOffset, icd_name, EncounterID) %>% as.data.frame()

#Save the massaged data
save(labValues, icdValues, medValues, file=output_filename)

