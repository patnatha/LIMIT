library("RSQLite")
source("../wrapper_helper.R")

connect_sqlite_lab <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/LabResults/LabResults.db")
    return(con)
}

async_query_labs <- function(pids, con){
    out <- tryCatch(
        if(length(pids) > 0){
            #Build the query and execute
            sql = paste('SELECT * FROM LabResults WHERE PatientID IN ("', paste(pids, collapse="\",\""), '") AND HILONORMAL_FLAG != "N" AND HILONORMAL_FLAG != ""', sep="")
            con = connect_sqlite_lab()
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

get_abnormal_labs <- function(pids){
    if(length(pids) > 0){
        print(paste("Download Labs: ", as.character(length(pids)), " pids",sep=""))
        return(parallelfxn_large(pids, async_query_labs))
    }
    else{
        return(NULL)
    }
}

