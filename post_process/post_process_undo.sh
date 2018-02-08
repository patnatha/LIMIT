source ../basedir.sh
tolistpath=$1
post_process_dir
for tdir in $prepdirs
do
    echo "CLEANING: ${tdir}"

    #Remove the post processed files
    eval "rm -f ${tdir}/*joined.Rdata"
    eval "rm -rf ${tdir}/joined/"
    eval "rm -rf ${tdir}/*combined.Rdata"
    eval "rm -rf ${tdir}/graphs/"

    #Move original data back to base directory
    eval "mv ${tdir}/med/*med.Rdata" "${tdir}/."
    eval "mv ${tdir}/icd/*icd.Rdata" "${tdir}/."
    eval "mv ${tdir}/lab/*lab.Rdata" "${tdir}/."
done

