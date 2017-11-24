tolistpath=$1
preplist=`ls -1 ${tolistpath}*.Rdata | tr '\n' '\0' | xargs -0 -n 1 basename`

echo "=====Run these files?====="
theCnt=0
finarricd=()
finarrmed=()
for tfile in $preplist;
do
    echo $tfile
    if [[ $tfile == *"icd"* ]];
    then
        finarricd+="${tfile}|"
    fi

    if [[ $tfile == *"med"* ]];
    then
        finarrmed+="${tfile}|"
    fi
done
read -r -p '=====Y|N=====: ' var
if [[ $var == "Y" || $var == "y" ]]
then   
    echo "AWESOME...HERE WE GO" 
else
    echo "ERROR: incorrect input Y|N"
    exit
fi

for tfile in $(echo $finarricd | tr "|" "\n");
do
    basefname=`basename ${tfile} | sed 's/\(.*\)_.*/\1/'`
    for tfile2 in $(echo $finarrmed | tr "|" "\n");
    do
        basefname2=`basename ${tfile2} | sed 's/\(.*\)_.*/\1/'`
        if [ $tfile != $tfile2 ] && [ $basefname == $basefname2 ];
        then
            thecmd="Rscript intersect_results.R --icd $tolistpath$tfile --med $tolistpath$tfile2"
            echo $thecmd
            eval $thecmd
        fi
    done
done

eval "mkdir ${tolistpath}med"
eval "mv ${tolistpath}*med.Rdata" "${tolistpath}med/." 

eval "mkdir ${tolistpath}icd"
eval "mv ${tolistpath}*icd.Rdata" "${tolistpath}icd/."

