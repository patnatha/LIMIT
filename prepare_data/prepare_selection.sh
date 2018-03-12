#Switch on the input the files to run
source ../basedir.sh
toswitch=$1
switch_input

#Setup the resources required to run
sed -i 's/ppn=[0-9]\+/ppn=1/' prepare_selection.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=12gb/' prepare_selection.pbs

#Set the selection value
errStmt="ERROR: must enter valid selection method [most_recent|random|all|latest]"
singularValue=$2
if [ -z $singularValue ]
then
    #Set the default behaior
    singularValue="random"
else
    if [[ "$singularValue" != "random" ]] && [[ "$singularValue" != "most_recent" ]] && [[ "$singularValue" != "all" ]] && [[ "$singularValue" != "latest" ]]
    then
        echo $errStmt
        exit
    fi
fi

#Run the selection process
tolistpath=$preparedir
run_em_select

