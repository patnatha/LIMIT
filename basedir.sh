basedir="/scratch/leeschro_armis/patnatha/"

preparedir="${basedir}prepared_data/"
mkdir -p "${preparedir}"

limitdir="${basedir}limit_results/"
mkdir -p "${limitdir}"

run_dir(){
    preplist=`ls -1 ${tolistpath} | tr '\n' '\0' | xargs -0 -n 1 basename`
    for tfile in $preplist;
    do
        run_em
    done
}

run_dir_limit(){
    run_em() { run_em_limit; }
    run_dir
}

run_em_limit(){
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

run_em_prepare(){
    eval "qsub prepare_data.pbs -F \"--input $basedir$indir --sex $thesex --race $therace --include $incGrp --age $theage --output ${outdir}\""
}

