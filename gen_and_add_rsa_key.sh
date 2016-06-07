#!/bin/bash
##
## Script that generates a rsa keypair without password, adds it to remote host authorized keys and local ssh confifuration
## Usage: gen_and_add_rsa_key.sh <username> <hostname>
##
SCRIPTS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_NAME=`basename "$0"`

USERNAME=$1
HOSTNAME=$2

if [ -z "$USERNAME" ] || [ -z "$HOSTNAME" ]; then
        echo
        echo "Usage ${SCRIPT_NAME} <username> <hostname>"
        echo
        exit 1
fi


KEY_FILE="${SCRIPTS_DIR}/${HOSTNAME}_rsa"

ssh-keygen -t rsa -f "${KEY_FILE}" -N ""
ssh-copy-id -i "${KEY_FILE}" ${USERNAME}@${HOSTNAME}

cat <<EOF >> ~/.ssh/config
Host ${HOSTNAME}
  HostName ${HOSTNAME}
  User ${USERNAME}
  IdentityFile ${KEY_FILE}
EOF
