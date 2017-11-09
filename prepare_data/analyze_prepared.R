library(optparse)
option_list <- list(
    make_option("--input", type="character", default=NULL, help="directory to load data from")
)

parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
inputFile = args[['input']]

load(inputFile)

print(length(labValues))

