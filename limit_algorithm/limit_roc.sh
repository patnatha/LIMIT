source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=8/' Nate_LIMIT.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' Nate_LIMIT.pbs

#Setup the path for input and output
tolistpath="${preparedir}roc/outpatient_and_never_inpatient/"
outpath=${tolistpath/"prepared_data"/"limit_results"}
mkdir -p $outpath

step_it_fxn(){
    out=""
    for (( i=1; $i<=$(bc<<<"$bce/$step"); i++ )); do
        out="$out,$(bc<<<"$step * $i")"
    done
    out="${out:1:${#out}-1}"
}

run_that_file(){
    #Tune the Hampel parameter
    bc="0.25"
    bce="3.50"
    step="0.25"
    step_it_fxn
    criticalHampels=$out

    #Tune the critical p-value
    bc="0.05"
    bce="0.25"
    step="0.05"
    step_it_fxn
    criticalPs=$out

    #Tune the critical proportion
    bc="0.005"
    bce="0.010"
    step="0.005"
    step_it_fxn
    criticalProps=$out

    #Tune the day-time-offset-pre
    bc="5"
    bce="125"
    step="30"
    step_it_fxn
    dtoPres=$out

    #Tune the day-time-offset-post
    bc="5"
    bce="125"
    step="30"
    step_it_fxn
    dtoPosts=$out

    singularValues="random"
    codes="icd,med,lab"

    numberOfRuns=0
    for criticalHampel in  $(echo $criticalHampels | sed "s/,/ /g")
    do
        for criticalP in $(echo $criticalPs | sed "s/,/ /g")
        do
            for criticalProp in $(echo $criticalProps | sed "s/,/ /g")
            do
                for dtoPre in $(echo $dtoPres | sed "s/,/ /g")
                do
                    for singularValue in $(echo $singularValues | sed "s/,/ /g")
                    do
                        for code in $(echo $codes | sed "s/,/ /g")
                        do
                            filename=$(echo $tfile | cut -d "." -f1)
                            #echo "qsub Nate_LIMIT.sh --critical-hampel $criticalHampel --critical-p-value $criticalP --critical-proportion $criticalProp --day-time-offset-pre $dtoPre --day-time-offset-post $dtoPre --singular-value $singularValue --code $code --output $outpath --input $finfile --name ${filename}_H${criticalHampel}P${criticalP}Prop${criticalProp}PrePost${dtoPre}SV${singularValue}_${code}"
                            numberOfRuns=$((numberOfRuns + 1))
                        done
                    done
                done
            done
        done
    done

    echo $numberOfRuns
}

preplist=`ls -1 ${tolistpath} | tr '\n' '\0' | xargs -0 -n 1 basename`
for tfile in $preplist;
do
    finfile=${tolistpath}${tfile}
    run_that_file
done

