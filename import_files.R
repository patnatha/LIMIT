library(readr)
library(plyr)
library(dplyr)
library(data.table)
source('../lab_results_wrapper.R')
source('../encounters_wrapper.R')

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
        print("Unable to load file")
        return(NULL)
    }
}

import_lab_values <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "LabResults"))) }

import_demo_info <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "DemographicInfo"))) }

import_patient_bday <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "PatientInfo"))) }

import_labs_all <- function(pids){
    print("Loading All Labs from DB")
    labsAll = get_labs(unique(pids))

    #Get a count of the rows and columns
    rowCnt = 0
    colCnt = 0
    for(x in labsAll){
        rowCnt = rowCnt + nrow(x)
        if(colCnt == 0){
            colCnt = ncol(x)
        }
    }

    print(paste("ROWS: ", as.character(rowCnt), sep=""))

    outLabAll = rbindlist(labsAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    remove(labsAll)
    return(outLabAll) 
}

import_encounter_all <- function(pids){
    print("Loading Encounters from DB")
    encountersAll = get_encounters(unique(pids)) 
    
    #Get a count of the rows and columns
    rowCnt = 0
    colCnt = 0
    for(x in encountersAll){
        rowCnt = rowCnt + nrow(x)
        if(colCnt == 0){
            colCnt = ncol(x)
        }
    }

    print(paste("ROWS: ", as.character(rowCnt), sep=""))

    #Copy all the results into one table
    outEncAll = rbindlist(encountersAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    remove(encountersAll)
    return(outEncAll)
}

import_encounter_location <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "EncounterLocations"))) }

import_diagnoses <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "DiagnosesComprehensive"))) }

import_med_admin <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "MedicationAdministrationsComprehensive"))) }

