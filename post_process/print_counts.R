library(optparse)
library(dplyr)
library(boot)

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata")
)

#Parse the incoming options
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)

args <- parse_args(parser)
inputData = args[['input']]
load(inputData)

print(paste("Original Lab Count: ", attributes(parameters)$med_pre_limit, sep=""))
print(paste("LIMIT ICD Count: ", attributes(parameters)$icd_post_limit, sep=""))
print(paste("LIMIT Med Count: ", attributes(parameters)$med_post_limit, sep=""))
print(paste("LIMIT Lab Count: ", attributes(parameters)$lab_post_limit, sep=""))
print(paste("Joined Tables: ", nrow(cleanLabValues), sep=""))


