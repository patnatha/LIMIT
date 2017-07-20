library(BBmisc)

# Bin pack algorithm
binPack = function(x, capacity) {
  #assertNumeric(x, min.len = 1L, lower = 0, any.missing = FALSE)
  #assertNumber(capacity)

  too.big = which.first(x > capacity, use.names = FALSE)
  if (length(too.big))
    stopf("Capacity not sufficient. Item %i (x=%f) does not fit", too.big, x[too.big])
  if (any(is.infinite(x)))
    stop("Infinite elements found in 'x'")

  ord = order(x, decreasing = TRUE)
  grp = integer(length(x))
  sums = vector(typeof(x), 1L)
  bin.count = 1L

  for(j in ord) {
    new.sums = sums + x[j]
    pos = which.first(new.sums <= capacity, use.names = FALSE)
    if (length(pos)) {
      grp[j] = pos
      sums[pos] = new.sums[pos]
    } else {
      bin.count = bin.count + 1L
      grp[j] = bin.count
      sums[bin.count] = x[j]
    }
  }
  grp
}

#The dirsource('glucose_paths.R')ectory from which to read
source('glucose_paths.R')

#Create the output directory
if(dir.exists(paired_pieces_output)){
    unlink(paired_pieces_output, recursive = TRUE)
}
dir.create(paired_pieces_output)

# Import the data
source("../import_files.R")
glucoseVals = import_lab_values(inputDir)

#Pick out the columns that we need for analyzing
selected_glucoses = select(glucoseVals, one_of(c('PatientID', 'ACCESSION_NUMBER', 'COLLECTION_DATE', 'RESULT_CODE', 'VALUE')))

#Get a count of the largest bin
opidCnt = selected_glucoses %>% group_by(PatientID) %>% count() %>% filter(n > 1) 
pidCnt = (tbl_df(opidCnt))
pidCnt$rowname = as.integer(pidCnt$rowname)
maxPtCnt = max(pidCnt$n)
if(maxPtCnt < 100000){
    maxPtCnt = 100000
}

# Pack the bins using a greedy algorithm
packedBins = binPack(pidCnt$n, maxPtCnt)
splitBins = split(pidCnt$n, packedBins)

newSplitBins = list()
for(bin in splitBins){
    # Get frequency of bins occurences
    binCnts = table(bin)
    tmpBinList = list()

    #Iterate over all these frequencies
    for(cntName in names(binCnts)){
        #Get the Pids with this many bins
        foundBin =  tibble::rownames_to_column(pidCnt) %>%
                    filter(n == as.numeric(cntName)) %>% 
                    head(binCnts[[cntName]])
        
        if(nrow(foundBin) > 0){
            for(pid in foundBin$PatientID){
                tmpBinList[[length(tmpBinList)+1]] = pid
            }
           
            # Remove the used Pids
            pidCnt = pidCnt[-(as.integer(foundBin$rowname)),]
        }
    }

    #update the bins
    newSplitBins[[length(newSplitBins)+1]] = tmpBinList
}

#Iterate over all the bins
binCounter = 1
for(bin in newSplitBins){
    # Get all the records
    records = selected_glucoses %>% filter(PatientID %in% bin)

    # Create a bin to fill with data
    print(paste("Binning (", as.character(nrow(records)), "): ", as.character(binCounter), '/', as.character(length(splitBins)), sep=""))

    # Get all the records 
    records = selected_glucoses %>% filter(PatientID %in% bin)

    #Save the output file
    save(records, file=paste(paired_pieces_output, as.character(binCounter), ".bin", sep=""))
    binCounter = binCounter + 1
}

