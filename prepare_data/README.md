# Prepare Data

## OVERVIEW
This directory contains the scripts for preparing the data for LIMIT algorithm. The scripts calculate fields as necessary and then saves an R object which can be loaded into the algorithm.

## FILES
* prepare_data.R: This is an R script that uses command line arguments to morph csv data into R objects which can be loaded into the limit scripts.
    * CMD ARGS
        * input: path to directory of csv files to load
        * output: path to directory of where to write the output
        * name: identify this run, which will name the file this name

