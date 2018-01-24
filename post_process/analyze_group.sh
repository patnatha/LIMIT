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
    echo "File, Pre-LIMIT Count, Post-LIMIT Count, Low Low, Low High, High Low, High High, Mean, Median, Reference Interval, Reference Low, Reference High" > ${outputFile}
fi

for tfile in $preplist;
do
    thecmd="Rscript analyze_results.R --input $tolistpath$tfile --ref-interval $optionalConfInt"
    eval $thecmd
done

