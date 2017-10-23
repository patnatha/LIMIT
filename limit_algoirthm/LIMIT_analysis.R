library(optparse)

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata")
)

#Parse the incoming options
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)

args <- parse_args(parser)
inputData = args[['input']]
load(inputData)

if(exists("parameters")){
    print("PARAMETERS")
    print(attributes(parameters))
}

print("Lab Values Quartiles")
print(as.numeric(quantile(as.numeric(cleanLabValues$l_val), c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)))
print(paste("Lab Values Count: ", length(cleanLabValues$l_val)))
print(paste("Unique Patient Count: ", length(unique(cleanLabValues$pid))))

