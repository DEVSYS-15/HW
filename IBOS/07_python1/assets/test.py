#!/bin/env python3
import sys
import os 
try:
    inputDIR=sys.argv[1]
except IndexError:
    print('input is empty')

if os.path.isfile(inputDIR):
    print(f"{inputDIR} - file")
    exit(0) 
if os.path.isdir(inputDIR):
    print(f"{inputDIR} - dir ")
    exit(0)
else:
    print(f"{inputDIR} - not exist")    
