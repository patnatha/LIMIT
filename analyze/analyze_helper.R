
library(dplyr)
library(boot)

check_empty_labs_list <- function(theList){
    if(length(theList) == 0){
        return(data.frame(
                 pid=character(),
                 l_val=numeric(),
                 timeOffset=numeric(),
                 EncounterID=character(),
                 stringsAsFactors=FALSE))
    } else {
        return(theList)
    }
}

combineExcludedLists <- function(excludedICDs, excludedLabs, excludedMeds){
    excludeICDLabs = check_empty_labs_list(attr(parameters, "icd_excluded_labs"))
    excludeMedLabs = check_empty_labs_list(attr(parameters, "med_excluded_labs"))
    excludeLabLabs = check_empty_labs_list(attr(parameters, "lab_excluded_labs"))
    excludeCombined = check_empty_labs_list(attr(parameters, "combined_excluded_labs"))

    finalExcluded=union(
        excludeICDLabs %>% select(pid, l_val, timeOffset, EncounterID), 
        excludeMedLabs %>% select(pid, l_val, timeOffset, EncounterID), 
        excludeLabLabs %>% select(pid, l_val, timeOffset, EncounterID), 
        excludeCombined %>% select(pid, l_val, timeOffset, EncounterID))

    return(finalExcluded)
}

#Run the Horn.outliers algorithm
horn.outliers = function(data){
    boxcox = car::powerTransform(data$l_val)
    lambda = boxcox$lambda
    transData = data$l_val^lambda
    descriptives = summary(transData)
    Q1 = descriptives[[2]]
    Q3 = descriptives[[5]]
    IQR = Q3 - Q1
    out = transData[transData <= (Q1 - 1.5 * IQR) | transData >= (Q3 + 1.5 * IQR)]
    sub = transData[transData > (Q1 - 1.5 * IQR) & transData < (Q3 + 1.5 * IQR)]
    lineInSand=(list(outliers = out^(1/lambda), subset = sub^(1/lambda)))
    return(data %>% filter(l_val > min(lineInSand$subset) & l_val < max(lineInSand$subset)))
}

run_outliers = function(theData, runsCnt){
    print(paste("Lab Values Count: ", length(cleanLabValues$l_val)))
    print(paste("Lab Values Quantiles: ", paste(round(as.double(quantile(cleanLabValues$l_val, c(0.025, 0.975), na.rm = TRUE)), digits=2),collapse=" "), sep=""))

    if(length(cleanLabValues$l_val) <= 10){
        return(cleanLabValues)
    }

    out <- tryCatch({
        runs=0
        while(runs < runsCnt){
            outliered = horn.outliers(theData)
            runs=runs+1
            print(paste("Horn Outliers: ", runs, " (", nrow(theData), " - ", nrow(outliered), ")", sep=""))
        print(paste("Lab Values Quantiles: ", paste(round(as.double(quantile(outliered$l_val, c(0.025, 0.975), na.rm = TRUE)), digits=2),collapse=" "), sep=""))
            if(nrow(theData) == nrow(outliered)){
                theData = outliered
                break
            }
            theData = outliered
        }
        theData = outliered
    }, error=function(cond) {
        print(paste("ERROR: ", cond, sep=""))
    })
    return(theData)
}

#Run the boot parametric confidence interval
nonparRI = function (data, indices = 1:length(data), refConf)
{
    d = data[indices]
    results = c(quantile(d, (1 - refConf)/2, type = 6), quantile(d, 1 - ((1 - refConf)/2), type = 6, na.rm=T))
    return(results)
}

#Define the boot non-parametric function
run_intervals <- function(data, refConf, limitConf){
    #Set the reference interval
    refInterval_Method = "non_parametric" # parametric, non_parametric

    #Set the confidence interval and type of interval to calculate
    confInterval_Method = "non_parametric" # parametric, non_parametric, boot

    #Do some error checking on data and the parameters
    if(confInterval_Method == "non_parametric"){ 
        if(length(data) >= 119 && length(data) <= 1000){
            if(refConf != 0.95 && limitConf != 0.90){
                #This function is a table look up that only works for one RI/CI pair
                confInterval_Method = "boot"
            }
        } else if(length(data) > 1000){
            #Switch to parametric if large sample size
            #refInterval_Method = "parametric"
            #confInterval_Method = "parametric"
        }
    }

    lowerRefLimit = NA
    upperRefLimit = NA

    lowerRefLowLimit = NA
    lowerRefUpperLimit = NA
    upperRefLowLimit = NA
    upperRefUpperLimit = NA

    if(length(data) > 0){
        #Run the parametric analysis 
        if(refInterval_Method == "parametric"){
            confInterval_Method = "parametric"

            refZ = qnorm(1 - ((1 - refConf)/2))
            limitZ = qnorm(1 - ((1 - limitConf)/2))

            mean = mean(data, na.rm = TRUE)
            sd = sd(data, na.rm = TRUE)

            lowerRefLimit = mean - refZ * sd
            upperRefLimit = mean + refZ * sd

            se = sqrt(((sd^2)/length(data)) + (((refZ^2) * (sd^2))/(2 * length(data))))

            lowerRefLowLimit = lowerRefLimit - limitZ * se
            lowerRefUpperLimit = lowerRefLimit + limitZ * se
            upperRefLowLimit = upperRefLimit - limitZ * se
            upperRefUpperLimit = upperRefLimit + limitZ * se

            if(length(data) > 5000){
                shap_normalcy = shapiro.test(sample(data, 5000))
            } else {
                shap_normalcy = shapiro.test(data)
            }
            shap_output = paste(c("Shapiro-Wilk: W = ", format(shap_normalcy$statistic, digits = 6), ", p-value = ", format(shap_normalcy$p.value, digits = 6)), collapse = "")
            ks_normalcy = suppressWarnings(ks.test(data, "pnorm", m = mean, sd = sd))
            ks_output = paste(c("Kolmorgorov-Smirnov: D = ", format(ks_normalcy$statistic, digits = 6), ", p-value = ", format(ks_normalcy$p.value, digits = 6)), collapse = "")

            print(shap_output)
            print(ks_output)

            #If sample data is not normal then run it non-parametrically
            if(shap_normalcy$p.value >= 0.05 && ks_normalcy$p.value >= 0.05){
                confInterval_Method = "non_parametric"
                refInterval_Method = "non_parametric"
            }
        }

        if (refInterval_Method == "non_parametric") {
            data = sort(data)
            holder = nonparRI(data, indices = 1:length(data), refConf)
            lowerRefLimit = holder[1]
            upperRefLimit = holder[2]
        }

        if (confInterval_Method == "non_parametric") {
            if (length(data) < 119) {
                confInterval_Method = "boot"
            }
            else if (length(data) >= 119 && length(data) <= 1000){
                methodCI = "Confidence Intervals calculated nonparametrically"
                data = sort(data)

                #This function uses a hard coded table for 90% CI on 95% RI
                load("nonparRanks.Rdata")
                refConf = 0.95
                limitConf = 0.90
                ranks = subset(nonparRanks, subset = (nonparRanks$SampleSize == length(data)))
 
                lowerRefLowLimit = data[ranks$Lower]
                lowerRefUpperLimit = data[ranks$Upper]
                upperRefLowLimit = data[(length(data) + 1) - ranks$Upper]
                upperRefUpperLimit = data[(length(data) + 1) - ranks$Lower]
            } else {
                confInterval_Method = "boot"
            } 
        }

        if (confInterval_Method == "boot" && refInterval_Method == "non_parametric"){
            print("Bootstrapping confidence intervals")
            bootresult = boot(data = data, statistic = nonparRI, refConf = refConf, R = 5000)

            #get the confidence intervals from the boot result
            bootresultlower = boot.ci(bootresult, conf = limitConf, type = "basic", index = 1)
            bootresultupper = boot.ci(bootresult, conf = limitConf, type = "basic", index = 2)

            #Get the upper and lower limits for limits for displaying
            lowerRefLowLimit = bootresultlower$basic[4]
            if(is.null(lowerRefLowLimit)){ lowerRefLowLimit = NA }
            lowerRefUpperLimit = bootresultlower$basic[5]
            if(is.null(lowerRefUpperLimit)){ lowerRefUpperLimit = NA }
            upperRefLowLimit = bootresultupper$basic[4]
            if(is.null(upperRefLowLimit)){ upperRefLowLimit = NA }
            upperRefUpperLimit = bootresultupper$basic[5]
            if(is.null(upperRefUpperLimit)){ upperRefUpperLimit = NA }
        }
    }

    print(paste("Lab Values Quantiles: ", paste(round(((1 - refConf)/2.0)*100, digits=1), "% <=CI=> ", round(100-(((1 - refConf)/2.0)*100), digits=1),"%: (", lowerRefLowLimit, "-", lowerRefUpperLimit, ") <=> (", upperRefLowLimit, "-", upperRefUpperLimit, ")", sep="")), sep="")
    
    results<-1:1
    attr(results, "lowerRefLimit") = lowerRefLimit
    attr(results, "upperRefLimit") = upperRefLimit
    attr(results, "lowerRefLowLimit") = lowerRefLowLimit
    attr(results, "lowerRefUpperLimit") = lowerRefUpperLimit
    attr(results, "upperRefLowLimit") = upperRefLowLimit
    attr(results, "upperRefUpperLimit") = upperRefUpperLimit
    attr(results, "confInterval_Method") = confInterval_Method
    attr(results, "refInterval_Method") = refInterval_Method
    attr(results, "refInterval") = refConf
    attr(results, "confInterval") = limitConf
    return(results)
}

calculateDiffRatio <- function(goldStandRefLow, goldStandRefHigh, procLow, procHigh){
    divisior = NA
    if(!is.na(goldStandRefLow) && !is.na(goldStandRefHigh) && 
       !is.na(procLow) && !is.na(procHigh)){
        divisior = 2.0
    } else if((!is.na(goldStandRefLow) && is.na(goldStandRefHigh) && !is.na(procLow)) ||
              (is.na(goldStandRefLow) && !is.na(goldStandRefHigh) && !is.na(procHigh))){
        divisior = 1.0
    }

    if(!is.na(divisior)){
        totalScore = 0
        if(!is.na(goldStandRefLow) && !is.na(procLow)){
            totalScore = totalScore + (abs(as.double(goldStandRefLow) - as.double(procLow)) / as.double(goldStandRefLow))
        }
        if(!is.na(goldStandRefHigh) && !is.na(procHigh)){
            totalScore = totalScore + (abs(as.double(goldStandRefHigh) - as.double(procHigh)) / as.double(goldStandRefHigh))
        }
        return(totalScore / divisior)
    } else {
        return(NA)
    }
}

write_line_append <- function(parameters, postHornCount, preLimitRef, refConfResults){
    tResultCode=toupper(attributes(parameters)$resultCodes[[1]])
    tSex=tolower(attributes(parameters)$sex)
    tRace=tolower(attributes(parameters)$race)
    tStime=attributes(parameters)$start_time
    tEtime=attributes(parameters)$end_time


    #Get the Gold Standard Reference Ranges
    findReference=import_reference_range(tResultCode, tSex, tRace, tStime, tEtime, c("CALIPER"))
    goldStandRefLow = findReference[[1]]
    goldStandRefHigh = findReference[[2]]
    goldStandRefSource = findReference[[3]]
    print(paste("Gold Standard Reference: ", goldStandRefLow, ' - ' , goldStandRefHigh, " (", goldStandRefSource, ")", sep=""))

    #Get the Fold Standard Reference Ranges
    findReference=import_confidence_range(tResultCode, tSex, tRace, tStime, tEtime, c("CALIPER"))
    goldStanConfLowLow = findReference[[1]]
    goldStandConfLowHigh = findReference[[2]]
    goldStandConfHighLow = findReference[[3]]
    goldStandConfHighHigh = findReference[[4]]
    goldStandConfSource = findReference[[5]]
    print(paste("Gold Standard Confidence: ", goldStanConfLowLow, " - ", goldStandConfLowHigh, " <=> ", goldStandConfHighLow, " - ", goldStandConfHighHigh, " (", goldStandConfSource, ")", sep=""))

    #Original results
    origRefLow = preLimitRef[[1]]
    origRefHigh = preLimitRef[[2]]
    origRatio = calculateDiffRatio(goldStandRefLow, goldStandRefHigh, origRefLow, origRefHigh)
 
    #Limit results
    limitRefLow = attr(refConfResults, "lowerRefLimit")
    limitRefHigh = attr(refConfResults, "upperRefLimit")
    limitRatio = calculateDiffRatio(goldStandRefLow, goldStandRefHigh, limitRefLow, limitRefHigh)

    #Limit parameters string
    limitParams = paste("H", attr(parameters, "criticalHampel"), "_P", attr(parameters, "criticalP"), "_PROP", attr(parameters, "criticalProp"), "_POST_", attr(parametres, "post_offset"), "_PRE", attr(patameters, "pre_offset"), sep="")

    print(paste("Difference Radio: ", origRatio, " => ", limitRatio, sep=""))
    newLine = c(basename(inputData),
                paste(attributes(parameters)$resultCodes, collapse="_"),
                gsub(",","_",attributes(parameters)$group),
                tSex, tRace, tStime, tEtime,
                attr(parameters, "selection"),
                limitParams, 
                attr(parameters, "icd_pre_limit"),
                attr(parameters, "icd_post_limit"),
                attr(parameters, "med_post_limit"),
                attr(parameters, "lab_post_limit"),
                attr(parameters, "joined_count"),
                attr(parameters, "combined_count"),
                postHornCount,
                preLimitRef, 
                attr(refConfResults, "lowerRefLimit"),
                attr(refConfResults, "upperRefLimit"),
                attr(refConfResults, "refInterval"),
                attr(refConfResults, "refInterval_Method"),
                attr(refConfResults, "lowerRefLowLimit"),
                attr(refConfResults, "lowerRefUpperLimit"),
                attr(refConfResults, "upperRefLowLimit"),
                attr(refConfResults, "upperRefUpperLimit"),
                attr(refConfResults, "confInterval"),
                attr(refConfResults, "confInterval_Method"),
                goldStandRefLow, goldStandRefHigh, goldStandRefSource,
                goldStanConfLowLow, goldStandConfLowHigh, goldStandConfHighLow, goldStandConfHighHigh, goldStandConfSource, origRatio, limitRatio)

    write(newLine,ncolumns=length(newLine),sep=",",file=theResultFile, append=TRUE)
}

