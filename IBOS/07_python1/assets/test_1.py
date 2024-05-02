#!/bin/env python
import sys
try:
    inputSTR=sys.argv[1]
    print(inputSTR+str(1))
except IndexError:
    print('input is empty')
