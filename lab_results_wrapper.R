library("parallel")
library("RSQLite")

connect_sqlite_lab <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/LabResults/LabResults.db")
    return(con)
}

async_query_labs <- function(pids, con){
    out <- tryCatch(
        if(length(pids) > 0){
            #Build the query and execute
            sql = paste('SELECT * FROM LabResults WHERE PatientID IN ("', paste(pids, collapse="\",\""), '")', sep="")
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

get_labs <- function(pids){
    if(length(pids) > 0){
        # Chunkify
        toChunk = 1000
        corecnt = 16
        if(length(pids) / corecnt < toChunk){
            toChunk = round(length(pids) / corecnt, digits=0)
        }

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

        print(paste("Downloading Labs: ", as.character(length(pids)), " pids",sep=""))
        allData = mclapply(finalList, async_query_labs, con, mc.cores = corecnt)
        return(allData)
    }
    else{
        return(NULL)
    }
}

