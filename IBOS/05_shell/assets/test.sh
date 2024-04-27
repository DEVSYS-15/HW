#!/bin/bash
set -e
if  [ -d "${1}" ]; then
    echo -e "${1}" - directory
elif [[ -f "${1}" ]]; then
    echo -e "${1}" - File
else 
    echo -e "${1}"  - not exist
fi


 