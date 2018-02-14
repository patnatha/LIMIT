qstat | grep `whoami` | grep "Q\|R" | awk '{print $1}' | cut -d '.' -f1
