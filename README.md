# LIMIT: Chemistry Reference Range Algorithm

## OVERVIEW
This application was original developed by Dr. Schoreder and Dr. Poole at Standford university. The LIMIT algorithm is an unsupervised learning algorithm to determine reference ranges for laboratory values. The description of the algorithm can be viewed at the following citation:

Poole, Sarah, Lee Frederick Schroeder, and Nigam Shah. "An unsupervised learning method to identify reference intervals from a clinical database." Journal of biomedical informatics 59 (2016): 276-284. 
## FILES
* list_jobs.sh: is a bash script to list all the jobs currently running on the scheduler for the account specified in the file and also the ones being run by the user.

* output_dir.sh: is a bash script to code in the output directories for batch running..

* clean_dir.sh: is a bash script to clean up all the output files from the portable batch system.

* SarahPoole_LIMIT.R/SarachPoole_sodium.R: Original software algorithm written by Dr. Poole.

* Nate_LIMIT.R: Nathan's updated version of the LIMITS algorithm

* Nate_LIMIT.pbs: This is a batch script that wraps the R algorithm (Nate_LIMIT.R) for submission to the PBS system. Can also be run locally.
    * CMD LINE ARGUMENTS: requires an -i/--input with a path to a R variable that can be read using the command load() in R. Has an optional -o/--output arguement which can specify an output directory for writing the results.
    * Submit to PBS: Can use qsub command to submit this script to the scheduler. ex: qsub Nate_LIMIT.pbs -F "--input /home/username/data.Rdata". The -F flag allows a command line argument to be passed to the scheduler.

* get_random_data.R: An algorithm for creating a bimodal dataset and enriching an outlier population of lab values with a restricted set of Icd codes to test the algorithm.

* get_random_data.pbs: This is a batch script that wraps the R algorithm (gen_randome_data.R) for submission to the PBS system. Can also be run locally..
    * CMD LINE ARGUMENTS: Has an optional -o/--output arguement which can specify an output directory for writing the results. 
    * Submit to PBS: Can use qsub command to submit this script to the scheduler. ex: qsub gen_randome_data.pbs -F "--output /home/username/rand_data". The -F flag allows a command line argument to be passed to the scheduler.


