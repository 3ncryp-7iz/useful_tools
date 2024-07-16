#!/bin/bash

# Check if two arguments are given
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 file1 file2"
    exit 1
fi

# Assign input arguments to variables
file1=$1
file2=$2

# Check if the files exist
if [ ! -f "$file1" ] || [ ! -f "$file2" ]; then
    echo "Both files must exist."
    exit 1
fi

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m'

# Compare files
diff -u "$file1" "$file2" | while read -r line
do
    # Color added lines in green and deleted lines in red
    if [[ $line == '+'* && $line != '++'* ]]; then
        echo -e "${GREEN}Added in $file2: ${line}${NO_COLOR}"
    elif [[ $line == '-'* && $line != '--'* ]]; then
        echo -e "${RED}Deleted from $file1: ${line}${NO_COLOR}"
    else
        echo "$line"
    fi
done
