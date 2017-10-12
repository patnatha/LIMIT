basedir="/scratch/leeschro_armis/patnatha/prepared_data/"
prepfile=`ls -1 ${basedir} | tr '\n' '\0' | xargs -0 -n 1 basename`

echo "=====Which prepared file?====="
theCnt=0
for tfile in $prepfile;
do
   theCnt=$((theCnt+1))
   echo "${theCnt}) $tfile"
done
read -r -p '=====Choose a number=====: ' var

preppedfile=''
theCnt=0
for tfile in $prepfile;
do
    if [[ $theCnt == $((var-1)) ]];
    then
        preppedfile=$tfile
    fi
    theCnt=$((theCnt+1))
done

echo "=====Which method to run?====="
echo "1) icd"
echo "2) med"
read -r -p '=====Choose a number=====: ' var
thecode=''
if [[ $var == 1 ]]
then
    thecode="icd"
fi
if [[ $var == 2 ]]
then
    thecode="med"
fi

thecmd="qsub Nate_LIMIT.pbs -F \"--input $basedir$preppedfile --code $thecode\""
echo Run it?: $thecmd
read -r -p '=====Y|N=====: ' var
if [[ $var == 'Y' ]]
then
    eval $thecmd
fi

