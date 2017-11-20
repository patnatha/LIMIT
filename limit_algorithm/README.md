# LIMIT Algorithm

## OVERVIEW
This is the script that is an implimentation of the LIMIT algorithm. This is the version updated by Nathan Patel. It is designed to be a script that is useable from the command line.

## FILES
* Nate_LIMIT.R: Nathan's updated version of the LIMITS algorithm

* Nate_LIMIT.pbs: This is a batch script that wraps the R algorithm (Nate_LIMIT.R) for submission to the PBS system. Can also be run locally.
    * CMD LINE ARGUMENTS: requires an -i/--input with a path to a R variable that can be read using the command load() in R. Has an optional -o/--output arguement which can specify an output directory for writing the results.
    * Submit to PBS: Can use qsub command to submit this script to the scheduler. ex: qsub Nate_LIMIT.pbs -F "--input /home/username/data.Rdata". The -F flag allows a command line argument to be passed to the scheduler.

