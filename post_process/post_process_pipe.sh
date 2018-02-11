tolistpath=$1

cmd="./post_process_undo.sh $tolistpath"
eval $cmd
cmd="./intersect_group.sh $tolistpath"
eval $cmd
cmd="./exclude_combined.sh $tolistpath"
eval $cmd

