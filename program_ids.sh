qstat | grep `whoami` | awk '{print $1}' | cut -d '.' -f1
