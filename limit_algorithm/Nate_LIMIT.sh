basedir="/scratch/leeschro_armis/patnatha/prepared_data/"
prepfile=`ls -1 ${basedir}$@ | tr '\n' '\0' | xargs -0 -n 1 basename`

echo "=====Which prepared file?====="
theCnt=0
for tfile in $prepfile;
do
    if [ $tfile != 'hgb_4_years_archive' ]; then
        finarr+="${tfile}|"
        theCnt=$((theCnt+1))
        echo "${theCnt}) $tfile"
    fi
done
echo "$((theCnt+1))) All"
read -r -p '=====Choose a number=====: ' var

preppedfile=''
if [[ $var == $((theCnt+1)) ]]
then
    for tfile in $prepfile;
    do
        preppedfile+="$tfile|"
    done
else
    preppedfile=''
    theCnt=0
    for tfile in $(echo $finarr | tr "|" "\n");
    do
        if [[ $theCnt == $((var-1)) ]];
        then
            preppedfile="$tfile|"
        fi
        theCnt=$((theCnt+1))
    done
fi

echo "=====Which method to run?====="
echo "1) icd"
echo "2) med"
echo "3) lab"
echo "4) both"
read -r -p '=====Choose a number=====: ' var
thecode=''
if [[ $var == 1 ]]
then
    thecode="icd"
elif [[ $var == 2 ]]
then
    thecode="med"
elif [[ $var == 3 ]]
then
    thecode="lab"
elif [[ $var == 4 ]]
then
    thecode="both"
else
    echo "ERROR: 1|2|3|4"
    exit
fi

echo "=====Which PID grouping to run?====="
echo "1) most_recent"
echo "2) random"
echo "3) all"
read -r -p '=====Choose a number=====: ' var
singularValue=''
if [[ $var == 1 ]]
then
    singularValue="most_recent"
elif [[ $var == 2 ]]
then
    singularValue="random"
elif [[ $var == 3 ]]
then
    singularValue="all"
else
    echo "ERROR: 1|2|3"
    exit
fi

for prepfile in $(echo $preppedfile| tr "|" "\n") ;
do
    echo $prepfile
    if [[ $thecode == "both" ]]
    then
        thecmd="qsub Nate_LIMIT.pbs -F \"--input $basedir$prepfile --code med --singular-value $singularValue\""
        echo $thecmd
        eval $thecmd
        thecmd="qsub Nate_LIMIT.pbs -F \"--input $basedir$prepfile --code icd --singular-value $singularValue\""
        echo $thecmd
        eval $thecmd
        thecmd="qsub Nate_LIMIT.pbs -F \"--input $basedir$prepfile --code lab --singular-value $singularValue\""
        echo $thecmd
        eval $thecmd
    else
        thecmd="qsub Nate_LIMIT.pbs -F \"--input $basedir$prepfile --code $thecode --singular-value $singularValue\""
        echo $thecmd
        eval $thecmd
    fi
done

