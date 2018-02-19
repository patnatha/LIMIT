source ../basedir.sh
toswitch=$1
switch_input

theCmd="qsub step_04_prepare_pair.pbs -F \"--input ${preparedir}\""
echo $theCmd
#eval $theCmd

