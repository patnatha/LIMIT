source ../basedir.sh
toswitch=$1
switch_input

if [ -z $inval ]
then
    echo "ERROR: the input result_codes is NULL"
    exit
fi

theCmd="qsub step_01_prepare_to_pair.pbs -F \"--input ${inval} --output ${preparedir} --start 2014-01-01 --end 2018-01-01\""
eval $theCmd

