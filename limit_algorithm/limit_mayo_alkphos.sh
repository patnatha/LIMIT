source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=8/' Nate_LIMIT.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' Nate_LIMIT.pbs

singularValue="random"
tolistpath="${preparedir}mayo_alk_phos/outpatient/"
run_dir_limit

