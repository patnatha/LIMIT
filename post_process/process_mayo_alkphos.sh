source ../basedir.sh

tolistpath="${limitdir}mayo_alk_phos/outpatient/"
cmd="./intersect_results_undo.sh $tolistpath"
eval $cmd
cmd="./intersect_results.sh $tolistpath"
eval $cmd
cmd="./exclude_combined.sh ${tolistpath}"
eval $cmd 
cmd="./analyze_group.sh $tolistpath 2.5 newfile"
eval $cmd

