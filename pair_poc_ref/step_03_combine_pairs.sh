source ../basedir.sh
toswitch=$1
switch_input

theCmd="qsub step_03_combine_pairs.pbs -F \"--input ${preparedir}\""
#echo $theCmd
eval $theCmd

