source ../basedir.sh
toswitch=$1
switch_input
tolistpath=$limitdir

thecmd="qsub analyze_selection.pbs -F \"--input $tolistpath"\"
eval $thecmd

