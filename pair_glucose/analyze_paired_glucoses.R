#Load up the paired glucose values
source('../encounters_wrapper.R')
source('glucose_paths.R')
load(paired_glucoses_path)

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

