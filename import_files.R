library(readr)
library(plyr)
library(dplyr)
library(data.table)
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

import_encounter_all <- function(pids){
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

    #curRInd = 1
    #outEncAll=data.frame(matrix(NA, ncol = colCnt, nrow = rowCnt))
    #for(x in encountersAll){
    #    outEncAll[seq(curRInd, curRInd + nrow(x) - 1), ] = x[seq(1, nrow(x)), ]
    #    curRInd = curRInd + nrow(x)
    #    remove(x)
    #    print(paste(as.character(curRInd), ' / ', as.character(rowCnt), sep=""))
    #}

    return(outEncAll)
}

import_encounter_location <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "EncounterLocations"))) }

import_diagnoses <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "DiagnosesComprehensive"))) }

import_med_admin <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "MedicationAdministrationsComprehensive"))) }

