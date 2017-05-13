for(i in 1:nrow(results)){
    theRow = results[i,]
    
    glucone_value = as.numeric(as.character(theRow$one_value))
    glucone_code = as.character(theRow$one_code)
    gluctwo_value = as.numeric(as.character(theRow$two_value))
    
    if(glucone_code == "GLUC"){
        valDiff = gluctwo_value - glucone_value
    }
    else if(glucone_code == "GLUC-WB"){
        valDiff = glucone_value - gluctwo_value
    }
    
    results[i,]$value_diff = valDiff
}

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
