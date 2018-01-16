library("parallel")
corecnt<-strtoi(system("nproc", ignore.stderr = TRUE, intern = TRUE))

partition_incoming <- function(pids, toChunk = 1000){
    # Chunk by at least each core
    if(length(pids) / corecnt < toChunk){
        toChunk = round(length(pids) / corecnt, digits=0)
    }

    # Chunkify
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

    return(finalList)
}

parallelfxn_small <- function(theList, asyncFxn){
    return(mclapply(partition_incoming(theList, 5000), asyncFxn, con, mc.cores = corecnt))
}

parallelfxn_large <- function(theList, asyncFxn){
    return(mclapply(partition_incoming(theList, 250), asyncFxn, con, mc.cores = corecnt))
}

