iterWaitTime=$((60 * 5))

while true
do
    #Time and run the function
    curTime=`date`
    SECONDS=0
    ./tune_Nate_LIMIT.sh $@
    ../clean_dir.sh
    DURATION=$SECONDS 
    echo "TIMING: ${curTime}/${DURATION} secs"
    
    #Wait for a bit before running it again
    underOver="$(($iterWaitTime - $DURATION))"
    if [ $underOver -gt 0 ]
    then
        sleep ${underOver}s
    fi
done

