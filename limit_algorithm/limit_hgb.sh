source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=4/' Nate_LIMIT.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=16gb/' Nate_LIMIT.pbs

singularValue="random"

tolistpath="${preparedir}hgb/hgb_2_groups/"
run_dir_limit

tolistpath="${preparedir}hgb/hgb_10_y_range/"
run_dir_limit

