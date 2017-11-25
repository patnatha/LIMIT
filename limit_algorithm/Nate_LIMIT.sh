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
echo "3) both"
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
    thecode="both"
else
    echo "ERROR: 1|2"
    exit
fi

for prepfile in $(echo $preppedfile| tr "|" "\n") ;
do
    echo $prepfile
    if [[ $thecode == "both" ]]
    then
        thecmd="qsub Nate_LIMIT.pbs -F \"--input $basedir$preppedfile --code med\""
        echo $thecmd
        eval $thecmd
        thecmd="qsub Nate_LIMIT.pbs -F \"--input $basedir$preppedfile --code icd\""
        echo $thecmd
        eval $thecmd
    else
        thecmd="qsub Nate_LIMIT.pbs -F \"--input $basedir$prepfile --code $thecode\""
        echo $thecmd
        eval $thecmd
    fi
done

