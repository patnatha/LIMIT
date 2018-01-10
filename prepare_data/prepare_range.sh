basedir="/scratch/leeschro_armis/patnatha/"
prepfile=`ls -1 ${basedir} | tr '\n' '\0' | xargs -0 -n 1 basename`

echo "=====Which directory set to prepare?====="
theCnt=0
finarr=()
for tfile in $prepfile;
do
    if [ $tfile != 'EncountersAll' ] && [ $tfile != 'RESULT_CODES.txt' ] && [ $tfile != 'limit_results' ] && [ $tfile != 'LabResults' ]; then
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

if [ "$var" = "1" ]; then
    ageInc="Y"
elif [ "$var" = "2" ]; then
    ageInc="M"
elif [ "$var" = "3" ]; then
    ageInc="D"
else
    echo ERROR: $var
    exit
fi

echo "=====AGE RANGE====="
echo "ex. 1-100 [If using MONTHS it will go by one month at a time]"
echo "ex. 1-100 [If using YEARS it will go by one year at a time]"
read -r -p 'Choose a start number: ' var
startInc=$var
read -r -p 'Choose an end number: ' var
endInc=$var
read -r -p 'Choose an increment: ' var
theInc=$var

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

echo "=====SEX====="
echo "1) Both"
echo "2) Male"
echo "3) Female"
read -r -p '=====Choose a number=====: ' var
thesex=""
if [ $var == "1" ]
then
    thesex="both"
elif [ $var == "2" ]
then
    thesex="male"
elif [ $var == "3" ]
then
    thesex="female"
else
    echo "ERROR: 1|2|3 only"
    exit
fi

echo "=====RACE====="
echo "1) All"
echo "2) White"
echo "3) Black"
read -r -p '=====Choose a number=====: ' var
therace=""
if [ $var == "1" ]
then
    therace="all"
elif [ $var == "2" ]
then
    therace="white"
elif [ $var == "3" ]
then
    therace="black"
else
    echo "ERROR: 1|2|3 only"
    exit
fi

outdir="/scratch/leeschro_armis/patnatha/prepared_data/${rawfile}_${theInc}${ageInc}_${startInc}_${endInc}_${thesex}_${therace}"
mkdir -p $outdir

lastI=''
for i in $(seq $startInc $theInc $endInc); 
do 
    if [ "$lastI" != '' ]; then
        fincmd="qsub prepare_data.pbs -F \"--input $finfile --include $incGrp --output $outdir --sex $thesex --race $therace --age ${lastI}${ageInc}_${i}${ageInc}\""
        echo $fincmd
        eval $fincmd
    fi

    lastI=$i
done


