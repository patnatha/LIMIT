library(readr)
library(plyr)
library(dplyr)
library(data.table)

import_csv <- function(path_to_file){
    #dat <- read.delim(path_to_file, sep='|')
    dat <- fread(path_to_file, sep="|", fill=TRUE, data.table=FALSE, blank.lines.skip = TRUE, quote="")
    return(tbl_df(dat))
}

import_txt <- function(path_to_file){
    #dat <- read.delim(path_to_file, sep='\t', quote="")
    dat <- fread(path_to_file, sep="\t", fill=TRUE, data.table=FALSE, blank.lines.skip = TRUE, quote="")
    return(tbl_df(dat))
}

import_files_fxn <- function(path_to_file){
    path_to_file = gsub('//', '/', path_to_file)
    csv_path = paste(path_to_file, ".csv", sep="")
    txt_path = paste(path_to_file, ".txt", sep="")

    if(file.exists(csv_path)){
        return(import_csv(csv_path))
    }
    else if(file.exists(txt_path)){
        return(import_txt(txt_path))
    }
    else{
        return(NULL)
    }
}

import_files <- function(input_dir){
    #Build the paths
    demo_info_path=file.path(input_dir, "DemographicInfo")
    patient_bday_path=file.path(input_dir, "PatientInfo")
    diagnoses_path=file.path(input_dir, "DiagnosesEverything")
    lab_values_path=file.path(input_dir, "LabResults")
    encouter_all_path=file.path(input_dir, "EncounterAll")
    encounter_location_path=file.path(input_dir, "EncounterLocations")
    medication_admin_path=file.path(input_dir, "MedicationAdmi...sComprehensive")

    #Load up the csv files
    demo_info=import_files_fxn(demo_info_path)
    patient_bday=import_files_fxn(patient_bday_path)
    diagnoses=import_files_fxn(diagnoses_path)
    encounter_all=import_files_fxn(encouter_all_path)
    encouter_location=import_files_fxn(encounter_location_path)
    lab_values=import_files_fxn(lab_values_path)
    med_admin=import_files_fxn(medication_admin_path)

    l <- list("demo_info" = demo_info, 
                "patient_bday" = patient_bday, 
                "diagnoses" = diagnoses, 
                "encounter_all" = encounter_all, 
                "encounter_location" = encouter_location, 
                "lab_values" = lab_values,
                "med_admin" = med_admin)

    return(l) 
}

