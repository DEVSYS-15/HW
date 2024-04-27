#!/bin/bash
set -e 
input=$1
if [[ "$input" =~ ^[+-]?[0-9]+$ ]]; then
    let output=$input+1
    echo $output
else
    echo $input is not int
fi

