library(stringr)

paired_pieces_path <- function(outpath){
    return(str_replace(paste(outpath, "paired_pieces/", sep="/"),"//","/"))
}

paired_path <- function(outpath){
    return(str_replace(paste(outpath, 'paired_values.Rdata', sep="/"),"//","/"))
}

