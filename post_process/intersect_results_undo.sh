tolistpath=$1

#Remove the post processed files
eval "rm ${tolistpath}/*joined.Rdata"
eval "rm -rf ${tolistpath}/joined/"
eval "rm -rf ${tolistpath}*combined.Rdata"
eval "rm -rf ${tolistpath}graphs/"

#Move original data back to base directory
eval "mv ${tolistpath}/med/*med.Rdata" "${tolistpath}."
eval "mv ${tolistpath}/icd/*icd.Rdata" "${tolistpath}."
eval "mv ${tolistpath}/lab/*lab.Rdata" "${tolistpath}."
