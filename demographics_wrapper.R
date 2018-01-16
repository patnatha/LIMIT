library("RSQLite")
source("../wrapper_helper.R")

connect_sqlite_demos <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/Demographics/Demographics.db")
    return(con)
}

async_query_demos <- function(pids, con){
    out <- tryCatch(
        if(length(pids) > 0){
            #Build the query and execute
            sql = paste('SELECT * FROM Demographics WHERE PatientID IN ("', paste(pids, collapse="\",\""), '")', sep="")
            con = connect_sqlite_demos()
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

get_demographics <- function(pids){
    if(length(pids) > 0){
        print(paste("Download Demographic: ", as.character(length(pids)), " pids",sep=""))
        return(parallelfxn_small(pids, async_query_demos))
    }
    else{
        return(NULL)
    }
}

