library(dplyr)
library(optparse)
library(stringr)
source('../import_files.R')
source('analyze_helper.R')

outniCuts = 1600
outniCuts = seq(0, 2000, by=100)
outCuts = 1600 
outCuts = seq(0, 2000, by=100)
allCuts = 0
allCuts = seq(0, 3000, by=100)

whichCnt = "PRE" #"HORN"

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata"),
  make_option("--type", type="character", default="combined", help="file type to load") 
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

#Load input data
input_dir = args[['input']]
print(paste("INPUT: ", input_dir, sep=""))
if(is.na(input_dir)){
    stop()
}

resultType= args[['type']]
if(resultType != "combined" && resultType != "joined"){
    stop()
}

#Create output file
searchName = paste("analysis_results_", resultType,".csv", sep="")
output_file = paste(str_replace(input_dir," ",""), searchName, sep="/")

cntTableInIt <- function(theTable){
    errorCI = 0
    denomCnt = 0
    inCICnt = 0
    for(x in 1:nrow(theTable)){
        if(theTable[x,]$Pre.LIMIT.Count < allCut){
            next
        }

        if(!is.na(theTable[x,]$Low.in.CI) && theTable[x,]$Low.in.CI != "NA"){
            inCICnt = inCICnt + as.numeric(theTable[x,]$Low.in.CI)
            denomCnt = denomCnt + 1
        } else {
            errorCI = errorCI + 1
        }
        if(!is.na(theTable[x,]$High.in.CI) && theTable[x,]$High.in.CI != "NA"){
            inCICnt = inCICnt + as.numeric(theTable[x,]$High.in.CI)
            denomCnt = denomCnt + 1
        } else {
            errorCI = errorCI + 1
        }
    }

    return(paste(inCICnt, ",", denomCnt, ",", errorCI, sep=""))
}

files=list.files(input_dir, pattern = searchName, full.names = TRUE,  recursive=T)
for(file in files){
    if(length(grep("/all/random", file)) != 0){
        allTable = tbl_df(read.csv(file=file, header=TRUE, sep=","))
    } else if(length(grep("/outpatient/random", file)) != 0){
        outTable = tbl_df(read.csv(file=file, header=TRUE, sep=","))
    } else if(length(grep("/outpatient_and_never_inpatient/random", file)) != 0){
        outniTable = tbl_df(read.csv(file=file, header=TRUE, sep=","))
    }  
}

for(allCut in allCuts){
    #print(paste("ALL,", cntTableInIt(allTable), ",N/A,N/A,", allCut, sep=""))
    #print(paste("OUT,", cntTableInIt(outTable), ",N/A,N/A,", allCut, sep=""))
    #print(paste("OUT_NI,", cntTableInIt(outniTable), ",N/A,N/A,", allCut, sep=""))

    #Get all the outpatient cuts with values greater than final cut
    for(outCut in outCuts){
    if(outCut > allCut) next

    #Get all the out_ni cuts with values greater than final cut
    for(outniCut in outniCuts){
    if(outniCut > allCut) next

    if(whichCnt == "PRE"){
        tempAllTable = allTable %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Pre.LIMIT.Count)
        tempAllTable = tempAllTable %>% rename(AllPreLimitCnt = Pre.LIMIT.Count)
    } else if(whichCnt == "HORN"){
        tempAllTable = allTable %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Horn.Count)
        tempAllTable = tempAllTable %>% rename(AllPreLimitCnt = Horn.Count)
    }

    if(whichCnt == "PRE"){
        tempOutTable = outTable  %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Pre.LIMIT.Count)
        tempOutTable = tempOutTable %>% rename(OutPreLimitCnt = Pre.LIMIT.Count)
    } else if(whichCnt == "HORN") {
        tempOutTable = outTable  %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Horn.Count)
        tempOutTable = tempOutTable %>% rename(OutPreLimitCnt = Horn.Count)
    }

    if(whichCnt == "PRE"){
        tempOutniTable = outniTable %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Pre.LIMIT.Count)
        tempOutniTable = tempOutniTable %>% rename(OutniPreLimitCnt = Pre.LIMIT.Count)
    } else if(whichCnt == "HORN"){
        tempOutniTable = outniTable %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Horn.Count)
        tempOutniTable = tempOutniTable %>%  rename(OutniPreLimitCnt = Horn.Count)
    }

    #Create the table of all the goodies
    joinedTable = inner_join(tempOutniTable, inner_join(tempAllTable, tempOutTable))

    #Get all the valid outpatient_and_never_inpatient values
    outNiValid = joinedTable %>% filter(OutniPreLimitCnt >= outniCut) %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection)

    #Get all the valid outpatient values
    outValid = joinedTable %>% filter(OutPreLimitCnt >= outCut & OutniPreLimitCnt <= outniCut) %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection)

    #Combine the out_ni and out tables
    out_outni_table = union(outNiValid, outValid)

    #Get the rest of the values as all
    allValid = anti_join(joinedTable, out_outni_table) %>% filter(AllPreLimitCnt >= allCut) %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection)

    #Build compliation table
    finalResult = union(inner_join(outValid, outTable), inner_join(outNiValid, outniTable))
    finalResult = union(finalResult, inner_join(allValid, allTable))

    getLimitRatio = as.numeric(finalResult$Low.in.CI, na.rm=TRUE)
    totalSum = 0
    denominator = 0
    for(x in getLimitRatio){
        if(!is.na(x) && x != "NA"){
            totalSum = totalSum + x
            denominator = denominator + 1
        }
    }

    getLimitRatio = as.numeric(finalResult$High.in.CI, na.rm=TRUE)
    for(x in getLimitRatio){
        if(!is.na(x) && x != "NA"){
            totalSum = totalSum + x
            denominator = denominator + 1
        }
    }

    getLimitRatio = as.numeric(finalResult$LIMIT.Ratio, na.rm=TRUE)
    LIMITRatio = 0
    for(x in getLimitRatio){
        if(!is.na(x) && x != "NA"){
            LIMITRatio = LIMITRatio + x
        }
    }

    lowPercentOff = (finalResult %>% filter(Low.in.CI == 0) %>% mutate(lowOffL = abs(RI.Low - GS.Conf.Low.Low)) %>% mutate(lowOffH = abs(RI.Low - GS.Conf.Low.High)) %>% mutate(lowOff = pmin(lowOffL, lowOffH)) %>% select(-c(lowOffL, lowOffH)) %>% mutate(lowOff = lowOff / (GS.Conf.Low.High - GS.Conf.Low.Low)))

    highPercentOff = (finalResult %>% filter(High.in.CI == 0) %>% mutate(highOffL = abs(RI.High - GS.Conf.High.Low)) %>% mutate(highOffH = abs(RI.High - GS.Conf.High.High)) %>% mutate(highOff = pmin(highOffL, highOffH)) %>% select(-c(highOffL, highOffH)) %>% mutate(highOff = highOff / (GS.Conf.High.High - GS.Conf.High.Low)))
   
    
    lowInPerc = nrow(lowPercentOff %>% filter(lowOff <= 1.0)) 
    highInPrec = nrow(highPercentOff %>% filter(highOff <= 1.0))

    print(paste(totalSum, ",", lowInPerc, ",", highInPrec, ",", (totalSum + lowInPerc + highInPrec), ",", denominator, ",", ((totalSum + lowInPerc + highInPrec)/denominator), ",", LIMITRatio, ",", outniCut, ",", outCut, ",", allCut, sep=""))
    }
    }
}

print(paste("SAVING: ", output_file, sep=""))
write.csv(finalResult %>% arrange(File), file=output_file, quote=F, row.names=F)

