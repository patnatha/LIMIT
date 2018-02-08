echo "========================Account Jobs========================"
showq -w acct=leeschro_armis

echo "=========================User Jobs=========================="
qstat -u `whoami` | awk '$10 == "Q" {print $0} $10 == "R" {print $0}'
