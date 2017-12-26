tolistpath=$1
preplist=`ls -1 ${tolistpath} | tr '\n' '\0' | xargs -0 -n 1 basename`

echo "=====Run these files?====="
theCnt=0
for tfile in $preplist;
do
    echo $tfile
done
read -r -p '=====Y|N=====: ' var
if [[ $var == "Y" || $var == "y" ]]
then   
    echo "AWESOME...HERE WE GO" 
else
    echo "ERROR: incorrect input Y|N"
    exit
fi

echo "=====Which method to run?====="
echo "1) icd"
echo "2) med"
echo "3) lab"
echo "4) all"
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

outpath=${tolistpath/"prepared_data"/"limit_results"}
mkdir -p $outpath
for tfile in $preplist;
do
    finfile="$tolistpath$tfile"
    if [[ $thecode == "both" ]]
    then
        thecmd="qsub Nate_LIMIT.pbs -F \"--input $finfile --code icd --output $outpath --singular-value $singularValue\""
        eval $thecmd

        thecmd="qsub Nate_LIMIT.pbs -F \"--input $finfile --code med --output $outpath --singular-value $singularValue\""
        eval $thecmd

        thecmd="qsub Nate_LIMIT.pbs -F \"--input $finfile --code lab --output $outpath --singular-value $singularValue\""
        eval $thecmd
    else
        thecmd="qsub Nate_LIMIT.pbs -F \"--input $finfile --code $thecode --output $outpath --singular-value $singularValue\""
        eval $thecmd
    fi
done

