source ../basedir.sh

tolistpath="${limitdir}liver_enzymes/outpatient_and_never_inpatient/"
cmd="./intersect_results_undo.sh $tolistpath"
eval $cmd
cmd="./intersect_results.sh $tolistpath"
eval $cmd
cmd="Rscript exclude_combined.R --input ${tolistpath}"
eval $cmd
cmd="./analyze_group.sh $tolistpath 2.5 newfile"
eval $cmd

