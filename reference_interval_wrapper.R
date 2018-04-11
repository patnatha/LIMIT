library("RSQLite")
source("../wrapper_helper.R")

connect_sqlite_ref <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/ReferenceIntervals/ReferenceIntervals.db")
    return(con)
}

query_confidence_interval <- function(result_code, sex, race, low_age, high_age, tsources){
    out <- tryCatch(
    {
        if(length(result_code) > 0){
            for(tsource in tsources){
                #Build the query and execute
                sql = paste('SELECT limit_type, limit_value FROM ReferenceIntervals WHERE (limit_type IN ("conf_low_low", "conf_low_high", "conf_high_low", "conf_high_high")) AND result_code = "', result_code, '" AND sex = "', sex, '" AND low_age <= ', low_age, ' AND high_age >= ', high_age, ' AND race = "', race,'" AND source = "', tsource, '"', sep="")
                con = connect_sqlite_ref()
                myQuery = dbGetQuery(con, sql)
                dbDisconnect(con)

                refConfLowLow=NA
                refConfLowHigh=NA
                refConfHighLow=NA
                refConfHighHigh=NA
                if(nrow(myQuery) > 0){
                    for(i in 1:nrow(myQuery)){
                        if(myQuery[i,]$limit_type == 'conf_low_low'){
                            refConfLowLow = myQuery[i,]$limit_value
                        } else if(myQuery[i,]$limit_type == 'conf_low_high'){
                            refConfLowHigh = myQuery[i,]$limit_value
                        } else if(myQuery[i,]$limit_type == 'conf_high_low'){
                            refConfHighLow = myQuery[i,]$limit_value
                        } else if(myQuery[i,]$limit_type == 'conf_high_high'){
                            refConfHighHigh = myQuery[i,]$limit_value
                        }
                    }

                    if((!is.na(refConfLowHigh) && !is.na(refConfLowLow)) ||
                       (!is.na(refConfHighLow) && !is.na(refConfHighHigh))){
                        return(c(refConfLowLow, refConfLowHigh, refConfHighLow, refConfHighHigh, tsource))
                    }
                }
            }
        }
        return(c(NA, NA, NA, NA, NA))
    }
    ,error=function(cond) {
            message(cond)
            return(c(NA, NA, NA, NA, NA))
        }
    )
}

query_reference_interval <- function(result_code, sex, race, low_age, high_age, tsources){
    out <- tryCatch(
    {
        if(length(result_code) > 0){
            for(tsource in tsources){
                #Build the query and execute
                sql = paste('SELECT limit_type, limit_value FROM ReferenceIntervals WHERE (limit_type = "upper" OR limit_type = "lower") AND result_code = "', result_code, '" AND sex = "', sex, '" AND low_age <= ', low_age, ' AND high_age >= ', high_age, ' AND race = "', race,'" AND source = "', tsource, '"', sep="")
                con = connect_sqlite_ref()
                myQuery = dbGetQuery(con, sql)
                dbDisconnect(con)
                
                lowerLimit=NA
                upperLimit=NA
                if(nrow(myQuery) > 0){
                    for(i in 1:nrow(myQuery)){
                        if(myQuery[i,]$limit_type == 'lower'){
                            lowerLimit = myQuery[i,]$limit_value
                        } else if(myQuery[i,]$limit_type == 'upper'){
                            upperLimit = myQuery[i,]$limit_value
                        }
                    }

                    if(!is.na(lowerLimit) || !is.na(upperLimit)){
                        return(c(lowerLimit, upperLimit, tsource))
                    }
                }
            } 
        }
        return(c(NA, NA, NA))
    }
    ,error=function(cond) {
            message(cond)
            return(c(NA, NA, NA))
        }
    )
}

