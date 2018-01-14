library("parallel")
library("RSQLite")

connect_sqlite_enc <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/EncountersAll/EncountersAll.db")
    return(con)
}

async_query_encs <- function(pids, con){
    out <- tryCatch(
        if(length(pids) > 0){
            #Build the query and execute
            sql = paste('SELECT * FROM EncountersAll WHERE PatientID IN ("', paste(pids, collapse="\",\""), '")', sep="")
            con = connect_sqlite_enc()
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

get_encounters <- function(pids){
    if(length(pids) > 0){
        # Chunkify
        toChunk = 1000
        corecnt<-strtoi(system("nproc", ignore.stderr = TRUE, intern = TRUE))
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

        print(paste("Download Encounters: ", as.character(length(pids)), " pids",sep=""))
        allData = mclapply(finalList, async_query_encs, con, mc.cores = 16)
        return(allData)
    }
    else{
        return(NULL)
    }
}

get_encounters_never_inpatient <- function(){
    con = connect_sqlite_enc()
    p1 = dbGetQuery(con,'SELECT PatientID, FirstInpatient, InpatientCnt FROM ever_inpatient WHERE InpatientCnt > 0')
    dbDisconnect(con)
    return(p1)
}

