library("RSQLite")
library("dplyr")

connect_sqlite <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/EncountersAll/EncountersAll.db")
    return(con)
}

query_encounters <- function(pid, con){
    sql = paste('SELECT * FROM EncountersAll WHERE PatientID = "', pid, '"', sep="")
    myQuery = dbGetQuery(con, sql)
    return(myQuery)
}

get_encounters <- function(pids, con){
    if(length(pids) > 0){
        data = paste(pids, collapse="\",\"")
        allData = data.frame()
        cnt = 1
        for(pid in pids){
            sql = paste('SELECT * FROM EncountersAll WHERE PatientID = "', pid, '"', sep="")
            myQuery = dbGetQuery(con, sql)
            allData = rbind(allData, myQuery)
            print(paste(as.character(cnt), " / ", as.character(length(pids)), sep = ""))
            cnt = cnt + 1
        }

        return(my_data)
    }
    else{
        return(NULL)
    }
}

