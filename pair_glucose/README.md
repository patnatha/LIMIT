# Paired Glucose Analysis

## OVERVIEW
This sub category is dedicated to preparing glucose lab values for analaysis in the LIMIT algorithm. The pupose of these scripts to to pair POC glucose values with a temporally related central lab glucose value. This is the for the quality control on the POC devices and to check their accuracy. This is particulalry important in patients that are on the inpatient wards and even more for the patients in the ICU. The POC glucose meters are not validated in ICU patients, but they are widely used for blood glucose management.

## FILES
* glucose_paths.R: This is the file that holds the static path variables for processing the data in the pairing pipeline.

* pair_glucose_values.R/pbs: These are the scripts and batch commands that load up the raw glucose data. Then sort the values on collection date and iterate through all the values. It attempts to pair a central lab glucose to a POC glucose value that are within a resonable time frame of each other. This result is then enetered into a new table as a single lab value.
    * No command line arguments are necessary, but does require updating the glucose_paths.R file for different input.

* prepare_paired_glucoses.R/pbs: These are the scripts and batch commands that load up the paired glucose data and prepare it for being run in the LIMIT algorithm. Calculates the difference in values of the two glucose values and then also calculates the timeOffset from birth for the LIMIT algorithm. It also prepares the ICD codes and Medications that were administered.
    * No command line arguments are necessary, but does require updating the glucose_paths.R file for different input.

* analyze_paired_glucoses.R: This is the script for doing some simple analysis on the paired glucose values.
    * No command line arguments are necessary, but does require updating the glucose_paths.R file for different input.

* validate_lab_values.py: This is the script to run through the raw downloaded data files to check their quality.
    * Run it with the --input flag and --name for the output
