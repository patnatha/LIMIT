source('glucose_paths.R')

finalOutput = data.frame()

for(file in list.files(path=paired_pieces_output)){
    if(grepl("pair", file)){
        inputFile = paste(paired_pieces_output, file,sep="")
        load(inputFile)

        finalOutput = rbind(finalOutput, results)
    }
}

results = finalOutput
save(results, file=paired_glucoses_path)


