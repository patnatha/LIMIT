source ../basedir.sh

tolistpath="${limitdir}${whichdir}alk_phos_5_years/"
cmd="./intersect_results.sh $tolistpath"
eval $cmd
cmd="./Group_analysis.sh $tolistpath 2.5 newfile"
eval $cmd


