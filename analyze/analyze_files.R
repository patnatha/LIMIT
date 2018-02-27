library(dplyr)
library(optparse)
source('../import_files.R')
source('analyze_helper.R')

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata") 
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

#Load input data
input_dir = args[['input']]
print(paste("INPUT: ", input_dir, sep=""))

files=list.files(input_dir, pattern = "analysis_results.csv", full.names = TRUE,  recursive=T)
for(file in files){
    print(paste("LOADING: ", file, sep=""))
    theTable = tbl_df(read.csv(file=file, header=TRUE, sep=","))
}

