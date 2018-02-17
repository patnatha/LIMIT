library(optparse)

option_list <- list(
    make_option("--input", type="character", default=NA, help="file to load Rdata")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
inputdir = args[['input']]

filelist = list.files(inputdir, pattern="*selected.Rdata", full.names = TRUE, recursive=T)
greatThanCnt =0 
lessThanList = list()
for (tfile in filelist){
    load(tfile)
    labValuesLength = nrow(labValues)
    if(labValuesLength > 20){
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
        file.remove(tfile)
    }

    n <- readline(prompt="DELETE THESE FILES? [Y|N]:")
    if(n == "Y"){
        for(tfile in lessThanList){
            print(paste("DELETING: ", basename(tfile), sep=""))
            file.remove(tfile)
        }
    }
}
