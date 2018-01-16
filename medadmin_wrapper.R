library("RSQLite")
source("../wrapper_helper.R")

connect_sqlite_meds <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/MedAdmin/MedAdmin.db")
    return(con)
}

async_query_meds <- function(pids, con){
    out <- tryCatch(
        if(length(pids) > 0){
            #Build the query and execute
            sql = paste('SELECT * FROM MedAdmin WHERE PatientID IN ("', paste(pids, collapse="\",\""), '")', sep="")
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

