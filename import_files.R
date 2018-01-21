library(readr)
library(plyr)
library(dplyr)
library(data.table)
source('../lab_results_wrapper.R')
source('../encounters_wrapper.R')
source('../diagnoses_wrapper.R')
source('../medadmin_wrapper.R')
source('../demographics_wrapper.R')
source('../patientinfo_wrapper.R')

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


import_lab_values <- function(resultCodes, startEpoch, endEpoch){
    labsAll = get_labs(resultCodes, startEpoch, endEpoch)

    #Get a count of the rows and columns
    rowCnt = 0
    colCnt = 0
    for(x in labsAll){
        rowCnt = rowCnt + nrow(x)
        if(colCnt == 0){
            colCnt = ncol(x)
        }
    }

    print(paste("Downloading Labs: ", as.character(rowCnt), " labs", sep=""))

    labsAll = rbindlist(labsAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    return(labsAll)
}*/

#import_lab_values <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "LabResults"))) }

import_demo_info <- function(pids){
    demoAll = get_demographics(unique(pids))

    #Get a count of the rows and columns
    rowCnt = 0
    colCnt = 0
    for(x in demoAll){
        rowCnt = rowCnt + nrow(x)
        if(colCnt == 0){
            colCnt = ncol(x)
        }
    }

    print(paste("Downloading Demographics: ", as.character(rowCnt), " pids", sep=""))

    demoAll = rbindlist(demoAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    return(demoAll)
}

#import_demo_info <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "DemographicInfo"))) }

import_patient_bday <- function(pids){
    pinfoAll = get_patient_info(unique(pids))

    #Get a count of the rows and columns
    rowCnt = 0
    colCnt = 0
    for(x in pinfoAll){
        rowCnt = rowCnt + nrow(x)
        if(colCnt == 0){
            colCnt = ncol(x)
        }
    }

    print(paste("Downloading Patient Info: ", as.character(rowCnt), " pids", sep=""))

    pinfoAll = rbindlist(pinfoAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    return(pinfoAll)
}

#import_patient_bday <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "PatientInfo"))) }

import_diagnoses <- function(pids){
    diagAll = get_diagnoses(unique(pids))

    #Get a count of the rows and columns
    rowCnt = 0
    colCnt = 0
    for(x in diagAll){
        rowCnt = rowCnt + nrow(x)
        if(colCnt == 0){
            colCnt = ncol(x)
        }
    }

    print(paste("Downloading Diagnoses: ", as.character(rowCnt), " codes", sep=""))

    diagAll = rbindlist(diagAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    return(diagAll)
}

#import_diagnoses <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "DiagnosesComprehensive"))) }

import_other_abnormal_labs <- function(pids){
    labsAll = get_abnormal_labs(unique(pids))

    #Get a count of the rows and columns
    rowCnt = 0
    colCnt = 0
    for(x in labsAll){
        rowCnt = rowCnt + nrow(x)
        if(colCnt == 0){
            colCnt = ncol(x)
        }
    }

    print(paste("Downloading Abnormal Labs: ", as.character(rowCnt), " labs", sep=""))

    labsAll = rbindlist(labsAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    return(labsAll) 
}

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

    print(paste("Downloading Encounters: ", as.character(rowCnt), " encounters", sep=""))

    encountersAll = rbindlist(encountersAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    return(encountersAll)
}

# Depreciated function
#import_encounter_location <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "EncounterLocations"))) }

import_med_admin <- function(pids){
    medsAll = get_meds(unique(pids))

    #Get a count of the rows and columns
    rowCnt = 0
    colCnt = 0
    for(x in medsAll){
        rowCnt = rowCnt + nrow(x)
        if(colCnt == 0){
            colCnt = ncol(x)
        }
    }

    print(paste("Downloading Meds: ", as.character(rowCnt), " medications", sep=""))

    medsAll = rbindlist(medsAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    return(medsAll)
}

# Depreciated function
#import_med_admin <- function(input_dir){ return(import_files_fxn(file.path(input_dir, "MedicationAdministrationsComprehensive"))) }

