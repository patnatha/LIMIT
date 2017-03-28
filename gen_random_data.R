
normal_dist_lab_values = function(patientDemo, labObs, mean, sd)
{
  #Create lab values table
  l_vals<-rnorm(labObs, mean=mean, sd=sd)
  
  #Add a pid to these lab values
  rand_pid=sample(1:nrow(patientDemo), replace = TRUE, labObs)
  pid<-patientDemo$pid[rand_pid]
  
  #Create the dataframe
  labValues<-data.frame(pid, l_vals)
  labValues$l_date = rep(as.Date(1900/01/01, origin = '1970-01-01'),length(labValues$l_vals))
  labValues$timeOffset = rep(0,length(labValues$l_vals))
  
  #Create a timestamp for each lab val
  for(i in 1:nrow(labValues))
  { 
    pbday<-patientDemo[labValues[i,]$pid,]$bday
    labValues[i,]$l_date<-sample(seq.Date(pbday, as.Date('2017-01-01'), by="day"), 1)
    labValues[i,]$timeOffset<-as.numeric(labValues[i,]$l_date - pbday)
  }
  return (labValues)
}

create_icd_values = function(patientDemo, numICDperPt)
{
  #Count number of uniqPatients
  uniqPat = nrow(patientDemo)
  
  #Create an ICD tables
  icd<-sample(1:round(uniqPat/5, digits = 0), round(uniqPat * numICDperPt, digits = 0), replace=TRUE)
  
  #Add a pid to these lab values
  rand_pid=sample(1:uniqPat, replace = TRUE, length(icd))
  pid<-patientDemo$pid[rand_pid]
  
  #Create the data frame
  icdValues<-data.frame(pid, icd)
  icdValues$icd_date = rep(as.Date(1900/01/01, origin = '1970-01-01'),length(icdValues$icd))
  icdValues$timeOffset = rep(0,length(icdValues$icd))
  
  #Create a timestamp for each ICD code
  for(i in 1:nrow(icdValues))
  {
    pbday<-patientDemo[icdValues[i,]$pid,]$bday
    icdValues[i,]$icd_date=sample(seq.Date(pbday, as.Date('2017-01-01'), by="day"), 1)
    icdValues[i,]$timeOffset<-as.numeric(icdValues[i,]$icd_date - pbday)
  }
  
  return(icdValues)
}

#Create list of unique patient ids
uniqPat<-1000
bdays<-sample(seq.Date(as.Date('1925/01/01'), as.Date('2014/01/01'), by="day"), replace = TRUE, uniqPat)
pid<-1:uniqPat
patientDemo<-data.frame(pid, bdays)

#Create a list of associated ICD codes
icdValues = create_icd_values(patientDemo, 2.5)

#Create some lab observations
normal_lab_vals = normal_dist_lab_values(patientDemo, 5000, 12, 2)

#Over saturate the bad lab values with small sample of icds values
bad_lab_vals = normal_dist_lab_values(patientDemo, 500, 18, 2)

#Pick 10 random icd values to over represent by this data
ten_rand = sample(icdValues$icd, 10)
for(i in 1:500){
  pid = bad_lab_vals[i,]$pid
  icd_date = bad_lab_vals[i,]$l_date
  timeOffset = 0
  icd = sample(ten_rand, 1)
  icdValues = rbind(icdValues, data.frame(pid, icd, icd_date, timeOffset))
}

labValues = rbind((normal_lab_vals), (bad_lab_vals))

