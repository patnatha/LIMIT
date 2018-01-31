tolistpath=$1

eval "mv ${tolistpath}/med/*med.Rdata" "${tolistpath}."
eval "mv ${tolistpath}/icd/*icd.Rdata" "${tolistpath}."
eval "mv ${tolistpath}/lab/*lab.Rdata" "${tolistpath}."
eval "rm ${tolistpath}/*joined.Rdata"

