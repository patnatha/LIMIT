library("RSQLite")
source("../wrapper_helper.R")

connect_sqlite_diagnoses <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/DiagComp/DiagComp.db")
    return(con)
}

async_query_diagnoses <- function(pids){
    out <- tryCatch(
        if(length(pids) >= 0){
            #Build the query and execute
            sql = paste('SELECT PatientID, EncounterID, TermCodeMapped, TermNameMapped, Lexicon FROM DiagComp WHERE PatientID IN ("', paste(pids, collapse="\",\""), '")', sep="")
            con = connect_sqlite_diagnoses()
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

get_diagnoses <- function(pids){
    if(length(pids) >= 0){
        print(paste("Download Diagnoses: ", as.character(length(pids)), " pids",sep=""))
        return(parallelfxn_large(pids, async_query_diagnoses))
    }
    else{
        return(NULL)
    }
}

async_query_pid_icd <- function(pids, icd){
    if(length(pids) >= 0){
        sql = paste("SELECT PatientID, EncounterID, TermCodeMapped FROM DiagComp WHERE TermCodeMapped = \"", icd, "\" AND PatientID IN (\"", paste(pids, collapse="\",\""), "\")", sep="")
        con = connect_sqlite_diagnoses()
        myQuery = dbGetQuery(con, sql)
        dbDisconnect(con)
        return(myQuery)
    } else {
        return(list())
    }
}

get_pid_with_icd <- function(icds, validPIDs){
    toExcludePids = list()

    #Itreate over each RESULT_CODE & HILOWNORMALFLAG TO find PIDs 
    curiter = 1
    totaliter = length(icds)
    for(icd in icds){
        #Split the PIDs into chunks and send to the cloud
        pidChunks = split(unique(validPIDs), ceiling(seq_along(validPIDs)/(length(validPIDs) / corecnt)))
        tempExcludePIDs = mclapply(pidChunks, async_query_pid_icd, icd, mc.cores = corecnt)

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
        print(paste("Downloaded (", icd, ") ", curiter, "/", totaliter,": ", uniqueLen, " icds", sep=""))
        curiter = curiter + 1
    }

    return(toExcludePids)
}

