
run_em(){
    outpath=${tolistpath/"prepared_data"/"limit_results"}
    mkdir -p $outpath
    finfile="$tolistpath$tfile"
    thecmd="qsub Nate_LIMIT.pbs -F \"--input $finfile --code icd --output $outpath --singular-value $singularValue\""
    eval $thecmd

    thecmd="qsub Nate_LIMIT.pbs -F \"--input $finfile --code med --output $outpath --singular-value $singularValue\""
    eval $thecmd

    thecmd="qsub Nate_LIMIT.pbs -F \"--input $finfile --code lab --output $outpath --singular-value $singularValue\""
    eval $thecmd
}

run_dir(){
    preplist=`ls -1 ${tolistpath} | tr '\n' '\0' | xargs -0 -n 1 basename`
    for tfile in $preplist;
    do
        run_em
    done
}

singularValue="random"
tolistpath="/scratch/leeschro_armis/patnatha/prepared_data/hgb_5_years/hgb_5_years_10_y_range/"
run_dir
tolistpath="/scratch/leeschro_armis/patnatha/prepared_data/hgb_5_years/hgb_5_years_2_groups/"
run_dir

