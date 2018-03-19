library(dplyr)
library(optparse)
library(stringr)
source('../import_files.R')
source('analyze_helper.R')

outniCuts = 10
outniCuts = seq(0, 200, by=25)
outCuts = 20
outCuts = seq(0, 200, by=25)
allCuts = 0
allCuts = seq(0, 200, by=25)

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
    print(paste("ALL,", cntTableInIt(allTable), ",N/A,N/A,", allCut, sep=""))
    print(paste("OUT,", cntTableInIt(outTable), ",N/A,N/A,", allCut, sep=""))
    print(paste("OUT_NI,", cntTableInIt(outniTable), ",N/A,N/A,", allCut, sep=""))

    for(outniCut in outniCuts){
        for(outCut in outCuts){
            if(outniCut == 0){ outniCut = 1 }
            if(outCut == 0){ outCut = 1 }

            if(whichCnt == "PRE"){
                tempAllTable = allTable %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Pre.LIMIT.Count)
                tempAllTable = tempAllTable %>% rename(AllPreLimitCnt = Pre.LIMIT.Count)
            } else if(whichCnt == "HORN"){
                tempAllTable = allTable %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Horn.Count)
                tempAllTable = tempAllTable %>% rename(AllPreLimitCnt = Horn.Count)
            }

            if(whichCnt == "PRE"){
                tempOutTable = outTable  %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Pre.LIMIT.Count)
                tempOutTable = tempOutTable %>% filter(Pre.LIMIT.Count >= allCut) %>% 
                                rename(OutPreLimitCnt = Pre.LIMIT.Count)
            } else if(whichCnt == "HORN") {
                tempOutTable = outTable  %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Horn.Count)
                tempOutTable = tempOutTable %>% filter(Horn.Count >= allCut) %>% 
                                rename(OutPreLimitCnt = Horn.Count)
            }

            if(whichCnt == "PRE"){
                tempOutniTable = outniTable %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Pre.LIMIT.Count)
                tempOutniTable = tempOutniTable %>% filter(Pre.LIMIT.Count >= allCut) %>% 
                                    rename(OutniPreLimitCnt = Pre.LIMIT.Count)
            } else if(whichCnt == "HORN"){
                tempOutniTable = outniTable %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Horn.Count)
                tempOutniTable = tempOutniTable %>% filter(Horn.Count >= allCut) %>%
                                    rename(OutniPreLimitCnt = Horn.Count)
            }

            joinedTable = inner_join(tempOutniTable, inner_join(tempAllTable, tempOutTable))

            #Get all the valid outpatient_and_never_inpatient values
            outNiValid = joinedTable %>% filter(OutniPreLimitCnt >= outniCut) %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection)

            #Get all the valid outpatient values
            outValid = joinedTable %>% filter(OutPreLimitCnt >= outCut & OutPreLimitCnt < outniCut) %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection)

            #Combine the out_ni and out tables
            out_outni_table = union(outNiValid, outValid)

            #Get the rest of the values as all
            allValid = anti_join(joinedTable, out_outni_table) %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection)

            #Build compliation table
            finalResult = union(inner_join(outValid, outTable), inner_join(outNiValid, outniTable))
            finalResult = union(finalResult, inner_join(allValid, allTable))

            #Sum up the lower limit in CI
            getLimitRatio = as.numeric(finalResult$Low.in.CI, na.rm=TRUE)
            totalSum = 0
            denominator = 0
            for(x in getLimitRatio){
                if(!is.na(x) && x != "NA"){
                    totalSum = totalSum + x
                    denominator = denominator + 1
                }
            }

            #Sum up the upper limit in CI
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
            print(paste(totalSum, ",", denominator, ",", (totalSum/denominator), ",", LIMITRatio, ",", outniCut, ",", outCut, ",", allCut, sep=""))
        }
    }
    }

print(paste("SAVING: ", output_file, sep=""))
write.csv(finalResult %>% arrange(File), file=output_file, quote=F, row.names=F)

