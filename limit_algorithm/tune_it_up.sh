iterWaitTime=$((60 * 5))

while true
do
    #Time and run the function
    curTime=`date`
    SECONDS=0
    ./Nate_LIMIT_tune.sh
    DURATION=$SECONDS 
    echo "TIMING: ${curTime}/${DURATION} secs"
    
    #Wait for a hit sex before running it again
    underOver="$(($iterWaitTime - $DURATION))"
    if [ $underOver -gt 0 ]
    then
        sleep ${underOver}s
    fi
done

