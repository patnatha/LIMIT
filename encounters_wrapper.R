library("parallel")
library("RSQLite")

connect_sqlite <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/EncountersAll/EncountersAll.db")
    return(con)
}

async_query_encs <- function(pids, con){
    out <- tryCatch(
        if(length(pids) > 0){
            #Build the query and execute
            sql = paste('SELECT * FROM EncountersAll WHERE PatientID IN ("', paste(pids, collapse="\",\""), '")', sep="")
            con = connect_sqlite()
            myQuery = dbGetQuery(con, sql)
            dbDisconnect(con)
            print(nrow(myQuery))
            return(myQuery)
        }
    ,error=function(cond) {
            message(cond)
            return(NA)
        }
    )
}

get_encounters <- function(pids){
    if(length(pids) > 0){
        # Chunkify
        toChunk = 1000
        cnt = 0
        tmpList = list()
        finalList = list()
        for(pid in pids){
            tmpList[(cnt %% toChunk) + 1] = pid
            cnt = cnt + 1

            if(cnt %% toChunk == 0){
                #Reset the list to empty
                finalList[[length(finalList) + 1]] = tmpList
                tmpList = list()
            }
        }

        #Build the final list set
        if(length(tmpList) > 0){
            finalList[[length(finalList) + 1]] = tmpList
        }

        print(paste("Download Encounters: ", as.character(length(pids)),sep=""))
        allData = mclapply(finalList, async_query_encs, con, mc.cores = 16)
        return(allData)
    }
    else{
        return(NULL)
    }
}

