source('paired_paths.R')

# Create the options list
library(optparse)
option_list <- list(
  make_option("--input", type="character", default="", help="file to run")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
inputPath = args[['input']]

#Set the null values for the variables to save
tresults = data.frame()
diff_in_secs = NA

#Iterate over paired files
totalRowCnt = 0
for(tfile in list.files(path=paired_pieces_path(inputPath), full.names = TRUE)){
    if(tools::file_ext(tfile) == "pair"){
        print(paste("LOADING: ", basename(tfile), sep=""))
        load(tfile)
        totalRowCnt = totalRowCnt + nrow(results)
        tresults = rbind(tresults, results)
    }
}

print(paste("TOTAL ROW COUNT: ", totalRowCnt, " pairs", sep=""))
results = tresults
remove(tresults)

#Save the results
fpaired_path=paired_path(inputPath)
save(results, diff_in_secs, originalDataFilePath, file=fpaired_path)

