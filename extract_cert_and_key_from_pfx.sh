#!/bin/bash

SCRIPTS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
read -s -p "Certificate file password: " CERT_PASSWD

CERT_PACKAGE=$1
OUTPUT_NAME=$2

set -x
openssl pkcs12 -in ${CERT_PACKAGE} -nocerts -nodes -passin pass:${CERT_PASSWD} | openssl rsa -out ${OUTPUT_NAME}.key
openssl pkcs12 -in ${CERT_PACKAGE} -clcerts -nokeys -passin pass:${CERT_PASSWD}  | openssl x509 -out ${OUTPUT_NAME}.pem
