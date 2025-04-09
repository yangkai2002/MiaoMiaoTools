#!/bin/bash
# ==============================================================================
# Script Description:
#
#   This script is used to batch copy three critical system files (/etc/passwd,
#   /etc/shadow, and /etc/group) from the local machine to multiple remote hosts.
#   The target files are copied to the /etc/ directory on the remote hosts.
#   The target host names are constructed by combining a common prefix (COMMON_PREFIX)
#   with a sequence of numbers within the specified range (BEG to END).
#
# Usage:
#   ./script.sh COMMON_PREFIX BEG END
#   Example: ./script.sh node- 01 05  
#            This will copy the files to hosts "node-01", "node-02", ... "node-05".
#
# Warnings and Limitations:
#
#   1. Security Risks:
#      - The /etc/shadow file contains sensitive password hash information.
#      - Copying these files may pose security risks. Ensure that the network
#        connection is secure and that remote hosts have proper access controls
#        and encrypted communication channels in place.
#
#   2. Permissions:
#      - The user running this script must have read permissions for
#        /etc/passwd, /etc/shadow, and /etc/group, as well as write permissions
#        to the /etc/ directory on the target remote hosts.
#
#   3. Potential Impact:
#      - Overwriting system files on the target hosts may affect system security
#        and stability. Verify the purpose of the target hosts and ensure they
#        are properly backed up before executing this script.
#
#   4. Testing:
#      - It is highly recommended to test this script in a controlled environment
#        before using it in production. Verify that the parameters and paths are
#        configured correctly.
#
#   5. Network Status:
#      - Ensure that the target hosts are reachable over the network; otherwise,
#        scp will fail due to connection issues.
#
# ==============================================================================
COMMON_PREFIX=$1
BEG=$2
END=$3

# Parameter Check: Ensure three parameters are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 COMMON_PREFIX BEG END"
    echo "Example: $0 node- 01 05"
    exit 1
fi

SLAVES=$(seq $BEG $END)
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

