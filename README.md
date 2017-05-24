# LIMIT: Chemistry Reference Range Algorithm

## OVERVIEW
This application was original developed by Dr. Schoreder and Dr. Poole at Standford university. The LIMIT algorithm is an unsupervised learning algorithm to determine reference ranges for laboratory values. The description of the algorithm can be viewed at the following citation:

## FILES
* list_jobs.sh: is a bash script to list all the jobs currently running on the scheduler for the account specified in the file and also the ones being run by the user.

* clean_dir.sh: is a bash script to clean up all the output files from the portable batch system.

* import_csv.R: This is an R script that loads up a function 'import_csv([input_dir])' that takes an argument of a path to a driectory. It returns an object indexable using '$' of tables.

* prepare_data.R: This is an R script that uses command line arguments to morph csv data into R objects which can be loaded into the limit scripts. 
    * CMD ARGS
        * input: path to directory of csv files to load
        * output: path to directory of where to write the output
        * name: identify this run, which will name the file this name

## DIRECTORIES
* pair_glucose: This is the directory that contains the scripts required for pairing glucose values and then preparing them for analysis in the LIMIT algorithm

* create_data: This is the directory that contains data creation algorithms for testing the validity of the LIMIT algorithm.

* limit_algorithm: This is the directory that contains the scripts for running the LIMIT algorithm on a prepared dataset.

* legacy_code: This is the directory that contains the original LIMIT algorithm.

