#!/bin/python
import sys
import re
import os
from pprint import pprint
from optparse import OptionParser

#Start up the option parser
parser = OptionParser()

parser.add_option("-o", "--output", type="string",
                  help="select directory to write output, this will create a combined directory",
                  dest="output_dir")

parser.add_option("-i", "--input", type="string",
                  help="a path to a directory full of  CSV files to combine",
                  dest="input_dir")

try:
    (args,options) = parser.parse_args()
except:
    parser.error("Invalid")
    sys.exit(0)

#Get the dir to list
THE_DIR = args.input_dir

#Get the list of files to combine
combined_dict = dict()
for root, dirs, files in os.walk(THE_DIR):
    for the_file in files:
        mods_file = re.sub(" \(part [1-9]+\)", "", the_file)
        if(mods_file not in combined_dict):
            combined_dict[mods_file] = list()
        combined_dict[mods_file].append(os.path.join(THE_DIR, the_file))

#Create output directory, delete if already exists
output_dir = os.path.join(args.output_dir, 'combined')
if(os.path.exists(output_dir)):
    print("Output directory already exists")
    sys.exit(1)
os.mkdir(output_dir)

#Order all the lists
for tkey in combined_dict:
    combined_dict[tkey].sort()

#Combine the files
for tkey in combined_dict:
    #Open the output file name
    output_filename = os.path.join(output_dir, tkey)
    fout = open(output_filename, 'w')
    
    #Iterate over all the file to combine for this base file
    for index, the_file in enumerate(combined_dict[tkey]):
        #Open the intput file
        f = open(the_file)

        print the_file
        #Enumerate all the line numbers
        for line_num, line in enumerate(f):
            if(index > 0 and line_num == 0):
                continue
            else:
                fout.write(line)    
        
        #Close the input file pointer
        f.close()

    #Close the output file pointer
    fout.close()
 
