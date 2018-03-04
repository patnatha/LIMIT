source ../basedir.sh
toswitch=$1
switch_input

cmd="qsub post_process.pbs -F \"$1\""
eval $cmd
#echo $cmd

