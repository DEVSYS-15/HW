#!/bin/env python3
import sys
import os 
try:
    inputDIR=sys.argv[1]
    
except IndexError:
    print('input is empty')
try:
    count=0
    for i in os.listdir(inputDIR):
        print(i)
        if os.path.isfile(os.path.join(inputDIR, i)):
            count=count+1
    print(f"Total: {count}")
except OSError:
    print("No such file or directory")
