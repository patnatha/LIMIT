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
    preplist=`find ${tolistpath} -maxdepth 3 | grep Rdata | grep --invert-match selected`
    for tfile in $preplist;
    do
        #Create the output directory
        outdir=`dirname ${tfile}`
        eval "rm -rf ${outdir}/*selected.Rdata"
        outdir="${outdir}/${singularValue}/"
        mkdir -p $outdir

        parameters="--input ${tfile} --singular-value ${singularValue} --output ${outdir}"        
        eval "qsub prepare_selection.pbs -F \"${parameters}\""
        #echo "Rscript prepare_selection.R ${parameters}"
    done
}

switch_input(){
    if [[ -z $toswitch ]]
    then
        echo "ERROR: ALK, ALK_MAYO, BILI, BMP, CALIPER, ELEC, HGB, PLT, ROC, TEST, WBC"
        exit
    fi

    if [ "${toswitch}" == "ALK" ]
    then
        preparedir="${preparedir}alk_phos/"
    fi
    
    if [ "${toswitch}" == "ALK_MAYO" ]
    then
        preparedir="${preparedir}alk_phos_mayo/"
    fi 

    if [ "${toswitch}" == "BILI" ]
    then
        preparedir="${preparedir}bilirubin/"
    fi

    if [ "${toswitch}" == "BMP" ]
    then
        preparedir="${preparedir}basic_metabolic_panel/"
    fi

    if [ "${toswitch}" == "ELEC" ]
    then
        preparedir="${preparedir}other_electrolytes/"
    fi

    if [ "${toswitch}" == "HGB" ]
    then
        preparedir="${preparedir}HGB_HGBN"
    fi

    if [ "${toswitch}" == "LIVER" ]
    then
        preparedir="${preparedir}liver_enzymes"
    fi

    if [ "${toswitch}" == "PLT" ]
    then
        preparedir="${preparedir}platelet/"
    fi

    if [ "${toswitch}" == "ROC" ]
    then
        preparedir="${preparedir}roc"
    fi

    if [ "${toswitch}" == "TEST" ]
    then
        preparedir="${preparedir}glucose_2_months"
    fi

    if [ "${toswitch}" == "WBC" ]
    then
        preparedir="${preparedir}white_blood_cell"
    fi

    limitdir=${preparedir/"prepared_data"/"limit_results"}
    mkdir -p $preparedir
    mkdir -p $limitdir
}

