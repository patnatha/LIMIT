library("RSQLite")
source("../wrapper_helper.R")

connect_sqlite_lab <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/LabResults/LabResults.db")
    return(con)
}

async_query_labs <- function(epochRange){
    out <- tryCatch(
        if(length(epochRange) > 0){
            #Build the query and execute
            sql = paste('SELECT PatientID, EncounterID, COLLECTION_DATE, ACCESSION_NUMBER, ORDER_CODE, RESULT_CODE, RESULT_NAME, VALUE FROM LabResults WHERE RESULT_CODE = "', epochRange[1], '" AND since_epoch >= ', epochRange[2], ' AND since_epoch < ', epochRange[3], sep="") 
            con = connect_sqlite_lab()
            myQuery = dbGetQuery(con, sql)
            dbDisconnect(con)
            return(myQuery)
        }
    ,error=function(cond) {
            message(paste("async_query_labs: ", cond, sep=""))
            return(NA)
        }
    )
}

async_query_abnormal_labs <- function(pids){
    out <- tryCatch(
        if(length(pids) > 0){
            #Build the query and execute
            sql = paste('SELECT PatientID, EncounterID, COLLECTION_DATE, ACCESSION_NUMBER, ORDER_CODE, RESULT_CODE, RESULT_NAME, VALUE, HILONORMAL_FLAG, HILONORMAL_COMMENT FROM LabResults WHERE PatientID IN ("', paste(pids, collapse="\",\""), '") AND HILONORMAL_FLAG != "N" AND HILONORMAL_FLAG != ""', sep="")
            con = connect_sqlite_lab()
            myQuery = dbGetQuery(con, sql)
            dbDisconnect(con)
            return(myQuery)
        }
    ,error=function(cond) {
            message(paste("async_query_abnormal_labs: ", cond, sep=""))
            return(NA)
        }
    )
}

get_abnormal_labs <- function(pids){
    if(length(pids) > 0){
        print(paste("Download Abnormal Labs: ", as.character(length(pids)), " pids",sep=""))
        return(parallelfxn_large(pids, async_query_abnormal_labs))
    }
    else{
        return(NULL)
    }
}

get_labs <-function(resultCodes, startEpoch, endEpoch){
    if(length(resultCodes) > 0){
        print(paste("Download Labs: ", paste(resultCodes, collapse=","), " - ", as.Date(as.POSIXlt(startEpoch * 86400, origin="1970-01-01")), " => ", as.Date(as.POSIXlt(endEpoch * 86400, , origin="1970-01-01")), sep=""))
        return(parallelfxn_labs(resultCodes, async_query_labs, startEpoch, endEpoch))
    }
    else {
        return(NULL)
    }
}

get_similar_lab_codes <- function(resultCodes){
    if(length(resultCodes) > 0){
        con = connect_sqlite_lab() 
        outputList = list()
        for(resultCode in resultCodes){
            sql = paste("SELECT similar_result_code FROM similar_result_codes WHERE RESULT_CODE = \"", resultCode,"\"", " AND valid = \"enabled\"", sep="")
            myQuery = dbGetQuery(con, sql)
            outputList = rbind(outputList, myQuery)
        }
        dbDisconnect(con)
        return(unique(outputList$similar_result_code))
    }
    else{
        return(list())
    }
}

