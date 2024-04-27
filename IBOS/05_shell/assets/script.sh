#!/bin/bash
set -e
if  [ ${#@} -gt 2 ]; then
    exit 1
elif [[ "$1" == "decrypt" ]]; then
    echo 'Decrypting...'
    echo "$2" | base64  --decode
    exit 0 
elif [[ "$1" == "crypt" ]]; then 
    echo 'Encrypting...'
    echo "$2" | base64
    exit 0
else 
    exit 1
fi


 