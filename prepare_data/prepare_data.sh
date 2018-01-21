read -r -p '=====Type a Result Code=====: ' var
inval=$var

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

echo "=====AGE====="
echo "1) Adult"
echo "2) Free form "
read -r -p '=====Choose a number=====: ' var
theage=null
if [ $var == "1" ]
then
    theage="adult"
elif [ $var == "2" ]
then
    read -r -p 'Enter Range: ' theage 
else
    echo "ERROR: 1 only"
    exit
fi 

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

outdir="/scratch/leeschro_armis/patnatha/prepared_data/${rawfile}_${therace}_${thesex}_${theage}"
mkdir $outdir

fincmd="qsub prepare_data.pbs -F \"--input $inval --sex $thesex --race $therace --include $incGrp --age $theage --output ${outdir}\""
eval $fincmd

