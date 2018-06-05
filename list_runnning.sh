echo "########################PREPARE_DATA########################"
for pid in `qstat | grep \`whoami\` | grep R | grep prepare_data | awk '{print $1}' | cut -d '.' -f1`
do
    yase=`qpeek ${pid} | grep 'Output File:' | cut -d':' -f2 | cut -d'"' -f1 | cut -d / -f6-`

    echo "prepare_data ($pid): $yase"
done

echo "#####################PREPARE_SELECTION######################"
for pid in `qstat | grep \`whoami\` | grep R | grep prepare_selection | awk '{print $1}' | cut -d '.' -f1`
do
    yase=`qpeek ${pid} | grep 'Loading\ Data:' | cut -d':' -f2 | cut -d'"' -f1 | cut -d / -f6-`
    echo "prepare_selection ($pid): $yase"
done

echo "#########################NATE_LIMIT#########################"
for pid in `qstat | grep \`whoami\` | grep R | grep Nate_LIMIT | awk '{print $1}' | cut -d '.' -f1`
do
    yase=`qpeek ${pid} | grep 'Loading\ Data:\|Running:' | cut -d':' -f2 | cut -d'"' -f1 | cut -d / -f6-`
    echo "Nate_LIMIT ($pid): $yase"
done

echo "#######################ANALYZE_FILES########################"
for pid in `qstat | grep \`whoami\` | grep R | grep analyze_files | awk '{print $1}' | cut -d '.' -f1`
do
    yase=`qpeek ${pid} | grep 'ANALYZE:' | cut -d':' -f2 | cut -d'"' -f1 | cut -d / -f6-`
    echo "analyze_files ($pid): $yase"
done

