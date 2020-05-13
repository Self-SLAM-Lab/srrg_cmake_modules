#!/usr/bin/python3
import json
import argparse
import sys

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


parser = argparse.ArgumentParser(description='''
    Read rmse from file and evalue if benchmark passed or not. 
    ''')
parser.add_argument('file', help='json result file from evo-suite')
parser.add_argument('--threshold', help='threshold for benchmark passed',default=0.5)

args = parser.parse_args()

filename = args.file;
threshold = args.threshold;

print("Reading file " + bcolors.OKBLUE + filename +  bcolors.ENDC)
print("Threshold is set to " + bcolors.OKBLUE + threshold +  bcolors.ENDC)

with open(filename, 'r') as f:
  results = json.load(f)
  rmse = results['rmse']
  print("RMSE value: "+ bcolors.WARNING+ bcolors.UNDERLINE + str(rmse) +  bcolors.ENDC)
  if (float(rmse) > float(threshold)): 
    print("RMSE above the threshold, benchmark "+ bcolors.FAIL +"NOT passed"+  bcolors.ENDC);
    sys.exit(-1)
  else:
    print("RMSE below the threshold, benchmark "+ bcolors.OKGREEN +"PASSED"+  bcolors.ENDC);
    sys.exit(0)


