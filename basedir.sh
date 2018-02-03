homedir="/scratch/leeschro_armis/patnatha/"

basedir="${homedir}raw_data/"
mkdir -p "${basdir}"

preparedir="${homedir}prepared_data/"
mkdir -p "${preparedir}"

limitdir="${homedir}limit_results/"
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
    toutdir="${outdir}${incGrp}/"
    mkdir -p $toutdir

    if [[ -z $startDate ]] & [[ -z $endDate ]]
    then
        eval "qsub prepare_data.pbs -F \"--input $inval --sex $thesex --race $therace --include $incGrp --age $theage --output ${toutdir}\""
    else
        eval "qsub prepare_data.pbs -F \"--input $inval --start $startDate --end $endDate --sex $thesex --race $therace --include $incGrp --age $theage --output ${toutdir}\""
    fi
}

