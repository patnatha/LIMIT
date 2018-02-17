if [ -z $1 ]
then
    qstat | grep `whoami` | grep "Q\|R" | awk '{print $1}' | cut -d '.' -f1
else
    qstat | grep `whoami` | grep "Q\|R" | grep $1 | awk '{print $1}' | cut -d '.' -f1
fi

