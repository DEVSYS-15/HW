#!/bin/env python
import sys
try:
    inputSTR=sys.argv[1]
    print(int(inputSTR)+1)
except IndexError:
    print('input is empty')
except ValueError:
    print('input is not int')


