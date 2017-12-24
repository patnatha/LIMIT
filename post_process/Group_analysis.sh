tolistpath=$1
preplist=`ls -1 ${tolistpath}*.Rdata | tr '\n' '\0' | xargs -0 -n 1 basename`

echo "=====Run these files?====="
theCnt=0
for tfile in $preplist;
do
    echo $tfile
done

outputFile="${tolistpath}analysis_results.csv"
rm ${outputFile}
echo "File, Pre-LIMIT Count, Post-LIMIT Count, Low Low, Low High, High Low, High High, Mean" > ${outputFile}

for tfile in $preplist;
do
    thecmd="Rscript analyze_results.R --input $tolistpath$tfile"
    #echo $thecmd
    eval $thecmd
done

