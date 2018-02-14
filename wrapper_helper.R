library("parallel")
corecnt<-strtoi(system("nproc", ignore.stderr = TRUE, intern = TRUE))

partition_incoming <- function(pids, toChunk = 1000){
    # Chunk by at least each core
    if(length(pids) / corecnt < toChunk){
        toChunk = floor(length(pids) / corecnt)
        if(toChunk == 0){
            toChunk = 1
        }
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
    
    if(length(finalList) == 0){
        #This is a place holder for nothingness (PatientID and EncounterID)
        finalList = list("YASERTON")
    }

    return(finalList)
}

parallelfxn_small <- function(theList, asyncFxn){
    return(mclapply(partition_incoming(theList, 5000), asyncFxn, mc.cores = corecnt))
}

parallelfxn_large <- function(theList, asyncFxn){
    return(mclapply(partition_incoming(theList, 250), asyncFxn, mc.cores = corecnt))
}

parallelfxn_labs <- function(resultCodes, asyncFxn, startEpoch, endEpoch){
    finalList = list()
    for(resultCode in resultCodes){
        toChunk = 30
        theList=seq(floor(startEpoch), ceiling(endEpoch), floor(toChunk))
        if(theList[length(theList)] != endEpoch){
            theList[length(theList) + 1] = endEpoch
        }
        lastX = NA
        for(x in theList){
            if(!is.na(lastX)){
                finalList[[length(finalList) + 1]] = c(resultCode, as.character(lastX), as.character(x))
            }
            lastX = x
        }
    }
    return(mclapply(finalList, asyncFxn, mc.cores = corecnt))
}

