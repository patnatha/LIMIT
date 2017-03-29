## Arguments
criticalProp = 0.005
criticalP = 0.05
criticalHampel = 3
saving = 'tmp'
dataType = 'HGB'
logData = TRUE
day_time_offset = 5

library(stats)    

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


FindICDs = function(pid, data, icdValues) {
  time = min(data$timeOffset[which(data$pid == pid)])
  ind = intersect(which(icdValues$pid == as.numeric(pid)), which(icdValues$timeOffset <= (as.numeric(time) + day_time_offset)))
  codes = unique(icdValues$icd[ind])
  return(codes) 
}

PerformFishertestICD = function(ICD, flaggedTable, totalFlagged, unflagged) { 
  if (!is.na(ICD)) {
    # Find number of flagged patients with the code of interest, and calculate number without
    numFlaggedWithCode = flaggedTable[which(flaggedTable[, 1] == ICD), 2]
    numFlaggedWithoutCode = totalFlagged - numFlaggedWithCode
    
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
  exclude1 = unique(icdValues$pid[which(icdValues$icd == disease)])
  return(exclude1)
}

# Create data set
labValues$outlier = rep(FALSE, length(labValues$pid))

# Initialise logical convergence indicator
converged = FALSE

# Initialise iteration value
iteration = 1

excludedICDs = list(numeric(0))

exclusionCounts = list(numeric(0))

exclusionII = list(numeric(0))

exclusionPval = list(numeric(0))

excludedIngrs = numeric()

mu = median(as.numeric(labValues$l_vals), na.rm = TRUE)
sig = mad(as.numeric(labValues$l_vals), na.rm = TRUE)

#CONVERGE
while (!converged) {
  
  # Initialise indices of outliers
  outliers = hampel(as.numeric(labValues$l_vals), criticalHampel, TRUE)
  labValues$outlier[outliers] = TRUE
  
  iteration = iteration + 1
  
  if (length(which(labValues$outlier == FALSE)) > 100) {
    # Create lists of patients with flagged and unflagged haemoglobin tests
    flaggedPatients = unique(labValues$pid[which(labValues$outlier == TRUE)])
    totalFlaggedPatients = length(flaggedPatients)
    unflaggedPatients = setdiff(unique(labValues$pid), flaggedPatients)
    totalUnflaggedPatients = length(unflaggedPatients)
    
    # Create list of flagged test results - take the first flagged test for each patient
    flaggedResults = labValues[which(labValues$outlier == TRUE), ]
    #Order on Date
    flaggedResults = flaggedResults[order(flaggedResults[, 3]), ]
    #Remove duplicate pids
    flaggedResults = flaggedResults[!(duplicated(flaggedResults[, 1])), ]
    
    if (length(flaggedResults$pid) > 10) {
      # Find all ICD codes for patients with flagged test results, before the date of this first flagged test
      ICDs = sapply(flaggedPatients, FindICDs, flaggedResults, icdValues)
      haveICDs = FALSE
      if (length(ICDs) != 0) {
        ICDtable = as.data.frame(table(unlist(ICDs)), useNA = 'no')
        ICDtable = ICDtable[order(ICDtable$Freq, decreasing = TRUE), ]
        haveICDs = TRUE
      }
      
      # Create strings listing all diseases and drugs that are significantly overrepresented in out of range patients.
      # Significant overrepresentation is considered to be present if the p value from the Fisher's exact test is less than criticalP
      if (haveICDs) {
        # Create contingency table for the relationship between a disease and flagged test result.
        # Perform Fisher's exact test on this table
        # Only perform this analysis for diseases that are present in a given proportion of flagged patients (criticalProp)
        limit = which(ICDtable$Freq <= ceiling(totalFlaggedPatients * criticalProp))[1] - 1
        if (is.na(limit)) {
          limit = length(ICDtable$Freq)
        }
        
        fisherTestICD = sapply(ICDtable[(1:limit), 1], PerformFishertestICD, ICDtable, totalFlaggedPatients, unflaggedPatients)
        fisherTestICD = p.adjust(fisherTestICD, method = 'bonferroni')
        DOI = as.character(ICDtable[which.min(fisherTestICD), 1])
        
        pvalue = min(fisherTestICD)
        if (pvalue > criticalP) {
          converged = TRUE
          exclude1 = numeric(0)
        } else {
          # Find all patients who have the significant ICD codes
          exclude1 = FindExclusions(DOI)
          exclusionCounts = c(exclusionCounts, length(which(labValues$pid %in% unique(exclude1))))
          exclusionII = c(exclusionII)
          excludedICDs = c(excludedICDs, DOI)
          exclusionPval = c(exclusionPval, pvalue)
        }
      } else {
        exclude1 = numeric(0)
      }
      
      # Create a list of all patients with either significant diseases or drugs
      excludePatients = unique(exclude1)
      includePatients = setdiff(unique(labValues$pid), excludePatients)
      
      # Remove excluded patients from data base
      labValues = labValues[which(labValues$pid %in% includePatients), ]
    } else {
      excludePatients = numeric(0)
      converged = TRUE
    }
  } else {
    converged = TRUE
  }
}

print(as.numeric(quantile(as.numeric(labValues$l_vals), c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)))
print(length(unique(labValues$pid)))

results = matrix(0, 1, 3)
results[1, 1:2] = as.numeric(quantile(as.numeric(labValues$l_vals), c(0.025, 0.975), na.rm = TRUE))
results[1, 3] = length(unique(labValues$pid))

