source ../basedir.sh
toswitch=$1
switch_input

thecmd="qsub analyze_files.pbs -F \"$@"\"
eval $thecmd

