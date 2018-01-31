library("RSQLite")
source("../wrapper_helper.R")

connect_sqlite_meds <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/MedAdmin/MedAdmin.db")
    return(con)
}

async_query_meds <- function(pids){
    out <- tryCatch(
        if(length(pids) > 0){
            #Build the query and execute
            sql = paste('SELECT PatientID, EncounterID, MedicationTermID, MedicationName, DoseStartTime, MedicationStatus FROM MedAdmin WHERE PatientID IN ("', paste(pids, collapse="\",\""), '") AND MedicationStatus = "Given"', sep="")
            con = connect_sqlite_meds()
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

get_meds <- function(pids){
    if(length(pids) > 0){
        print(paste("Download Meds: ", as.character(length(pids)), " pids",sep=""))
        return(parallelfxn_large(pids, async_query_meds))
    }
    else{
        return(NULL)
    }
}

async_query_pid_med <-function(pids, med){
    if(length(pids) > 0){
        sql = paste("SELECT PatientID, MedicationTermID, DoseStartTime FROM MedAdmin WHERE MedicationTermID = \"", med, "\" AND PatientID IN (\"", paste(pids, collapse="\",\""), "\")", sep="")
        con = connect_sqlite_meds()
        myQuery = dbGetQuery(con, sql)
        dbDisconnect(con)
        return(myQuery)
    } else {
        return(list())
    }
}

get_pid_with_med <- function(meds, validPIDs){
    toExcludePids = list()

    curiter = 1
    totaliter = length(meds)
    for(med in meds){
        #Split the PIDs into chunks and send to the cloud
        pidChunks = split(unique(validPIDs), ceiling(seq_along(validPIDs)/(length(validPIDs) / corecnt)))
        tempExcludePIDs = mclapply(pidChunks, async_query_pid_med, med, mc.cores = corecnt)

        #Flatten the results
        uniqueLen = 0
        for(x in tempExcludePIDs){
            if(nrow(x) > 0){
                uniqueLen = uniqueLen + nrow(x)
                toExcludePids = rbind(toExcludePids, x)
            }
        }

        #Exclude unique PIDs
        toExcludePids = unique(toExcludePids)
        print(paste("Downloaded (", med, ") ", curiter, "/", totaliter,": ", uniqueLen, " pids", sep=""))
        curiter = curiter + 1
    }

    return(toExcludePids)
}

