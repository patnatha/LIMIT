homedir="/scratch/leeschro_armis/patnatha/"

basedir="${homedir}raw_data/"
mkdir -p "${basedir}"

preparedir="${homedir}prepared_data/"
mkdir -p "${preparedir}"

limitdir="${homedir}limit_results/"
mkdir -p "${limitdir}"

run_dir_limit(){
    preplist=`find ${tolistpath} | grep selected`
    for tfile in $preplist;
    do
        run_em_limit
    done
}

run_em_limit(){
    #Create the output path
    toutdir=`dirname $tfile`
    toutdir=${toutdir/"prepared_data"/"limit_results"}
    mkdir -p $toutdir

    #Build the params to send
    paramsone="--input $tfile --code icd --output $toutdir"
    paramstwo="--input $tfile --code med --output $toutdir"
    paramsthree="--input $tfile --code lab --output $toutdir"

    eval "qsub Nate_LIMIT.pbs -F \"${paramsone}\""
    eval "qsub Nate_LIMIT.pbs -F \"${paramstwo}\""
    eval "qsub Nate_LIMIT.pbs -F \"${paramsthree}\""
    #echo "Rscript Nate_LIMIT.R ${paramsone}"
}

run_em_prepare(){
    toutdir="${preparedir}${incGrp}/"
    mkdir -p $toutdir

    if [[ -z $startDate ]] | [[ -z $endDate ]]
    then
        parameters="--input $inval --sex $thesex --race $therace --include $incGrp --age $theage --output ${toutdir}"
    else
        parameters="--input $inval --start $startDate --end $endDate --sex $thesex --race $therace --include $incGrp --age $theage --output ${toutdir}"
    fi

    eval "qsub prepare_data.pbs -F \"${parameters}\""
    #echo "Rscript prepare_data.R ${parameters}"
}

run_em_select(){
    preplist=`find ${tolistpath} -maxdepth 3 | grep Rdata | grep --invert-match selected`
    for tfile in $preplist;
    do
        #Create the output directory
        outdir=`dirname ${tfile}`
        outdir="${outdir}/${singularValue}/"
        mkdir -p $outdir

        parameters="--input ${tfile} --singular-value ${singularValue} --output ${outdir}"        
        eval "qsub prepare_selection.pbs -F \"${parameters}\""
        #echo "Rscript prepare_selection.R ${parameters}"
    done
}

switch_input(){
    errStmt="ERROR: ALK, ALK_MAYO, BILI, BMP, CALIPER, ELEC, HGB, LIVER, PLT, TEST, TUNEUP1, TUNEUP5, WBC"
    if [[ -z $toswitch ]]
    then
        echo $errStmt
        exit
    elif [ "${toswitch}" == "ALK" ]
    then
        preparedir="${preparedir}alk_phos/"
    elif [ "${toswitch}" == "ALK_MAYO" ]
    then
        preparedir="${preparedir}alk_phos_mayo/"
    elif [ "${toswitch}" == "BILI" ]
    then
        preparedir="${preparedir}bilirubin/"
    elif [ "${toswitch}" == "BMP" ]
    then
        preparedir="${preparedir}basic_metabolic_panel/"
    elif [ "${toswitch}" == "ELEC" ]
    then
        preparedir="${preparedir}other_electrolytes/"
    elif [ "${toswitch}" == "HGB" ]
    then
        preparedir="${preparedir}HGB_HGBN/"
    elif [ "${toswitch}" == "LIVER" ]
    then
        preparedir="${preparedir}liver_enzymes/"
    elif [ "${toswitch}" == "PLT" ]
    then
        preparedir="${preparedir}platelet/"
    elif [ "${toswitch}" == "TUNEUP1" ]
    then
        preparedir="${preparedir}tune_up_1_year/"
    elif [ "${toswitch}" == "TUNEUP5" ]
    then
        preparedir="${preparedir}tune_up_5_year/"
    elif [ "${toswitch}" == "TEST" ]
    then
        preparedir="${preparedir}glucose_2_months/"
    elif [ "${toswitch}" == "WBC" ]
    then
        preparedir="${preparedir}white_blood_cell/"
    else
        echo $errStmt
        exit
    fi

    limitdir=${preparedir/"prepared_data"/"limit_results"}
    mkdir -p $preparedir
    mkdir -p $limitdir
}

post_process_dir(){
    prepdirstemp=`find ${tolistpath} -maxdepth 3 -type d`
    prepdirs=""
    for tdir in $prepdirstemp
    do
        if [[ $tdir == *"random" ]] || [[ $tdir == *"most_recent" ]] || [[ $tdir == *"all" ]] || [[ $tdir == *"latest" ]]
        then
            prepdirs+="${tdir}|"
        fi
    done
    
    prepdirs=`echo $prepdirs | tr "|" "\n"` 
}

