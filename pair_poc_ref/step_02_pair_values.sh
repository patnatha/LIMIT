source ../basedir.sh
toswitch=$1
switch_input

files=`find ${preparedir} | grep -P "[0-9]+\.bin"`
for file in $files;
do
    theCmd="qsub step_02_pair_values.pbs -F \"--input $file\""
    #echo $theCmd
    eval $theCmd
done

