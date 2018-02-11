
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

    glimpse(finalExcluded)
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
    print(paste("Lab Values Quantiles: ", paste(round(as.double(quantile(cleanLabValues$l_val, c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)), digits=2),collapse=" "), sep=""))

    runs=0
    while(runs < runsCnt){
        outliered = horn.outliers(theData)
        runs=runs+1
        print(paste("Horn Outliers: ", runs, " (", nrow(theData), " - ", nrow(outliered), ")", sep=""))
    print(paste("Lab Values Quantiles: ", paste(round(as.double(quantile(outliered$l_val, c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)), digits=2),collapse=" "), sep=""))
        if(nrow(theData) == nrow(outliered)){
            theData = outliered
            break
        }
        theData = outliered
    }
    theData = outliered
    return(theData)
}

#Run the boot parametric confidence interval
nonparRI = function (data, indices = 1:length(data), refConf = 0.95)
{
    d = data[indices]
    results = c(quantile(d, (1 - refConf)/2, type = 6), quantile(d,
    1 - ((1 - refConf)/2), type = 6))
    return(results)
}



#Define the boot non-parametric function
run_intervals <- function(data, refConf, limitConf){
    #Set the reference interval
    refInterval_Method = "parametric" # parametric, non_parametric

    #Set the confidence interval and type of interval to calculate
    confInterval_Method = "parametric" # parametric, non_parametric, boot

    lowerRefLimit = NA
    upperRefLimit = NA

    lowerRefLowLimit = NA
    lowerRefUpperLimit = NA
    upperRefLowLimit = NA
    upperRefUpperLimit = NA

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
        #If sample data is nor normal then run it non-parametrically
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

        #Confidence intervals can only be parametric if reference interval is as well
        if (confInterval_Method == "parametric") {
            confInterval_Method = "non_parametric"
        }
    }

    #Run non-parametric analysis
    if (confInterval_Method == "non_parametric") {
        if (length(data) < 120) {
            #Sample size too small for non-parametric CI, bootstrapping!
            confInterval_Method = "boot"
        }
        else {
            methodCI = "Confidence Intervals calculated nonparametrically"
            ranks = subset(nonparRanks, subset = (nonparRanks$SampleSize == length(data)))
            lowerRefLowLimit = data[ranks$Lower]
            lowerRefUpperLimit = data[ranks$Upper]
            upperRefLowLimit = data[(length(data) + 1) - ranks$Upper]
            upperRefUpperLimit = data[(length(data) + 1) - ranks$Lower]
        }
    }

    if (confInterval_Method == "boot" && refInterval_Method == "non_parametric"){
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

write_line_append <- function(parameters, postHornCount, preLimitRef, refConfResults){
    tResultCode=toupper(attributes(parameters)$icd_result_code[[1]])
    tSex=tolower(attributes(parameters)$icd_sex)
    tRace=tolower(attributes(parameters)$icd_race)
    tStime=attributes(parameters)$icd_start_time
    tEtime=attributes(parameters)$icd_end_time

    print(paste("Find Gold Standard Reference:", tResultCode, tSex, tRace, tStime, tEtime, sep=" "))
    findReference=import_reference_range(tResultCode, tSex, tRace, tStime, tEtime, "MAYO")
    goldStandardRefLow = findReference[[1]]
    goldStandardRefHigh = findReference[[2]]
    print(paste("Gold Standard Reference: ", goldStandardRefLow, ' - ' , goldStandardRefHigh, sep=""))

    newLine = c(basename(inputData),
                paste(attributes(parameters)$icd_result_code, collapse="_"),
                gsub(",","_",attributes(parameters)$icd_group),
                tSex, tRace, tStime, tEtime,
                attr(parameters, "icd_selection"),
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
                goldStandardRefLow, goldStandardRefHigh)

    write(newLine,ncolumns=length(newLine),sep=",",file=theResultFile, append=TRUE)
}
