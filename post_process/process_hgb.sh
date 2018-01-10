tolistpath='/scratch/leeschro_armis/patnatha/limit_results/hgb_5_years/hgb_5_years_10_y_range/'
cmd="./intersect_results.sh $tolistpath"
eval $cmd
cmd="./Group_analysis.sh $tolistpath 2.5 newfile"
eval $cmd

tolistpath='/scratch/leeschro_armis/patnatha/limit_results/hgb_5_years/hgb_5_years_2_groups/'
cmd="./Group_analysis.sh $tolistpath 2.5 newfile"
eval $cmd
cmd="./Group_analysis.sh $tolistpath 5.0 appendfile"
eval $cmd

