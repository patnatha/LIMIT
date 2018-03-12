source ../basedir.sh
toswitch=$1
switch_input

if [ -z $2 ] || [[ $2 == "small" ]]
then
    sed -i 's/ppn=[0-9]\+/ppn=4/' Nate_LIMIT.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' Nate_LIMIT.pbs
    sed -i 's/walltime=[0-9]\+\:[0-9]\+\:[0-9]\+/walltime=24:00:00/' Nate_LIMIT.pbs
elif [[ $2 == "large" ]]
then
    sed -i 's/ppn=[0-9]\+/ppn=8/' Nate_LIMIT.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' Nate_LIMIT.pbs
    sed -i 's/walltime=[0-9]\+\:[0-9]\+\:[0-9]\+/walltime=48:00:00/' Nate_LIMIT.pbs
fi

tolistpath=${preparedir}
run_dir_limit

