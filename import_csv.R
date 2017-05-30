library(readr)
library(plyr)
library(dplyr)

import_csv_fxn <- function(path_to_file){
    path_to_file = gsub('//', '/', path_to_file)
    csv_path = paste(path_to_file, ".csv", sep="")
    txt_path = paste(path_to_file, ".txt", sep="")
    if(file.exists(csv_path)){
        dat <- read.delim(csv_path, sep='|')
        return(tbl_df(dat))
    }
    else if(file.exists(txt_path)){
        dat <- read.delim(txt_path, sep='\t', quote="")
        return(tbl_df(dat))
    }
    else{
        return(NULL)
    }
}

import_csv <- function(input_dir){
    #Build the paths
    demo_info_path=file.path(input_dir, "DemographicInfo")
    patient_bday_path=file.path(input_dir, "PatientInfo")
    diagnoses_path=file.path(input_dir, "DiagnosesEverything")
    lab_values_path=file.path(input_dir, "LabResults")
    encouter_all_path=file.path(input_dir, "EncounterAll")
    encounter_location_path=file.path(input_dir, "EncounterLocations")
    medication_admin_path=file.path(input_dir, "MedicationAdmi...sComprehensive")

    #Load up the csv files
    demo_info=import_csv_fxn(demo_info_path)
    patient_bday=import_csv_fxn(patient_bday_path)
    diagnoses=import_csv_fxn(diagnoses_path)
    encounter_all=import_csv_fxn(encouter_all_path)
    encouter_location=import_csv_fxn(encounter_location_path)
    lab_values=import_csv_fxn(lab_values_path)
    med_admin=import_csv_fxn(medication_admin_path)

    l <- list("demo_info" = demo_info, 
                "patient_bday" = patient_bday, 
                "diagnoses" = diagnoses, 
                "encounter_all" = encounter_all, 
                "encounter_location" = encouter_location, 
                "lab_values" = lab_values,
                "med_admin" = med_admin)

    return(l) 
}

