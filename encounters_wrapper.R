library("RSQLite")
source("../wrapper_helper.R")

connect_sqlite_enc <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/EncountersAll/EncountersAll.db")
    return(con)
}

async_query_encs <- function(pids){
    out <- tryCatch(
        if(length(pids) >= 0){
            #Build the query and execute
            sql = paste('SELECT PatientID, EncounterID, AdmitDate, PatientClassCode FROM EncountersAll WHERE PatientID IN ("', paste(pids, collapse="\",\""), '")', sep="")
            con = connect_sqlite_enc()
            myQuery = dbGetQuery(con, sql)
            dbDisconnect(con)
            return(myQuery)
        }
    ,error=function(cond) {
            message(cond)
            return(NA)
        }
    )
}

get_encounters_pid <- function(pids){
    if(length(pids) >= 0){
        print(paste("Download Encounters: ", as.character(length(pids)), " pids",sep=""))
        return(parallelfxn_large(pids, async_query_encs))
    }
    else{
        return(NULL)
    }
}

async_query_encid <- function(encids){
    out <- tryCatch(
        if(length(encids) >= 0){
            sql = paste('SELECT PatientID, EncounterID, AdmitDate, PatientClassCode FROM EncountersAll WHERE EncounterID IN ("', paste(encids, collapse="\",\""), '")', sep="")
            con = connect_sqlite_enc()
            myQuery = dbGetQuery(con, sql)
            dbDisconnect(con)
            return(myQuery)
        }
    ,error=function(cond) {
            message(cond)
            return(NA)
        }
    )
}

get_encounters_encid <- function(encIDs){
    if(length(encIDs) >= 0){
        print(paste("Download Encounters: ", as.character(length(encIDs)), " encs",sep=""))
        return(parallelfxn_large(encIDs, async_query_encid))
    }
    else{
        return(NULL)
    }
}

get_encounters_never_inpatient <- function(){
    con = connect_sqlite_enc()
    p1 = dbGetQuery(con,'SELECT PatientID, FirstInpatient, InpatientCnt FROM ever_inpatient WHERE InpatientCnt > 0')
    dbDisconnect(con)
    return(p1)
}

