tolistpath=$1
eval "mkdir -p ${tolistpath}graphs/"
preplist=`ls -1 ${tolistpath}*combined.Rdata | sort | tr '\n' '\0' | xargs -0 -n 1 basename`

echo "=====Run these files?====="
theCnt=0
for tfile in $preplist;
do
    echo $tfile
done

outputFile="${tolistpath}analysis_results.csv"
rm ${outputFile}
echo "File, Result Code, Group, Sex, Race, Start Days, End Days, Pre-LIMIT Count,  Post-Limit ICD Count, Post-Limit Med Count, Post-Limit Lab Count, ICD-Lab-Med Joined Count, Post-Combined Count, Post-Horn Count, Pre-LIMIT 2.5%, Pre-LIMIT 5%, Pre-LIMIT 95%, Pre-LIMIT 97.5%, Post-LIMIT 2.5%, Post-LIMIT 5%, Post-LIMIT 95%, Post-LIMIT 97.5%, Boot Low Low, Boot Low High, Boot High Low, Boot High High, Boot Ref Interval" > ${outputFile}

for tfile in $preplist;
do
    thecmd="Rscript analyze_results.R --input $tolistpath$tfile"
    eval $thecmd
done

