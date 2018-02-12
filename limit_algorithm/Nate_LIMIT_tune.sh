source ../basedir.sh
toswitch="TUNEUP"
switch_input

sed -i 's/ppn=[0-9]\+/ppn=8/' Nate_LIMIT.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' Nate_LIMIT.pbs

declare -a criticalHampels=("0.5" "1.0" "1.5" "2.0" "2.5" "3.0" "3.5")
declare -a criticalPs=("0.05" "0.1" "0.2")
declare -a criticalProps=("0" "0.005" "0.01")
declare -a day_time_offset_posts=("120" "60" "5")
declare -a day_time_offset_pres=("120" "60" "5")

theCounter = 0
tolistpath=${preparedir}
preplist=`find ${tolistpath} | grep selected`
for tfile in $preplist;
do
    echo `basename $tfile`
    for (( i=0; i<${#criticalHampels[@]}; i++ ));
    do
        for (( j=0; j<${#criticalPs[@]}; j++ ));
        do
            for (( k=0; k<${#criticalProps[@]}; k++ ));
            do
                for (( l=0; l<${#day_time_offset_posts[@]}; l++ ));
                do
                    parameters="--critical-hampel ${criticalHampels[$i]} --critical-p-value ${criticalPs[$j]} --critical-proportion ${criticalProps[$k]} --day-time-offset-post ${day_time_offset_posts[$l]} --day-time-offset-pre ${day_time_offset_pres[$l]}"
                    theCounter=$((theCounter + 1))
                    echo $parameters
                done
            done
        done
    done
done

echo "COUNT: $theCounter" 
