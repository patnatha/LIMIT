library("RSQLite")
source("../wrapper_helper.R")

connect_sqlite_pinfo <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/PatientInfo/PatientInfo.db")
    return(con)
}

async_query_pinfo <- function(pids, con){
    out <- tryCatch(
        if(length(pids) > 0){
            #Build the query and execute
            sql = paste('SELECT * FROM PatientInfo WHERE PatientID IN ("', paste(pids, collapse="\",\""), '")', sep="")
            con = connect_sqlite_pinfo()
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

get_patient_info <- function(pids){
    if(length(pids) > 0){
        print(paste("Download Patient Info: ", as.character(length(pids)), " pids",sep=""))
        return(parallelfxn_small(pids, async_query_pinfo))
    }
    else{
        return(NULL)
    }
}

