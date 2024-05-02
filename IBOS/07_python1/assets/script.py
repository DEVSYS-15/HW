#!/bin/env python3
import base64
import sys 
try:
    inputPARAM=sys.argv[1:]

except IndexError:
    exit(1)
if len(inputPARAM) > 2:
    exit(1) 
if inputPARAM[0] == "crypt":
    text_bytes = base64.b64encode(inputPARAM[1].encode('ascii'))
    print('Encrypting...')
    print (text_bytes.decode('ascii'))
    exit(0)
if inputPARAM[0] == "decrypt":
    text_bytes = base64.b64decode(inputPARAM[1])
    print('Decrypting....') 
    print (text_bytes.decode('ascii'))
    exit(0)
else:
    exit(1)

 