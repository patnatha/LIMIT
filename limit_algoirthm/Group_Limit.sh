tolistpath=$1
preplist==`ls -1 ${tolistpath} | tr '\n' '\0' | xargs -0 -n 1 basename`

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
read -r -p '=====Choose a number=====: ' var
thecode=''
if [[ $var == 1 ]]
then
    thecode="icd"
elif [[ $var == 2 ]]
then
    thecode="med"
else
    echo "ERROR: incorrect code 1|2" 
    exit
fi

outpath=${tolistpath/"prepared_data"/"limit_results"}
mkdir $outpath
for tfile in $preplist;
do
    finfile="$tolistpath$tfile"
    thecmd="qsub Nate_LIMIT.pbs -F \"--input $finfile --code $thecode --output $outpath\""
    #echo $thecmd
    eval $thecmd
done

