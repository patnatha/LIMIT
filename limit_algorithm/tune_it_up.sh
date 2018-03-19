source ../basedir.sh
iterWaitTime=$((60 * 5))

while true
do
    curTime=`date`
    SECONDS=0
    if [[ "$1" == "TUNE_CALIPER" ]]
    then
        ./tune_Nate_LIMIT.sh $1
    elif [[ "$1" == "TUNE_CALIPER_MICRO" ]]
    then
        ./tune_micro_Nate_LIMIT.sh $1
    elif [[ "$1" == "SAMPLE_CALIPER" ]] || [[ "$1" == "TUNE_CALIPER_SAMPLE" ]]
    then
        ./sample_tune_it.sh $1
        exit
    else
        toswitch=$1
        switch_input 
        echo "ERROR: incorrect input"
        exit
    fi
    
    ../clean_dir.sh QUIET
    DURATION=$SECONDS
    echo "TIMING: ${curTime}/${DURATION} secs"
    
    underOver="$(($iterWaitTime - $DURATION))"
    if [ $underOver -gt 0 ]
    then
        sleep ${underOver}s
    fi

done

