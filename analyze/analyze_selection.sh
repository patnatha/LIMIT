source ../basedir.sh
toswitch=$1
switch_input
tolistpath=$preparedir

thecmd="Rscript analyze_selection.R --input $tolistpath"
eval $thecmd

