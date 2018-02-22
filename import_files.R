library(readr)
library(dplyr)
library(data.table)
source('../lab_results_wrapper.R')
source('../encounters_wrapper.R')
source('../diagnoses_wrapper.R')
source('../medadmin_wrapper.R')
source('../demographics_wrapper.R')
source('../patientinfo_wrapper.R')
source('../reference_interval_wrapper.R')

start_timer <-function(){
    return(Sys.time())
}

import_timeout <- function(stime){
    time.taken <- as.numeric(Sys.time() - stime, units="secs")
    timeout = paste(as.character(round(time.taken, digits=2)), " seconds", sep="")
    return(timeout)
}

import_lab_values <- function(resultCodes, startEpoch, endEpoch){
    stime = start_timer()
    labsAll = get_labs(unique(resultCodes), startEpoch, endEpoch)
    labsAll = rbindlist(labsAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    print(paste("Downloading Labs: ", as.character(nrow(labsAll), " labs", sep="")))
    print(paste("Downloading Labs: ", import_timeout(stime), sep=""))
    return(labsAll)
}

import_demo_info <- function(pids){
    stime = start_timer()
    demoAll = get_demographics(unique(pids))
    demoAll = rbindlist(demoAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    print(paste("Downloading Demographics: ", as.character(nrow(demoAll)), " pids", sep=""))
    print(paste("Downloading Demographics: ", import_timeout(stime), sep=""))
    return(demoAll)
}

import_patient_bday <- function(pids){
    stime = start_timer()
    pinfoAll = get_patient_info(unique(pids))
    pinfoAll = rbindlist(pinfoAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    print(paste("Downloading Patient Info: ", as.character(nrow(pinfoAll)), " pids", sep=""))
    print(paste("Downloading Patient Info: ", import_timeout(stime), sep=""))
    return(pinfoAll)
}

import_diagnoses <- function(pids){
    stime = start_timer()
    diagAll = get_diagnoses(unique(pids))
    diagAll = rbindlist(diagAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    print(paste("Downloading Diagnoses: ", as.character(nrow(diagAll)), " codes", sep=""))
    print(paste("Downloading Diagnoses: ", import_timeout(stime), sep=""))
    return(diagAll)
}

import_other_abnormal_labs <- function(pids){
    stime = start_timer()
    labsAll = get_abnormal_labs(unique(pids))
    labsAll = rbindlist(labsAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    print(paste("Downloading Abnormal Labs: ", as.character(nrow(labsAll)), " labs", sep=""))
    print(paste("Downloading Abnormal Labs: ", import_timeout(stime), sep=""))
    return(labsAll) 
}

import_similar_result_codes <- function(resultCodes){
    stime = start_timer()
    otherCodes = get_similar_lab_codes(resultCodes)
    print(paste("Downloading Result Codes: ", as.character(nrow(otherCodes)), " codes", sep=""))
    print(paste("Downloading Result Codes: ", import_timeout(stime), sep=""))
    return(otherCodes)
}

import_encounter_all <- function(pids){
    stime = start_timer()
    encountersAll = get_encounters_pid(unique(pids)) 
    encountersAll = rbindlist(encountersAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    print(paste("Downloading Encounters: ", as.character(nrow(encountersAll)), " encounters", sep=""))
    print(paste("Downloading Encounters: ", import_timeout(stime), sep=""))
    return(encountersAll)
}

import_encounter_encid <- function(encids){
    stime = start_timer()
    encounters = get_encounters_encid(unique(encids))
    encounters = rbindlist(encounters, use.names=TRUE, fill=TRUE, idcol=FALSE)
    print(paste("Downloading Encounters: ", as.character(nrow(encounters)), " encounters", sep=""))
    print(paste("Downloading Encounters: ", import_timeout(stime), sep=""))
    return(encounters)
}

import_med_admin <- function(pids){
    stime = start_timer()
    medsAll = get_meds(unique(pids))
    medsAll = rbindlist(medsAll, use.names=TRUE, fill=TRUE, idcol=FALSE)
    print(paste("Downloading Meds: ", as.character(nrow(medsAll)), " medications", sep=""))
    print(paste("Downloading Meds: ", import_timeout(stime), sep=""))
    return(medsAll)
}

import_reference_range <- function(result_code, sex, race, low_age, high_age, tsources){
    return(query_reference_interval(result_code, sex, race, low_age, high_age, tsources)) 
}

import_confidence_range <- function(result_code, sex, race, low_age, high_age, tsources){
    return(query_confidence_interval(result_code, sex, race, low_age, high_age, tsources))
}

