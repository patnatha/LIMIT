source ../basedir.sh
toswitch=$1
switch_input

sed -i 's/ppn=[0-9]\+/ppn=8/' Nate_LIMIT.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' Nate_LIMIT.pbs

tolistpath=${preparedir}
run_dir_limit

