# LIMIT: Chemistry Reference Range Algorithm

## OVERVIEW
This application was original developed by Dr. Schoreder and Dr. Poole at Standford university. The LIMIT algorithm is an unsupervised learning algorithm to determine reference ranges for laboratory values. The description of the algorithm can be viewed at the following citation:

Poole, Sarah, Lee Frederick Schroeder, and Nigam Shah. "An unsupervised learning method to identify reference intervals from a clinical database." Journal of biomedical informatics 59 (2016): 276-284. 
## FILES
* list_jobs.sh: is a bash script to list all the jobs currently running on the account and also the onces being run by the user.

* output_dir.sh: is a bash script to list the jobs on the current account and then also the jobs submitted by the current user.

* clean_dir.sh: is a bash script to clean up all the output files from the portable batch system.

* LIMIT_DB.pptx: powerpoint file of the relationships of the data for input into the LIMIT algorithm.

* SarahPoole_LIMIT.R/SarachPoole_sodium.R: Original software algorithm written by Dr. Poole.

* Nate_LIMIT.R: Nathan's updated version of the LIMITS algorithm

* Nate_LIMIT.pbs: This is a batch script that wraps the R algorithm (Nate_LIMIT.R) for submission to the PBS system. Can also be run locally.
    * CMD LINE ARGUMENTS: requires an -i/--input with a path to a R variable that can be read using the command load() in R. Has an optional -o/--output arguement which can specify an output directory for writing the results.
    * Submit to PBS: Can use squb command to submit this script to the scheduler. ex: qsub Nate_LIMIT.pbs -F "--input /home/username/data.Rdata". The -F flag allows a command line argument to be passed to the scheduler when it runs the command.

* get_random_data.R: An algorithm for creating a bimodal dataset and enriching an outlier population of labvalues with a restricted set of Icd codes to test the algorithm.
    * CMD LINE ARGUMENTS: Has an optional -o/--output arguement which can specify an output directory for writing the results. 
    * Submit to PBS: Can use squb command to submit this script to the scheduler. ex: qsub gen_randome_data.pbs -F "--ouput /home/username/rand_data". The -F flag allows a command line argument to be passed to the scheduler when it runs the command.
