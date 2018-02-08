#Switch on the input the files to run
source ../basedir.sh
toswitch=$1
switch_input

#Setup the resources required to run
sed -i 's/ppn=[0-9]\+/ppn=1/' prepare_selection.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_selection.pbs

#Set the selection value
if [ -z $2 ]
then
    singularValue="random"
else
    if [ $2 == "random" ] || [ $2 == "most_recent" ]
    then
        singularValue=$2
    else
        echo "ERROR: must enter valid selection method [most_recent|random]"
        exit
    fi
fi

#Run the selection process
tolistpath=$preparedir
run_em_select

