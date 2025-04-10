#!/bin/bash

WORK_DIR="$(dirname "$0")"

usage() {
    echo "Usage: $0 COMMON_PREFIX BEG END"
    echo "Example: $0 node- 01 05"
    exit 1
}

# Check parameters: Ensure three arguments are provided
if [ "$#" -ne 3 ]; then
    usage
fi

COMMON_PREFIX=$1
BEG=$2
END=$3

SLAVES=$(seq "$BEG" "$END")
for HOST in $SLAVES; do
    FULL_HOST="${COMMON_PREFIX}${HOST}"
    echo "Copying files to ${FULL_HOST} ..."
    scp /etc/passwd ${FULL_HOST}:/etc/
    scp /etc/shadow ${FULL_HOST}:/etc/
    scp /etc/group ${FULL_HOST}:/etc/
    if [ "$?" -ne 0 ]; then
        echo "Error occurred while copying files to ${FULL_HOST}. Please check network connectivity or permission settings."
    fi
done
