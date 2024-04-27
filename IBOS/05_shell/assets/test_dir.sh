#!/bin/bash
set -e 
read -p "Type a directory or press anter to PWD:  " input
count=0
function listdir {
if [[ -d "$dir_name" ]]; then
    for i in $(ls -1 $dir_name); do
        echo $i
        if [[ -f "$dir_name/$i" ]]; then
          let count=$count+1
        fi
    done 
    echo -e Total:$count

else
    echo -e "$input" No such file or directory or enter full path
fi

}
if [ "$input" ]; then 
    dir_name="$input"
    listdir
else
    dir_name=$(pwd)
    listdir
fi