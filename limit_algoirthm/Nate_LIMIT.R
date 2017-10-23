## Arguments
criticalProp = 0.005
criticalP = 0.05
criticalHampel = 3
saving = 'tmp'
day_time_offset = 5

#Count the number of CPUs available
cpuCnt<-system("nproc", ignore.stderr = TRUE, intern = TRUE)
parallelCores<-strtoi(cpuCnt)

#Load up the data from command line argument
library(optparse)
library(dplyr)
library(parallel)

#Create the options list
option_list <- list(
  make_option("--output", type="character", default="/scratch/leeschro_armis/patnatha/limit_results/", help="directory to put results"),
  make_option("--input", type="character", default=NA, help="file to load Rdata"),
  make_option("--name", type="character", default=NA, help="name of file to output"),
  make_option("--codes", type="character", default="icd", help="which codes to run against [med|icd]"),
  make_option("--critical-proportion", type="double", default=0.005, help="critical proportion of icd values to perform fishers"),
  make_option("--critical-p-value", type="double", default=0.05, help="critical p-value for fisher's test cutoff"),
  make_option("--critical-hampel", type="integer", default=3, help="hampel algorithm cutoff"),
  make_option("--day-time-offset", type="integer", default=5, help="Offset in days from lab values to include values")
)

#Parse the incoming options
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

#Assign the parsed options to their variable
criticalProp = args[['critical-proportion']]
criticalP = args[['critical-p-value']]
criticalHampel = args[['critical-hampel']]
outputDir = args[['output']]
outputName = args[['name']]
inputData = args[['input']]
day_time_offset = args[['day-time-offset']]
codeType = args[['codes']]
versioning = '1.1'

#Check the output directory exists
if(!dir.exists(outputDir)){
    print("The output directory doesn't exist")
    stop()
}

#Load RData from disk
if(is.na(inputData) || !file.exists(inputData)){
    print("The input file path doesn't exist")
    stop()
}
load(inputData);

#Check to see if the code type had been selected
if(!is.na(codeType)){
    # Run algorithm against administered medicines
    if(codeType == 'med'){
        icdValues = medValues
    }
}else{
    print("A code type has not been selected [icd|med]")
    stop()
}

#Check to make sure the name parameter was set
if(is.na(outputName)){
    outputName = strsplit(basename(inputData), "[.]")[[1]][[1]]
    outputName = paste(outputName, codeType, sep="_")
}

#Create the output file
saving = gsub('//', '/', paste(outputDir, outputName, sep="/"))
saving = paste(saving, '.Rdata', sep="")

#Check to see if the file exists
if(file.exists(saving)){
    while(file.exists(saving)){
        #Extract the filename from the path
        persplit = strsplit(basename(saving), ".", fixed = TRUE)[[1]]
        getnum = strsplit(persplit[1], "_")[[1]]
   
        #Calculate the new path name
        if(is.na(as.numeric(tail(getnum, n = 1)))){
            getnum[[length(getnum) + 1]] = 1
        }
        else{
            getnum[[length(getnum)]] = as.numeric(tail(getnum, n=1)) + 1
        }
 
        #Build the new path 
        outputName=paste(getnum, collapse="_") 
        saving = gsub('//', '/', paste(outputDir, outputName, sep="/"))
        saving = paste(saving, '.Rdata', sep="")
    }
}

#Save all the parameters to a structure
parameters<-1:9
attr(parameters, "criticalProp") <- criticalProp
attr(parameters, "criticalP") <- criticalP
attr(parameters, "criticalHampel") <- criticalHampel
attr(parameters, "outputDir") <- outputDir
attr(parameters, "outputName") <- outputName
attr(parameters, "day_time_offset") <- day_time_offset
attr(parameters, "codeType") <- codeType
attr(parameters, "versioning") <- versioning
attr(parameters, "inputData") <- inputData

#Run the hampel outlier detection
hampel = function(x, t = 3, RemoveNAs = TRUE) {
  #
  #  This procedure returns an index of x values declared
  #  outliers according to the Hampel detection rule, if any
  #
  mu = median(x, na.rm = RemoveNAs)
  sig = mad(x, na.rm = RemoveNAs)
  indx = which(abs(x - mu) > t *sig)
  
  return(indx)
}

FindICDs = function(pid, data, icdValues, day_time_offset) {
    if(is.na(pid) | is.null(pid) | pid == ""){
        return(list())
    }

    # Get the first timestamp of labValue for the input pid
    theTime = min(data$timeOffset[which(data$pid == pid)])

    #Return NA for errors
    if(is.na(theTime) | is.null(theTime)){
        return(list())
    }

    #Get ICD values assigned before the time of the lab value
    #ind = intersect(which(icdValues$pid == pid), 
    #                which(icdValues$timeOffset <= (as.numeric(theTime) + day_time_offset)))
    ind = which(icdValues$pid == pid & icdValues$timeOffset <= (as.numeric(theTime) + day_time_offset))

    #Get the unique list of ICD values
    codes = unique(icdValues$icd[ind])

    #Return the list of codes 
    return(codes) 
}

PerformFishertestICD = function(ICD, icdValues, flaggedTable, totalFlagged, unflagged) { 
    if (!is.na(ICD)) {
        # Find number of flagged patients with the code of interest, and calculate number without
        numFlaggedWithCode = flaggedTable[which(flaggedTable$icd == ICD),]$freq
        numFlaggedWithoutCode = totalFlagged - numFlaggedWithCode

        # Get the pids that use this ICD 
        allWithCode = unique(icdValues$pid[which(icdValues$icd == as.character(ICD))])

        # Find number of unflagged patients who have this code, and number who do not
        numUnflaggedWithCode = length(intersect(unflagged, allWithCode))
        numUnflaggedWithoutCode = length(unflagged) - numUnflaggedWithCode
        
        # Perform Fisher's exact test to see if flagged population has significantly higher proportion of patients with this code. Return p value
        fisherResult = fisher.test(matrix(c(numFlaggedWithCode, numFlaggedWithoutCode, numUnflaggedWithCode, numUnflaggedWithoutCode), nrow = 2), alternative = "greater")
        
        return(fisherResult$p.value)  
    } else {
        return(0)
    }
}

FindExclusions = function(disease) {
    #Get list of unique PIDs that have the input value
    exclude1 = unique(icdValues$pid[which(icdValues$icd == disease)])
    return(exclude1)
}

# Remove the empty values
labValues = labValues %>% filter(!is.na(pid) & !is.null(pid) & !pid == "")
labValues = labValues %>% filter(!is.na(as.numeric(l_val)))


#Print the original results
print("Lab Values Quartiles")
print(as.numeric(quantile(as.numeric(labValues$l_val), c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)))
print(paste("Lab Values Count: ", length(labValues$l_val)))
print(paste("Patient Count: ", length(unique(labValues$pid))))

# Create data set
labValues$outlier = rep(FALSE, length(labValues$pid))

# Initialise logical convergence indicator
converged = FALSE

# Structures to keep track of excluded items
excludedICDs = list()
excludedICDNames = list()
excludedPatients = list()
excludedCounts = list()
excludedPval = list()

# Get the mean and MAD of the lab values
mu = median(as.numeric(labValues$l_val), na.rm = TRUE)
sig = mad(as.numeric(labValues$l_val), na.rm = TRUE)

#CONVERGE
debug = TRUE
iteration = 0
while (!converged) {
    # Initialise indices of outliers using Hampels method
    outliers = hampel(as.numeric(labValues$l_val), criticalHampel, TRUE)
    labValues$outlier[outliers] = TRUE

    #Print some interation output for notification
    iteration = iteration + 1
    print(paste("Outliers ","(", as.character(iteration), "): ", length(which(labValues$outlier == TRUE)), sep=""))


    # Only run algorith if there are some non-outliers
    if (length(which(labValues$outlier == FALSE)) > 100) {
        # Create lists of patients with flagged tests
        flaggedPatients = unique(labValues$pid[which(labValues$outlier == TRUE)])
        totalFlaggedPatients = length(flaggedPatients)
        if(debug){
            print(paste("Flagged Unique Patients: ", unique(totalFlaggedPatients), sep=""))
        }

        #Create  lists of patients with unflagged test
        unflaggedPatients = setdiff(unique(labValues$pid), flaggedPatients)
        totalUnflaggedPatients = length(unflaggedPatients)

        # Create list of flagged test results 
        flaggedResults = labValues[which(labValues$outlier == TRUE),]
        
        #Order the values based on age
        flaggedResults = flaggedResults[order(flaggedResults$timeOffset), ]

        #Remove duplicate pids
        flaggedResults = flaggedResults[!(duplicated(flaggedResults$pid)), ]

        if(debug){
            print(paste("Flagged Results: ", length(flaggedResults$pid), sep=""))   
        }

        if (length(flaggedResults$pid) > 4) {
            # Find all ICD codes for patients with flagged test results, before the first test
            start.time <- Sys.time()
            #ICDs = sapply(flaggedPatients, FindICDs, flaggedResults, icdValues, day_time_offset)
            cl = makeCluster(parallelCores, outfile='~/parSapply.out')
            ICDs = parSapply(cl=cl, flaggedPatients, FindICDs, flaggedResults, icdValues, day_time_offset)
            stopCluster(cl)
            if(debug){
                time.taken <- as.numeric(Sys.time() - start.time, units="secs")
                print(paste("Finding ICDs: ", as.character(time.taken), " secs", sep=""))
            }

            # Process the results
            if (length(ICDs) != 0) {
                #Flatten the list of ICDs with counts
                ICDtable = as.data.frame(table(unlist(ICDs, recursive=FALSE)), useNA = 'no')
                
                #Rename the columns
                ICDtable$icd = ICDtable$Var1
                ICDtable$freq = ICDtable$Freq
                ICDtable = ICDtable[c("icd", "freq")]
                
                #Order the ICD tables on freq
                ICDtable = ICDtable[order(ICDtable$freq, decreasing = TRUE), ]

                # Calculate the limit value
                limit = which(ICDtable$freq <= ceiling(totalFlaggedPatients * criticalProp))[1] - 1
                if (is.na(limit)) {
                    limit = length(ICDtable$freq)
                }

                # Perform Fisher's exact test on this table 
                start.time <- Sys.time()
                #fisherTestICD = sapply(ICDtable[(1:limit),]$icd, PerformFishertestICD, icdValues, ICDtable, totalFlaggedPatients, unflaggedPatients)
                cl <- makeCluster(parallelCores)
                fisherTestICD = parSapply(cl=cl, ICDtable[(1:limit),]$icd, PerformFishertestICD, icdValues, ICDtable, totalFlaggedPatients, unflaggedPatients)                
                stopCluster(cl)
                if(debug){
                    time.taken <- as.numeric(Sys.time() - start.time, units="secs")
                    print(paste("Fisher Testing: ", as.character(time.taken, units="secs"), " secs", sep=""))
                }

                fisherTestICD = p.adjust(fisherTestICD, method = 'bonferroni')
                DOI = as.character(ICDtable[which.min(fisherTestICD),]$icd)

                # Get the minumum Fisher value 
                pvalue = min(fisherTestICD)

                if (pvalue > criticalP) {
                    converged = TRUE
                    excludePID = numeric()
                } else {
                    #Find the ICD code for this given name
                    DOIName = unique(icdValues$icd_name[which(icdValues$icd == DOI)])
                    print(paste('CODE NAME: ', DOIName, sep=""))

                    # Removing ICD
                    print(paste('CODE: ', DOI, sep=""))

                    # Find all patients who have the significant codes
                    excludePID = FindExclusions(DOI)

                    #Keep track of which codes were excluded and their p-values at exclusion 
                    excludedICDs = c(excludedICDs, DOI)
                    excludedICDNames = c(excludedICDNames, DOIName)
                    excludedPatients = append(excludedPatients, excludePID)
                    excludedCounts = c(excludedCounts, 
                                        length(which(labValues$pid %in% excludePID)))
                    excludedPval = c(excludedPval, pvalue)
                }
            } else {
                excludePID = numeric()
            }
          
            # Remove excluded patients from data base
            includePatients = setdiff(unique(labValues$pid), excludePID)
            labValues = labValues[which(labValues$pid %in% includePatients), ]
        } else {
            converged = TRUE
        }
    } else {
        converged = TRUE
    }
}

print("Lab Values Quartiles")
print(as.numeric(quantile(as.numeric(labValues$l_val), c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)))
print(paste("Lab Values Count: ", length(labValues$l_val)))
print(paste("Patient Count: ", length(unique(labValues$pid))))

#Save the updated labValues and excluded ICD values
cleanLabValues = labValues
save(parameters, cleanLabValues, excludedPatients, excludedICDs, excludedICDNames, excludedCounts, excludedPval, file=saving)

