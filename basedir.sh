homedir="/scratch/leeschro_armis/patnatha/"
basedir="${homedir}raw_data/"
mkdir -p "${basedir}"

preparedir="${homedir}prepared_data/"
mkdir -p "${preparedir}"

limitdir="${homedir}limit_results/"
mkdir -p "${limitdir}"

#Variables for tuning
declare -a criticalHampels=("1.0" "2.0" "3.0") #"0.5"
declare -a criticalPs=("0.05" "0.1" "0.2") 
declare -a criticalProps=("0" "0.005" "0.01") #"0.025" "0.05"
declare -a day_time_offset_posts=("54750" "360" "180" "5" "0") #"75" "30" 
declare -a day_time_offset_pres=("54750" "360" "180" "5" "0") #"75" "30"
declare -a code_switch=("icd" "med" "lab")
declare -a sample_sizes=("10000" "5000" "2500" "1000" "800" "600" "500" "400" "300" "250" "200" "150" "100" "50")

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
    params="--input $tfile --output $toutdir"
   
    eval "qsub Nate_LIMIT.pbs -F \"${params} --code all\""
    #echo "Rscript Nate_LIMIT.R ${params}"
}

run_em_prepare(){
    #Create the output directory
    toutdir="${preparedir}${incGrp}/"
    mkdir -p $toutdir
   
    #Space cannot be sent to the batch manager, so one must make them a single string 
    inval=${inval/\ /\?}

    parameters="--input '$inval' --sex $thesex --race $therace --include $incGrp --age $theage --output ${toutdir}"

    if [[ ! -z $startDate ]] | [[ ! -z $endDate ]]
    then
        parameters="${parameters} --start $startDate --end $endDate"
    fi

    if [[ ! -z $maxSample ]]
    then
        parameters="${parameters} --max-sample $maxSample"
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
    errStmt="ERROR: A1C, ALK, ALK_MAYO, BILI, BMP, CALIPER, ELEC, HGB2, LIVER, PAIR_GLUC, PLT, TEST, TEST_CALIPER, TEST_CALIPER_ANALYZE, TRAIN, TRAIN_TRAIN, TRAIN_TEST, TUNE_CALIPER, TUNE_CALIPER_SAMPLE, TUNE_CALIPER_ANALYZE, SAMPLE_CALIPER, WBC"
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
    elif [ "${toswitch}" == "ALK_UMICH" ]
    then
        preparedir="${preparedir}alk_phos_umich/"
    elif [ "${toswitch}" == "BILI" ]
    then
        preparedir="${preparedir}bilirubin/"
    elif [ "${toswitch}" == "BMP" ]
    then
        preparedir="${preparedir}basic_metabolic_panel/"
        refCodes="UMICH"
    elif [ "${toswitch}" == "ELEC" ]
    then
        preparedir="${preparedir}other_electrolytes/"
        refCodes="UMICH"
    elif [ "${toswitch}" == "HGB2" ]
    then
        preparedir="${preparedir}HGB_two_groups/"
        refCodes="NHANES"
    elif [ "${toswitch}" == "LIVER" ]
    then
        preparedir="${preparedir}liver_enzymes/"
    elif [ "${toswitch}" == "PLT" ]
    then
        preparedir="${preparedir}platelet/"
    elif [ "${toswitch}" == "WBC" ]
    then
        preparedir="${preparedir}white_blood_cell/"
    elif [ "${toswitch}" == "TUNE_CALIPER" ]
    then
        preparedir="${preparedir}tune_caliper/"
        refCodes="CALIPER"
    elif [ "${toswitch}" == "TUNE_CALIPER_SAMPLE" ]
    then
        preparedir="${preparedir}tune_caliper_sample/"
        refCodes="CALIPER"
    elif [ "${toswitch}" == "TUNE_CALIPER_ANALYZE" ]
    then
        preparedir="${preparedir}tune_caliper_analyze/"
        refCodes="CALIPER"
    elif [ "${toswitch}" == "TEST_CALIPER_ANALYZE" ]
    then
        preparedir="${preparedir}test_caliper_analyze/"
        refCodes="CALIPER"
    elif [ "${toswitch}" == "SAMPLE_CALIPER" ]
    then
        preparedir="${preparedir}caliper_sample/"
        refCodes="CALIPER"
    elif [ "${toswitch}" == "TEST_CALIPER" ]
    then
        preparedir="${preparedir}caliper_test/"
        refCodes="CALIPER"
    elif [ "${toswitch}" == "A1C" ]
    then
        preparedir="${preparedir}hgb_a1c/"
    elif [ "${toswitch}" == "CALIPER" ]
    then
        preparedir="${preparedir}caliper/"
        refCodes="CALIPER"
    elif [ "${toswitch}" == "PAIR_GLUC" ]
    then
        preparedir="${preparedir}paired_glucose/"
        inval="GLUC,GLUC-WB"
    elif [ "${toswitch}" == "TRAIN_TEST" ]
    then
        preparedir="${preparedir}train_test/"
    elif [ "${toswitch}" == "TRAIN" ]
    then
        preparedir="${preparedir}train/"
        refCodes="ABBOTT_CALIPER,MAYO"
    elif [ "${toswitch}" == "TRAIN_PEDS" ]
    then
        preparedir="${preparedir}train_peds/"
        refCodes="ABBOTT_CALIPER,MAYO"
    elif [ "${toswitch}" == "TRAIN_ADULTS" ]
    then
        preparedir="${preparedir}train_adult/"
        refCodes="ABBOTT_CALIPER,MAYO"
    elif [ "${toswitch}" == "TRAIN_TRAIN" ]
    then
        preparedir="${preparedir}train_train/"
        refCodes="ABBOTT_CALIPER,MAYO"
    elif [ "${toswitch}" == "TRAIN_SMALL" ]
    then
        preparedir="${preparedir}train_small/"
        refCodes="ABBOTT_CALIPER,MAYO"
    elif [ "${toswitch}" == "TRAIN_LARGE" ]
    then
        preparedir="${preparedir}train_large/"
        refCodes="ABBOTT_CALIPER,MAYO"
    elif [ "${toswitch}" == "TEST" ]
    then
        preparedir="${preparedir}test/"
        refCodes="ABBOTT_CALIPER,MAYO"
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
        temptdir=`dirname ${tdir}`
        if [[ "${tdir}/" == "${tolistpath}" ]] || [[ "${temptdir}/" == "${tolistpath}" ]]
        then
            continue
        fi

        if [[ $tdir == *"random" ]] || [[ $tdir == *"most_recent" ]] || [[ $tdir == *"all" ]] || [[ $tdir == *"latest" ]]
        then
            prepdirs+="${tdir}|"
        fi
    done
    
    prepdirs=`echo $prepdirs | tr "|" "\n"` 
}

