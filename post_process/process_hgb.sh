source ../basedir.sh

whichdir="HGB_HGBN"

#Analyze the decade range
tolistpath="${limitdir}${whichdir}/${whichdir}_10_y_range/"
cmd="./intersect_results.sh $tolistpath"
eval $cmd
cmd="Rscript exclude_combined.R --input ${tolistpath}"
eval $cmd
cmd="./analyze_group.sh $tolistpath 2.5 newfile"
eval $cmd

#Analyze the 2 groups
tolistpath="${limitdir}${whichdir}/${whichdir}_2_groups/"
cmd="./intersect_results.sh $tolistpath"
eval $cmd
cmd="Rscript exclude_combined.R --input ${tolistpath}"
eval $cmd
cmd="./analyze_group.sh $tolistpath 2.5 newfile"
eval $cmd
cmd="./Group_analysis.sh $tolistpath 5.0 appendfile"
eval $cmd

