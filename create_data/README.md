# Creating Random Data

## OVERVIEW
This directory contains the scripts for generating random data for testing the algorithm. The scripts create two distributions of data and then enriches the outliers with a subset of codes. This enrichment is the group of codes that the LIMIT algorithm should identify.

## FILES
* get_random_data.R: An algorithm for creating a bimodal dataset and enriching an outlier population of lab values with a restricted set of Icd codes to test the algorithm.

* get_random_data.pbs: This is a batch script that wraps the R algorithm (gen_randome_data.R) for submission to the PBS system. Can also be run locally..
    * CMD LINE ARGUMENTS: Has an optional -o/--output arguement which can specify an output directory for writing the results.
    * Submit to PBS: Can use qsub command to submit this script to the scheduler. ex: qsub gen_randome_data.pbs -F "--output /home/username/rand_data". The -F flag allows a command line argument to be passed to the scheduler.
