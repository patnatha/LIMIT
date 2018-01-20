source ../basedir.sh

tolistpath="${limitdir}other_electrolytes/"
cmd="./intersect_results.sh $tolistpath"
eval $cmd
cmd="./Group_analysis.sh $tolistpath 2.5 newfile"
eval $cmd


