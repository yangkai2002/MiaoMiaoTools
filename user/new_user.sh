#!/bin/bash

WORK_DIR="$(dirname "$0")"

usage() {
    cat <<EOF
Usage: $0 [-z ZPOOL_NAME] [-k [SKEL_DIR]] [-s] USER_NAME
  -z   Specify the zpool name for the user's home directory.
       A ZFS dataset will be created at: <ZPOOL_NAME>/home/<USER_NAME>.
  -k   Specify the skeleton directory for the new user.
       If -k is given without SKEL_DIR, the default /etc/skel is used.
  -s   Add sudo privileges for the user.
Example: $0 -z mypool -k /path/to/skel -s username
EOF
    exit 1
}

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Ensure USER_NAME is provided as the remaining argument
USER_NAME="$1"
[ -z "$USER_NAME" ] && usage

# Initialize flags and variables
SKEL_DIR="/etc/skel"
HOME_DIR="/home/${USER_NAME}"
ADD_SUDO=false

# Parse command line options
while getopts "z:k:s" opt; do
    case $opt in
        z)
            ZPOOL_NAME="$OPTARG"
            [ -z "$ZPOOL_NAME" ] && error_exit "ZPOOL_NAME must be provided with the -z option."
            
            # Check if the specified zpool exists using grep on zpool list output
            zpool list -H -o name | grep -q "^${ZPOOL_NAME}$" || error_exit "ZPOOL_NAME ${ZPOOL_NAME} does not exist."
            
            # Update home directory to use the zpool and create the ZFS dataset
            HOME_DIR="/${ZPOOL_NAME}${HOME_DIR}"
            echo "Creating ZFS dataset ${HOME_DIR}..."
            sudo zfs create "${HOME_DIR}" || error_exit "Failed to create ZFS dataset ${HOME_DIR}"
            ;;
        k)
            SKEL_DIR="$OPTARG"
            [ -z "$SKEL_DIR" ] && SKEL_DIR="/etc/skel"
            [ ! -d "$SKEL_DIR" ] && error_exit "Skeleton directory $SKEL_DIR does not exist."
            ;;
        s)
            ADD_SUDO=true
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND - 1))

# Create the user with the specified skeleton directory
echo "Creating user ${USER_NAME} with home directory: ${HOME_DIR}"
sudo useradd -m -d "${HOME_DIR}" -k "${SKEL_DIR}" -s /bin/bash "${USER_NAME}" || error_exit "Failed to create user ${USER_NAME}"

# Change the ownership of the home directory
sudo chown -R "${USER_NAME}:${USER_NAME}" "${HOME_DIR}" || error_exit "Failed to change ownership of ${HOME_DIR}"

# Add sudo privileges if requested, run add_sudo.sh script
if $ADD_SUDO; then
    echo "Warning: Adding sudo privileges for user ${USER_NAME}. Please verify your security policies." >&2
    # add_sudo.sh script should be in the same directory
    if [ -f "${WORK_DIR}/add_sudo.sh" ]; then
        sudo bash "${WORK_DIR}/add_sudo.sh" "${USER_NAME}"
    else
        error_exit "add_sudo.sh script not found in ${WORK_DIR}."
    fi
fi

echo "User ${USER_NAME} created successfully."