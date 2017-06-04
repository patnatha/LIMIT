import argparse
import sys
import os

parser = argparse.ArgumentParser(description='Process some input.')
parser.add_argument('--input', metavar='i',
                    help='input file path')
parser.add_argument('--name', metavar='n', help="output file name")
args = parser.parse_args()

inputFilePath = args.input
if(not os.path.isfile(inputFilePath)):
    print "--input is not a valid file"

outputFilePath = os.path.join(os.path.dirname(inputFilePath), args.name)

theInFP = inputFilePath
theOutFP = outputFilePath
fout = open(theOutFP, 'w')
f = open(theInFP)

colCnt = None
totalRow = 0
goodRow = 0
badRow = 0
for index, line in enumerate(f):
    if(index == 0):
        colCnt = len(line.split('\t'))
        fout.write(line)
    else:
        if(colCnt != len(line.split('\t'))):
            badRow += 1
        else:
            goodRow += 1
            fout.write(line)

        totalRow += 1

    if(index % 10000 == 0):
        print index

f.close()
fout.close()

print 'BAD:', badRow, '/', totalRow, '=', (badRow/float(totalRow)) * 100.0
print 'GOOD:', goodRow, '/', totalRow, '=', (goodRow/float(totalRow)) * 100.0

