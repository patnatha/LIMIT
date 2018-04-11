source ../basedir.sh
toswitch=$1
switch_input
tolistpath=$limitdir
post_process_dir

if [ ! -z $2 ]
then
    if [[ $2 != "combined" ]] && [[ $2 != "joined" ]]
    then
        print "Error 2nd arguement is no good"
        exit
    else
        method=$2
    fi
else
    method="combined"
fi

for tdir in $prepdirs
do
    echo "CLEANING: ${tdir}"

    #Remove the post processed files
    eval "rm -f ${tdir}/*joined.Rdata"
    eval "rm -rf ${tdir}/joined/"

    if [[ $method == "combined" ]]
    then
        eval "rm -rf ${tdir}/*combined.Rdata"
        eval "rm -rf ${tdir}/graphs/"
    fi

    #Move original data back to base directory
    eval "mv ${tdir}/med/*med.Rdata" "${tdir}/."
    eval "mv ${tdir}/icd/*icd.Rdata" "${tdir}/."
    eval "mv ${tdir}/lab/*lab.Rdata" "${tdir}/."
done

