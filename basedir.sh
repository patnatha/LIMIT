homedir="/scratch/leeschro_armis/patnatha/"

basedir="${homedir}raw_data/"
mkdir -p "${basedir}"

preparedir="${homedir}prepared_data/"
mkdir -p "${preparedir}"

limitdir="${homedir}limit_results/"
mkdir -p "${limitdir}"

#Variables for tuning
declare -a criticalHampels=("0.5" "1.0" "2.0" "3.0")
declare -a criticalPs=("0.05" "0.1" "0.2")
declare -a criticalProps=("0" "0.005" "0.01" "0.025" "0.05")
declare -a day_time_offset_posts=("360" "180" "120" "90" "60" "30" "5")
declare -a day_time_offset_pres=("360" "180" "120" "90" "60" "30" "5")
declare -a code_switch=("icd" "med" "lab")

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
    #Create the output directory
    toutdir="${preparedir}${incGrp}/"
    mkdir -p $toutdir
   
    #Space cannot be sent to the batch manager, so one must make them a single string 
    inval=${inval/\ /\?}

    if [[ -z $startDate ]] | [[ -z $endDate ]]
    then
        parameters="--input '$inval' --sex $thesex --race $therace --include $incGrp --age $theage --output ${toutdir}"
    else
        parameters="--input '$inval' --start $startDate --end $endDate --sex $thesex --race $therace --include $incGrp --age $theage --output ${toutdir}"
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
    errStmt="ERROR: A1C, ALK, ALK_MAYO, BILI, BMP, CALIPER, ELEC, HGB2, LIVER, PLT, TEST, TUNEUP, WBC"
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
    elif [ "${toswitch}" == "HGB2" ]
    then
        preparedir="${preparedir}HGB_two_groups/"
    elif [ "${toswitch}" == "LIVER" ]
    then
        preparedir="${preparedir}liver_enzymes/"
    elif [ "${toswitch}" == "PLT" ]
    then
        preparedir="${preparedir}platelet/"
    elif [ "${toswitch}" == "TEST" ]
    then
        preparedir="${preparedir}glucose_2_months/"
    elif [ "${toswitch}" == "WBC" ]
    then
        preparedir="${preparedir}white_blood_cell/"
    elif [ "${toswitch}" == "TUNEUP" ]
    then
        preparedir="${preparedir}tune_up/"
    elif [ "${toswitch}" == "A1C" ]
    then
        preparedir="${preparedir}hgb_a1c/"
    elif [ "${toswitch}" == "CALIPER" ]
    then
        preparedir="${preparedir}caliper/"
    else
        echo $errStmt
        exit
    fi

    limitdir=${preparedir/"prepared_data"/"limit_results"}
    mkdir -p $preparedir
    mkdir -p $limitdir
}

post_process_dir(){
    prepdirstemp=`find ${tolistpath} -maxdepth 2 -type d`
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

