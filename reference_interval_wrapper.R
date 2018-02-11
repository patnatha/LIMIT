library("RSQLite")
source("../wrapper_helper.R")

connect_sqlite_ref <- function(){
    con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/ReferenceIntervals/ReferenceIntervals.db")
    return(con)
}

query_reference_interval <- function(result_code, sex, race, low_age, high_age, tsource){
    out <- tryCatch(
        if(length(result_code) > 0){
            #Build the query and execute
            sql = paste('SELECT limit_type, limit_value FROM ReferenceIntervals WHERE result_code = "', result_code, '" AND sex = "', sex, '" AND low_age <= ', low_age, ' AND high_age >= ', high_age, ' AND race = "', race,'" AND source = "', tsource, '"', sep="")
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
            }
            
            return(c(lowerLimit, upperLimit))
        } else {
            return(c(NA, NA))
        }
    ,error=function(cond) {
            message(cond)
            return(c(NA, NA))
        }
    )
}

