library(optparse)
library(tools)
library(stringr)

option_list <- list(
    make_option("--input", type="character", default=NA, help="file to load Rdata")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
inputdir = args[['input']]

if(is.na(inputdir)){
    print("ERROR: must enter a directory")
    stop()
}

actionDirect=args[['action']]

#Start the file for the count results
outFile=paste(inputdir, "file_counts.csv", sep="/")
fileDelim=","
fileCols=c("Filename","Group","Count","Selection","Count")
write(fileCols, file = outFile, ncolumns = length(fileCols), append = FALSE, sep=fileDelim)

#Print it out
print(inputdir)

#Iterate over base directories
dirlist = list.files(inputdir, full.names = TRUE, include.dirs=T)
for (tdir in dirlist){
    if(tdir == outFile) { next }
    Split=strsplit(tdir, "//")
    incGrp=Split[[1]][length(Split[[1]])]
    print(paste("GROUP: ", incGrp, sep=""))

    #Iterate over base files in each directory
    tbasenames=c()
    filelist = list.files(tdir, pattern="*.Rdata", recursive=T, full.names=T)
    for(tfile in filelist){
        tbname = file_path_sans_ext(basename(tfile))
        load(tfile)
        labValuesLength = nrow(labValues)
        tbasenames[tbname] = labValuesLength
    }
 
    #Iterate over the selected directories
    dirlist = list.dirs(tdir, full.names = TRUE)
    for(tfdir in dirlist){
        if(tfdir == tdir) { next }
        Split=strsplit(tfdir, "/")
        selectMethod=Split[[1]][length(Split[[1]])]
        print(paste("SELECTION: ", selectMethod, sep=""))

        #Iterate over the selected files  
        selected_file_list = list.files(tfdir, pattern="*.Rdata", full.names = TRUE) 
        for(selected_file in selected_file_list){
            tfbname = str_replace(file_path_sans_ext(basename(selected_file)), "_selected", "")
            if(tfbname %in% names(tbasenames)){
                load(selected_file)
                labValuesLength = nrow(labValues)

                theline=c(tfbname, incGrp, tbasenames[tfbname], selectMethod, labValuesLength)
                write(theline, file = outFile, ncolumns = length(theline), append=T,sep=fileDelim)
            }
        }
    }
} 


