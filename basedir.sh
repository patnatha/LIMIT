homedir="/scratch/leeschro_armis/patnatha/"

basedir="${homedir}raw_data/"
mkdir -p "${basedir}"

preparedir="${homedir}prepared_data/"
mkdir -p "${preparedir}"

limitdir="${homedir}limit_results/"
mkdir -p "${limitdir}"

run_dir_limit(){
    preplist=`ls -1 ${tolistpath} | tr '\n' '\0' | xargs -0 -n 1 basename | grep selected`
    for tfile in $preplist;
    do
        run_em_limit
    done
}

run_em_limit(){
    outpath=${tolistpath/"prepared_data"/"limit_results"}
    mkdir -p $outpath

    finfile="$tolistpath$tfile"

    thecmd="qsub Nate_LIMIT.pbs -F \"--input $finfile --code icd --output $outpath \""
    eval $thecmd

    thecmd="qsub Nate_LIMIT.pbs -F \"--input $finfile --code med --output $outpath \""
    eval $thecmd

    thecmd="qsub Nate_LIMIT.pbs -F \"--input $finfile --code lab --output $outpath \""
    eval $thecmd
}

run_em_prepare(){
    toutdir="${outdir}${incGrp}/"
    mkdir -p $toutdir

    if [[ -z $startDate ]] & [[ -z $endDate ]]
    then
        eval "qsub prepare_data.pbs -F \"--input $inval --sex $thesex --race $therace --include $incGrp --age $theage --output ${toutdir}\""
        echo "Rscript prepare_data.R --input $inval --sex $thesex --race $therace --include $incGrp --age $theage --output ${toutdir}\""
    else
        eval "qsub prepare_data.pbs -F \"--input $inval --start $startDate --end $endDate --sex $thesex --race $therace --include $incGrp --age $theage --output ${toutdir}\""
        echo "Rscript prepare_data.R --input $inval --start $startDate --end $endDate --sex $thesex --race $therace --include $incGrp --age $theage --output ${toutdir}\""
    fi
}

run_em_select(){
    sed -i 's/ppn=[0-9]\+/ppn=1/' prepare_selection.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' prepare_selection.pbs

    preplist=`ls -1 ${tolistpath} | tr '\n' '\0' | xargs -0 -n 1 basename | grep --invert-match selected`
    for tfile in $preplist;
    do
        eval "qsub prepare_selection.pbs -F \"--input ${tolistpath}${tfile} --singular-value ${singularValue}\""
        #echo "Rscript prepare_selection.R --input ${tolistpath}${tfile} --singular-value ${singularValue}"
    done
}
