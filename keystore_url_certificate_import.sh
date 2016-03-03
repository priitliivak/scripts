#!/bin/bash
# Author: Priit Liivak
# Imports certificate from URL into Java keystore.
# Warning: This script does not verify the certificate in any way beforehand. Not recommended to use in production environments

SCRIPTFILE_NAME=`basename "$0"`

# Prints usage help
usage() {
        echo "\n\nThis script is used to import certificate into a Java keystore from https url"
        echo "Usage: sh $SCRIPTFILE_NAME --host <hostname without protocol>"
}

# Default
PORT=443
KEYSTORE_PASS=changeit

while [ $# -gt 0 ]; do
        case $1
        in
                --host)
                        HOSTNAME=$2
                        shift 2
        ;;
                --port)
                        PORT=$2
                        shift 2
        ;;
        
                --javahome)
                        JAVA_HOME=$2
                        shift 2
        ;;
                -h | --help)
                        usage
                        exit 0
        ;;
                *)
                        echo "${scriptname}: Unknown option $1, exiting" 1>&2
                        usage
                        exit 1
        ;;
        esac
done

echo "Java Home is: $JAVA_HOME"
echo "Importing cert from $HOSTNAME"

KEYTOOL=${JAVA_HOME}/bin/keytool

# Assume JAVA_HOME points to JRE
KEYSTORE=${JAVA_HOME}/lib/security/cacerts

if [ ! -f "${KEYSTORE}" ]; then
    # Check if JAVA_HOME points to JDK
    KEYSTORE=${JAVA_HOME}/jre/lib/security/cacerts
    
    if [ ! -f "${KEYSTORE}" ]; then
        # Invalid JAVA_HOME
        echo "\nCould not find cacerts using JAVA_HOME=${JAVA_HOME}"
        echo "Tried:\n\t${JAVA_HOME}/lib/security/cacerts\n\t${JAVA_HOME}/jre/lib/security/cacerts"
        exit 1
    fi
fi

CERTFILE="${HOSTNAME}"_cert.pem

# Sanity checks
[ -z ${CERTFILE} ] && echo "CERTFILE variable is mandatory" && exit 1
[ -z ${PORT} ] && echo "PORT variable is mandatory" && exit 1
[ -z ${HOSTNAME} ] && echo "HOSTNAME variable is mandatory" && exit 1
[ -z ${KEYTOOL} ] && echo "KEYTOOL variable is mandatory" && exit 1

# Get cert
echo | openssl s_client -connect ${HOSTNAME}:${PORT} 2>&1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${CERTFILE}

# Trust cert
${KEYTOOL} -delete -noprompt -alias ${HOSTNAME} -keystore ${KEYSTORE} -storepass ${KEYSTORE_PASS}
${KEYTOOL} -import -alias ${HOSTNAME} -keystore ${KEYSTORE} -file ${CERTFILE} -trustcacerts -noprompt -storepass ${KEYSTORE_PASS}
