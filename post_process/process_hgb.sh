tolistpath='/scratch/leeschro_armis/patnatha/limit_results/hgb_5_years/*/'

preplist=`ls -d1 ${tolistpath}`
for tfile in $preplist;
do
    cmd="./intersect_results.sh $tfile"
    eval $cmd
done

for tfile in $preplist;
do
    cmd="./Group_analysis.sh $tfile"
    eval $cmd
done

