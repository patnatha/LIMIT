# Variable for how close to measure seconds
diff_in_secs = (60 * 10)

# Import the data
source("import_csv.R")
glucoseVals = import_csv('/scratch/leeschro_armis/patnatha/glucose_3_month/')

#Pick out the columns that we need for analyzing
selected_glucoses = select(glucoseVals$lab_values, one_of(c('PatientID', 'ACCESSION_NUMBER', 'COLLECTION_DATE', 'RESULT_CODE', 'VALUE')))

# Ordered Lab Results based on patient ID and then on Collection ID
ordered_glucoses = selected_glucoses %>% arrange(PatientID, COLLECTION_DATE)

#Convert dplyr table into data.frame
ordglucdf<-ordered_glucoses %>% as.data.frame()

# Date diff algorithm to get diff in seconds
date_diff = function(time1, time2){
    firstTime = as.numeric(as.POSIXct(time1, origin="1970-01-01"))
    secondTime = as.numeric(as.POSIXct(time2, origin="1970-01-01"))
    return(abs(firstTime - secondTime))
}

#Setup the results array
results<-data.frame(pid=character(), 
                    one_code=character(), 
                        one_collect=character(), one_value=character(), one_accesssion=character(), 
                    two_code=character(), 
                        two_collect=character(), two_value=character(), two_accesssion=character())

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
                                one_value=as.character(theData$VALUE),
                                one_accesssion=as.character(theData$ACCESSION_NUMBER),
                            two_code=as.character(last_lab_code_GLUC),
                                two_collect=as.character(last_lab_coll_GLUC), 
                                two_value=as.character(last_lab_value_GLUC),
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
                            one_code=as.character(theData$RESULT_CODE),
                                one_collect=as.character(theData$COLLECTION_DATE), 
                                one_value=as.character(theData$VALUE),
                                one_accesssion=as.character(theData$ACCESSION_NUMBER),
                            two_code=as.character(last_lab_code_GLUCP),
                                two_collect=as.character(last_lab_coll_GLUCP), 
                                two_value=as.character(last_lab_value_GLUCP),
                                two_accession=as.character(last_lab_access_GLUCP)
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

save(results, file="paired_glucoses.Rdata")

