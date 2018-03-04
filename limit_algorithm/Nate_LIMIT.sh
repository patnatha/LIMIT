source ../basedir.sh
toswitch=$1
switch_input

sed -i 's/ppn=[0-9]\+/ppn=4/' Nate_LIMIT.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' Nate_LIMIT.pbs
sed -i 's/walltime=[0-9]\+\:[0-9]\+\:[0-9]\+/walltime=24:00:00/' Nate_LIMIT.pbs

tolistpath=${preparedir}
run_dir_limit

