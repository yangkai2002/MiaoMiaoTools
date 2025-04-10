#!/bin/bash

usage() {
    echo "Usage: $0 USER_NAME" >&2
    echo "Example: $0 username" >&2
    exit 1
}

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Ensure USER_NAME is provided as an argument
[ -n "$1" ] || usage
USER_NAME="$1"

# Verify the user exists and is not already in the sudo group
id "$USER_NAME" &>/dev/null || error_exit "User $USER_NAME does not exist."
id -nG "$USER_NAME" | grep -qw "sudo" && error_exit "User $USER_NAME is already in the sudo group."

# Add the user to the sudo group
usermod -aG sudo "$USER_NAME" || error_exit "Failed to add user $USER_NAME to the sudo group."
echo "User $USER_NAME has been added to the sudo group."
