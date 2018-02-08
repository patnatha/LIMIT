source ../basedir.sh
toswitch=$1
switch_input

tolistpath=$limitdir

run_that_stuff(){
    eval $cmd
    echo $cmd
}

cmd="./post_process_undo.sh $tolistpath"
run_that_stuff
cmd="./intersect_group.sh $tolistpath"
run_that_stuff
cmd="./exclude_combined.sh $tolistpath"
run_that_stuff
cmd="./analyze_group.sh $tolistpath 2.5 newfile"
run_that_stuff
cmd="./analyze_group.sh $tolistpath 5.0 appendfile"
run_that_stuff

