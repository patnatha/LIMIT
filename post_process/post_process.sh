source ../basedir.sh
toswitch=$1
switch_input

tolistpath=$limitdir

cmd="qsub post_process.pbs -F \"${tolistpath}\""
eval $cmd

#cmd="Rscript post_process_pipe.sh ${tolistpath}"
#echo $cmd

