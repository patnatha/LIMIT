echo "========================Account Jobs========================"
showq -w acct=leeschro_armis

echo "=========================User Jobs=========================="
qstat -u `whoami`
