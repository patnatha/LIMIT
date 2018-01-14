source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=8/' Nate_Limit.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=16gb/' Nate_Limit.pbs

singularValue="random"

tolistpath="${preparedir}hgb_5_years/hgb_5_years_2_groups/"
run_dir_limit

tolistpath="${preparedir}hgb_5_years/hgb_5_years_10_y_range/"
run_dir_limit

