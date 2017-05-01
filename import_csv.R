library(readr)
library(plyr)
library(dplyr)

import_csv_fxn <- function(path_to_file){
    dat <- read.delim(path_to_file, sep='|')
    return(tbl_df(dat))
}

import_csv <- function(input_dir){
    #Build the paths
    demo_info_path=file.path(input_dir, "DemographicInfo.csv")
    patient_bday_path=file.path(input_dir, "PatientInfo.csv")
    diagnoses_path=file.path(input_dir, "DiagnosesEverything.csv")
    lab_values_path=file.path(input_dir, "LabResults.csv")
    encouter_all_path=file.path(input_dir, "EncounterAll.csv")
    encounter_location_path=file.path(input_dir, "EncounterLocations.csv")

    #Load up the csv files
    demo_info=import_csv_fxn(demo_info_path)
    patient_bday=import_csv_fxn(patient_bday_path)
    diagnoses=import_csv_fxn(diagnoses_path)
    encounter_all=import_csv_fxn(encouter_all_path)
    encouter_location=import_csv_fxn(encounter_location_path)
    lab_values=import_csv_fxn(lab_values_path)

    l <- list("demo_info" = demo_info, 
                "patient_bday" = patient_bday, 
                "diagnoses" = diagnoses, 
                "encounter_all" = encounter_all, 
                "encounter_location" = encouter_location, 
                "lab_values" = lab_values)

    return(l) 
}

