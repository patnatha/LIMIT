#Switch on the input the files to run
source ../basedir.sh
toswitch=$1
switch_input

#Setup the resources required to run
sed -i 's/ppn=[0-9]\+/ppn=1/' count_files.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=12gb/' count_files.pbs

#Run the selection process
tolistpath=$preparedir
cmd="qsub count_files.pbs -F \"--input ${tolistpath}\""
eval $cmd

