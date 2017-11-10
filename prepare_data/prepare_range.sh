basedir="/scratch/leeschro_armis/patnatha/"
prepfile=`ls -1 ${basedir} | tr '\n' '\0' | xargs -0 -n 1 basename`

echo "=====Which directory set to prepare?====="
theCnt=0
finarr=()
for tfile in $prepfile;
do
    if [ $tfile != 'EncountersAll' ] && [ $tfile != 'RESULT_CODES.txt' ] && [ $tfile != 'limit_results' ]; then
        finarr+="${tfile}|"
        theCnt=$((theCnt+1))
        echo "${theCnt}) $tfile"
    fi
done
read -r -p '=====Choose a number=====: ' var

rawfile=''
theCnt=0
for tfile in $(echo $finarr | tr "|" "\n");
do
    if [[ $theCnt == $((var-1)) ]];
    then
        rawfile=$tfile
    fi
    theCnt=$((theCnt+1))
done
finfile=$basedir$rawfile

echo "=====AGE INCREMENT====="
echo "1) YEARS = Y"
echo "2) MONTHS = M"
echo "3) DAYS = D"
read -r -p '=====Choose a number=====: ' var

if [ "$var" = "Y" ]; then
    ageInc="Y"
elif [ "$var" = "M" ]; then
    ageInc="M"
elif [ "$var" == "D" ]; then
    ageInc="D"
else
    echo ERROR: $var
    exit
fi
echo $ageInc

echo "=====AGE RANGE====="
echo "ex. 1-100 [If using MONTHS it will go by one month at a time]"
echo "ex. 1-100 [If using YEARS it will go by one year at a time]"
read -r -p 'Choose a start number: ' var
startInc=$var
read -r -p 'Choose an end number: ' var
endInc=$var

outdir="/scratch/leeschro_armis/patnatha/prepared_data/${rawfile}_${ageInc}_${startInc}_${endInc}"
mkdir $outdir

echo "=====INCLUDE====="
includArr=( "inpatient" "outpatient" "never_inpatient" "outpatient_and_never_inpatient" "all")
theCnt=0
for incArg in ${includArr[@]}
do
    theCnt=$((theCnt+1))
    echo "$theCnt) $incArg"
done
read -r -p '=====Choose a number=====: ' var
theCnt=0
for incArg in ${includArr[@]}
do
    if [[ $theCnt == $((var-1)) ]];
    then
        incGrp=${includArr[$theCnt]}
    fi
    theCnt=$((theCnt+1))
done

lastI=''
for i in $(seq $startInc $endInc); 
do 
    if [ "$lastI" != '' ]; then
        fincmd="qsub prepare_data.pbs -F \"--input $finfile --age ${lastI}${ageInc}_${i}${ageInc} --include $incGrp --output $outdir\""
        echo $fincmd
        eval $fincmd
    fi

    lastI=$i
done


