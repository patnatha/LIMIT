#!/bin/bash
module load R

dirPaths=`Rscript glucose_paths.R | sed 's/[^"]*"\([^"]*\)".*/\1/'`
foundPath=false
pathNameConst="paired_pieces_output"
for tPath in $dirPaths; do
    varName=$(echo ${tPath} | cut -d "|" -f 1)
    if [ "$pathNameConst" == "$varName" ]
    then
        pathname=$(echo ${tPath} | cut -d "|" -f 2)
        foundPath=true
    fi
done

if ! $foundPath;
then
    echo "Did not find a path to run"
    exit
fi

files=`ls $pathname*.bin`
for file in $files;
do
    theCmd="qsub pair_glucose_values_run.pbs -F \"$file\""
    echo $theCmd
    eval $theCmd
done

exit

