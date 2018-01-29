tolistpath=$1
preplist=`ls -1 ${tolistpath}*.Rdata | sort | tr '\n' '\0' | xargs -0 -n 1 basename`

optionalConfInt=$2
if [ -z $optionalConfInt ];
then
    optionalConfInt="2.5"
fi

optionalNewFile=$3
if [ -z $optionalConfInt ];
then
    optionalNewFile="newfile"
fi

echo "=====Run these files?====="
theCnt=0
for tfile in $preplist;
do
    echo $tfile
done

if [ $optionalNewFile == 'newfile' ];
then
    outputFile="${tolistpath}analysis_results.csv"
    rm ${outputFile}
    echo "File, Result Code, Start Date, End Date, Pre-LIMIT Count, Pre-LIMIT 2.5%, Pre-LIMIT 5%, Pre-LIMIT 95%, Pre-LIMIT 97.5%, Post-Limit ICD, Post-Limit Med, Post-Limit Lab, Post-Combined Count, Post-Horn Count, Post-LIMIT 2.5%, Post-LIMIT 5%, Post-LIMIT 95%, Post-LIMIT 97.5%, Boot Low Low, Boot Low High, Boot High Low, Boot High High, Boot Ref Interval" > ${outputFile}
fi

for tfile in $preplist;
do
    thecmd="Rscript analyze_results.R --input $tolistpath$tfile --ref-interval $optionalConfInt"
    eval $thecmd
done

