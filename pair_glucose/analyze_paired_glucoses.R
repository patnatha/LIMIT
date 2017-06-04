#Load up the paired glucose values
source('glucose_paths.R')
load(paired_glucoses)

# Find the differences
results$value_diff = results$one_value - results$two_value

#Get ride of invalid values
the_inds=which(is.na(results$value_diff))
results=setdiff(results, results[the_inds,])

#Calculate five numb sum
fivenumsum<-summary(results$value_diff)
print("FIVE NUM SUM")
print(fivenumsum)

#Calculate STD DEV
stddev<-sd(results$value_diff, na.rm = TRUE)
print(paste("ERROR:", as.character(stddev), sep=" "))

#Calculate STD ERR
error <- qnorm(0.975)* stddev / sqrt(length(results$value_diff))
print(paste("ERROR:", as.character(error), sep=" "))
left <- mean(results$value_diff) - error
right <- mean(results$value_diff) + error
print(paste("95% CI", as.character(left), '<=>', as.character(right), sep=" "))

