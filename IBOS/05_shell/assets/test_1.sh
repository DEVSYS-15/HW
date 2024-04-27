#!/bin/bash
set -e 
input=$1
if [ "$input" ]; then
    output="${input}1"
    echo $output
else
    echo $input is empty
fi
