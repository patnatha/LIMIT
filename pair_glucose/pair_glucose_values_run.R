library(dplyr)
library(optparse)

# Create the options list
option_list <- list(
  make_option("--input", type="character", default="", help="file to run")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

# Check to see that intput file exists
if(!file.exists(args[['input']])){
    print("The input file doesn't exist")
    stop()
}

#Parse input file path and create the output file path
inputPath = args[['input']]
outputPath = paste(dirname(inputPath), "/", 
                   gsub(pattern = "bin", "pair",basename(inputPath)), sep="")

# Variable for how close to measure seconds
diff_in_secs = (60 * 10) # Time in minutes on either side

# Ordered Lab Results based on patient ID and then on Collection ID
load(inputPath)
ordglucdf <- binData %>% arrange(PatientID, COLLECTION_DATE)

# Date diff algorithm to get diff in seconds
date_diff = function(time1, time2){
    firstTime = as.numeric(as.POSIXct(time1, origin="1970-01-01"))
    secondTime = as.numeric(as.POSIXct(time2, origin="1970-01-01"))
    return(abs(firstTime - secondTime))
}

#Setup the results array
results<-data.frame(pid=character(), 
                    one_code=character(), 
                        one_collect=character(), one_value=numeric(), one_accession=character(), 
                    two_code=character(), 
                        two_collect=character(), two_value=numeric(), two_accession=character())

#Set up variables for keeping track of last glucose values
last_lab_code_GLUCP = ''
last_lab_coll_GLUCP = ''
last_patient_id_GLUCP = ''
last_lab_value_GLUCP = ''
last_lab_access_GLUCP = ''

last_lab_code_GLUC = ''
last_lab_coll_GLUC = ''
last_patient_id_GLUC = ''
last_lab_value_GLUC = ''
last_lab_access_GLUC = ''

# Iterate over each row in the table
for(i in 1:nrow(ordglucdf)){
    #Get a row
    theData<-ordglucdf[i,]

    # Does this row involve use of POC glucose
    if(theData$RESULT_CODE == "GLUC-WB"){
        # Are they the same patient?
        if(theData$PatientID == last_patient_id_GLUC){
            secondsOff = date_diff(theData$COLLECTION_DATE, last_lab_coll_GLUC)
            if(secondsOff <= diff_in_secs){
                rowToAdd = data.frame(
                            pid=as.character(last_patient_id_GLUC),
                            one_code=as.character(theData$RESULT_CODE), 
                                one_collect=as.character(theData$COLLECTION_DATE), 
                                one_value=as.numeric(theData$VALUE),
                                one_accession=as.character(theData$ACCESSION_NUMBER),
                            two_code=as.character(last_lab_code_GLUC),
                                two_collect=as.character(last_lab_coll_GLUC), 
                                two_value=as.numeric(last_lab_value_GLUC),
                                two_accession=as.character(last_lab_access_GLUC)
                            )
                results = rbind(results, rowToAdd)
            }
        }

        last_lab_code_GLUCP = theData$RESULT_CODE
        last_lab_coll_GLUCP = theData$COLLECTION_DATE
        last_patient_id_GLUCP = theData$PatientID
        last_lab_value_GLUCP = theData$VALUE
        last_lab_access_GLUCP = theData$ACCESSION_NUMBER
    }
    # Does this row involve use of Central Lab Glucose
    else if(theData$RESULT_CODE == "GLUC"){
        if(theData$PatientID == last_patient_id_GLUCP){
            secondsOff = date_diff(theData$COLLECTION_DATE, last_lab_coll_GLUCP)
            if(secondsOff <= diff_in_secs){
                rowToAdd = data.frame(
                            pid=as.character(last_patient_id_GLUCP),
                            one_code=as.character(last_lab_code_GLUCP),
                                one_collect=as.character(last_lab_coll_GLUCP), 
                                one_value=as.numeric(last_lab_value_GLUCP),
                                one_accession=as.character(last_lab_access_GLUCP),
                            two_code=as.character(theData$RESULT_CODE),
                                two_collect=as.character(theData$COLLECTION_DATE),
                                two_value=as.numeric(theData$VALUE),
                                two_accession=as.character(theData$ACCESSION_NUMBER)
                            )
                results = rbind(results, rowToAdd)
            }
        }

        last_lab_code_GLUC = theData$RESULT_CODE
        last_lab_coll_GLUC = theData$COLLECTION_DATE
        last_patient_id_GLUC = theData$PatientID
        last_lab_value_GLUC = theData$VALUE
        last_lab_access_GLUC = theData$ACCESSION_NUMBER
    }
}

#Save the output to an Rdata file
save(results, file=outputPath)

