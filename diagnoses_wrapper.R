library("RSQLite")
source("../wrapper_helper.R")

connect_sqlite_diagnoses <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/DiagComp/DiagComp.db")
    return(con)
}

async_query_diagnoses <- function(pids, con){
    out <- tryCatch(
        if(length(pids) > 0){
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
    if(length(pids) > 0){
        print(paste("Download Diagnoses: ", as.character(length(pids)), " pids",sep=""))
        return(parallelfxn_large(pids, async_query_diagnoses))
    }
    else{
        return(NULL)
    }
}

