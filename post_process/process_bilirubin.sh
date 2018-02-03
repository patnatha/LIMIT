source ../basedir.sh

tolistpath="${limitdir}bilirubin/outpatient/"
cmd="./intersect_results.sh $tolistpath"
eval $cmd
cmd="Rscript exclude_combined.R --input ${tolistpath}"
eval $cmd
cmd="./analyze_group.sh $tolistpath 2.5 newfile"
eval $cmd

