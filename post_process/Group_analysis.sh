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

for tfile in $preplist;
do
    thecmd="Rscript LIMIT_analysis.R --input $tolistpath$tfile"
    #echo $thecmd
    eval $thecmd
done

