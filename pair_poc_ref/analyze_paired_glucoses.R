#Load up the paired glucose values
source('paired_paths.R')
library(optparse)
option_list <- list(
    make_option("--input", type="character", default=NA, help="directory to load data from")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

# Check to see that intput file exists
input_val = args[['input']]
if(!file.exists(args[['input']])){
    print("The input file doesn't exist")
    stop()
}

load(input_val)

# Find the differences
results$value_diff = results$one_value - results$two_value

#Get ride of invalid values
the_inds=which(is.na(results$value_diff))
results=setdiff(results, results[the_inds,])

#Print out a list of all the results
print("Results Count")
print(nrow(results))

#Calculate five numb sum
fivenumsum<-summary(results$value_diff)
print("FIVE NUM SUM")
print(fivenumsum)

#Calculate STD DEV
stddev<-sd(results$value_diff, na.rm = TRUE)
print(paste("Std Dev", as.character(stddev), sep=" "))

#Calculate STD ERR
error <- qnorm(0.975)* stddev / sqrt(length(results$value_diff))
print(paste("STD ERROR:", as.character(error), sep=" "))
left = mean(results$value_diff, na.rm = TRUE) - error
right = mean(results$value_diff, na.rm = TRUE) + error
print(paste("95% CI", as.character(left), '<=>', as.character(right), sep=" "))

