source("import_csv.R")

#Parse input from command line
library(optparse)
option_list <- list(
    make_option("--input", type="character", default=NULL, help="directory to load data from"),
    make_option("--output", type="character", default=NULL, help="filepath output"),
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

#Create the final output filename
output_filename = gsub("//", "/", paste(output_directory, args[['name']], sep=""))
output_filename = paste(output_filename, '.Rdata', sep="")
if(file.exists(output_filename)){
    print("The output filename already exists")
    stop()
}

#Load up the csv files
importDb=import_csv(input_dir)
patient_bday = importDb$patient_bday
diagnoses = importDb$diagnoses
encounter_all = importDb$encounter_all
encounter_location = importDb$encounter_location
lab_values = importDb$lab_values

#Get the diagnosis and pair with PtID to build the timeOffset
diagnosis_process=inner_join(diagnoses, patient_bday, by="PatientID")
encounter_earliest=encounter_location %>% group_by(EncounterID) %>% summarise(StartDate = min(as.Date(StartDate)))
diagnosis_process=inner_join(diagnosis_process, encounter_earliest, by="EncounterID")

#Get the columns that we need
icdValuesDplyr = select(diagnosis_process, one_of(c("PatientID", "DOB", "EncounterID", "TermCodeMapped","TermNameMapped", "StartDate")))
icdValuesDplyr = rename(icdValuesDplyr, pid = PatientID)
icdValuesDplyr = rename(icdValuesDplyr, icd = TermCodeMapped)
icdValuesDplyr = icdValuesDplyr %>% mutate(timeOffset = as.numeric(as.Date(StartDate) - as.Date(DOB)))

#Save the ICD values as a dataframe
icdValues<-icdValuesDplyr %>% as.data.frame()

#Build the lab values dataset
labValuesDplyr=inner_join(lab_values, patient_bday)
labValuesDplyr = select(labValuesDplyr, one_of(c("PatientID", "DOB", "COLLECTION_DATE", "ORDER_CODE", "ORDER_NAME", "VALUE", "UNIT", "RANGE")))
labValuesDplyr = rename(labValuesDplyr, pid = PatientID)
labValuesDplyr = rename(labValuesDplyr, l_val = VALUE)
labValuesDplyr = labValuesDplyr %>% mutate(timeOffset = as.numeric(as.Date(COLLECTION_DATE) - as.Date(DOB))) 

#Save lab values as a dataframe
labValues<-labValuesDplyr %>% as.data.frame()

#Save the massaged data
save(labValues, icdValues, file=output_filename)

