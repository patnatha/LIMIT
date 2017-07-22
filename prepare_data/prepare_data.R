source("../import_files.R")

#Parse input from command line
library(optparse)
option_list <- list(
    make_option("--input", type="character", default=NULL, help="directory to load data from"),
    make_option("--output", type="character", default="/scratch/leeschro_armis/patnatha/prepared_data/", help="filepath output"),
    make_option("--name", type="character", default=NULL, help="name of this set analysis"),
    make_option("--age", type="character", default=NULL, help="enter range of ages separate by |"),
    make_option("--include", type="character", default=NULL, help="groups to include")
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

if(is.null(args[["age"]])){
    ageBias = NULL
} else {
    theSplit = strsplit(args[['age']], "|")
    if(length(theSplit) == 2){
        ageBiad = theSplit
    }
    else{
        print("ERROR: age format [start]|[end] in decimals of years")
        stop()
    }
}

toInclude = NULL
if(!is.null(args[["include"]])){
    toInclude = args[["include"]]
    if(toInclude != "inpatient" &
       toInclude != "outpatient"){
        toInclude == NULL
    }
}    

#Parse the name from input if exists
if(is.null(args[["name"]])){
    #Build the filename
    theBasename = basename(input_dir)
    if(!is.null(ageBias)){
        theBasename = paste(theBasename, "_age_", paste(ageBias, sep="_"), sep="")
    }

    if(!is.null(toInclude)){
        theBasename = paste(theBasename, "_", toInclude, sep="")
    }

    output_filename = gsub("//", "/", paste(output_directory, theBasename, sep="/"))
} else {
    output_filename = gsub("//", "/", paste(output_directory, args[['name']], sep="/"))
}
output_filename = paste(output_filename, '.Rdata', sep="")
print(output_filename)
if(file.exists(output_filename)){
    print("The output filename already exists")
    stop()
}

#Load up the csv files
patient_bday = import_patient_bday(input_dir)

#Load up all the encouters for the given pids
encounter_all = import_encounter_all(patient_bday$PatientID)

#Build the lab values dataset
lab_values = import_lab_values(input_dir)
labValuesDplyr = inner_join(lab_values, patient_bday)
remove(lab_values)
labValuesDplyr = rename(labValuesDplyr, pid = PatientID)
labValuesDplyr = rename(labValuesDplyr, l_val = VALUE)
labValuesDplyr = labValuesDplyr %>% mutate(timeOffset = as.numeric(as.Date(COLLECTION_DATE) - as.Date(DOB)))
labValues<-labValuesDplyr %>% select(pid, l_val, timeOffset, COLLECTION_DATE, EncounterID) %>% as.data.frame()

#Exclude all the lab values that are not consistent with a grouping
if(toInclude == "inpatient"){
    labValuesDplyr = inner_join(labValuesDplyr, encounter_all %>% filter(PatientClassNameSource == "Inpatient"))
} else if(toInclude == "outpatient"){
    labValuesDplyr = inner_join(labValuesDplyr, encounter_all %>% filter(PatientClassNameSource == "Outpatient"))
}
remove(encounter_all)

#Get only the columns we want
labValuesDplyr = select(labValuesDplyr, one_of(c("PatientID", "EncounterID", "DOB", "COLLECTION_DATE", "ORDER_CODE", "ORDER_NAME", "VALUE", "UNIT", "RANGE")))

#Get the diagnosis and pair with PtID to build the timeOffset
diagnoses = import_diagnoses(input_dir)
diagnosis_process = inner_join(diagnoses, patient_bday, by="PatientID")
remove(diagnoses)
#encounter_location = import_encounter_location(input_dir)
#encounter_earliest = encounter_location %>%
#                        mutate(StartDate = ifelse(StartDate == "", EndDate, StartDate)) %>%
#                        filter(StartDate != "") %>%
#                        group_by(EncounterID) %>%
#                        summarise(StartDate = min(as.Date(StartDate)))
#remove(encounter_location)

encounter_earliest = encounter_all %>% filter(AdmitDate != "")
icdValuesDplyr = inner_join(diagnosis_process, encounter_earliest, by="EncounterID")
remove(encounter_earliest)
icdValuesDplyr = rename(icdValuesDplyr, pid = PatientID)
icdValuesDplyr = rename(icdValuesDplyr, icd = TermCodeMapped)
icdValuesDplyr = rename(icdValuesDplyr, icd_name = TermNameMapped)
icdValuesDplyr = icdValuesDplyr %>%
                    mutate(timeOffset =
                        as.numeric(as.Date(AdmitDate)
                        -
                        as.Date(DOB)))
icdValues<-icdValuesDplyr %>% select(pid, icd, timeOffset, EncounterID) %>% as.data.frame()

#Get Medications that were administered
med_admin = import_med_admin(input_dir)
medsAdminDyplyr = med_admin %>% filter(MedicationStatus == "Given")
remove(med_admin)
medsAdminDyplyr = inner_join(medsAdminDyplyr, patient_bday, by="PatientID")
medsAdminDyplyr = rename(medsAdminDyplyr, pid = PatientID)
medsAdminDyplyr = rename(medsAdminDyplyr, icd = MedicationTermID)
medsAdminDyplyr = rename(medsAdminDyplyr, icd_name = MedicationName)
medsAdminDyplyr = medsAdminDyplyr %>% 
                    mutate(timeOffset = 
                        as.numeric(as.Date(DoseStartTime) 
                        - 
                        as.Date(DOB)))

#Save the massaged data
save(labValues, icdValues, medValues, encountersAll, file=output_filename)

