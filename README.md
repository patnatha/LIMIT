# LIMIT: Chemistry Reference Range Algorithm

## OVERVIEW
This application was original developed by Dr. Schoreder and Dr. Poole at Standford university. The LIMIT algorithm is an unsupervised learning algorithm to determine reference ranges for laboratory values. The description of the algorithm can be viewed at the following citation:

## FILES
* list_jobs.sh: is a bash script to list all the jobs currently running on the scheduler for the account specified in the file and also the ones being run by the user.

* clean_dir.sh: is a bash script to clean up all the output files from the portable batch system.

* import_csv.R: This is an R script that loads up a function 'import_csv([input_dir])' that takes an argument of a path to a directory. It returns an object indexable using '$' of tables.

## DIRECTORIES
* pair_glucose: This is the directory that contains the scripts required for pairing glucose values and then preparing them for analysis in the LIMIT algorithm

* create_data: This is the directory that contains data creation algorithms for testing the validity of the LIMIT algorithm.

* limit_algorithm: This is the directory that contains the scripts for running the LIMIT algorithm on a prepared dataset.

* legacy_code: This is the directory that contains the original LIMIT algorithm.

* prepare_data: This is the directory that contains the scripts for loading text files dumped from SQL queries and prepares it for munching on by the LIMIT algorithm.

