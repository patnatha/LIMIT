#Switch on the input the files to run
source ../basedir.sh
toswitch=$1
switch_input

#Setup the resources required to run
sed -i 's/ppn=[0-9]\+/ppn=1/' prepare_selection.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_selection.pbs

#Set the selection value
errStmt="ERROR: must enter valid selection method [most_recent|random|all|latest]"
if [ -z $2 ]
then
    echo $errStmt
    exit
else
    if [ $2 == "random" ] || [ $2 == "most_recent" ] || [[ $2 == "all" ]] || [[ $2 == "latest" ]]
    then
        singularValue=$2
    else
        echo $errStmt
        exit
    fi
fi

#Run the selection process
tolistpath=$preparedir
run_em_select

