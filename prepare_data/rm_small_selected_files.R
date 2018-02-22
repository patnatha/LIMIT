library(optparse)

option_list <- list(
    make_option("--input", type="character", default=NA, help="file to load Rdata"),
    make_option("--cut", type="numeric", default=1000, help="cut off for lab value cnt"),
    make_option("--action", type="character", default=NA, help="what to do with lower than cut off offenders")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
inputdir = args[['input']]

if(is.na(inputdir)){
    print("ERROR: must enter a directory")
    stop()
}

cutOffVal = 1000
cutOffVal = as.numeric(args[['cut']])
if(is.na(cutOffVal)){
    print("ERROR: must enter a numeric cut off value")
    stop()
}

actionDirect=args[['action']]

filelist = list.files(inputdir, pattern="*selected.Rdata", full.names = TRUE, recursive=T)
greatThanCnt =0 
lessThanList = list()
for (tfile in filelist){
    load(tfile)
    labValuesLength = nrow(labValues)
    if(labValuesLength >= cutOffVal){
        print(paste(basename(tfile), ": ", labValuesLength, sep=""))
        greatThanCnt = greatThanCnt + 1
    } else {
        lessThanList=c(lessThanList, tfile)
    }
} 

if(length(lessThanList) > 0){
    for(tfile in lessThanList){
        load(tfile)
        labValuesLength = nrow(labValues)
        print(paste("TO DELETE: ", basename(tfile), ": ", labValuesLength, sep=""))
    }

    
    if(!is.na(actionDirect) && actionDirect == "delete"){
        for(tfile in lessThanList){
            print(paste("DELETING: ", basename(tfile), sep=""))
            file.remove(tfile)
        }
    }
}

