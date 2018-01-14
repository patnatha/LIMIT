source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=8/' Nate_Limit.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=16gb/' Nate_Limit.pbs

singularValue="random"
tolistpath="${preparedir}alk_phos_5_years/"
run_dir_limit

