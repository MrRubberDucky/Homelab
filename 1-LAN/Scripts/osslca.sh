#!/bin/sh
# [O]pen[SSL][C]ertificate[A]uthority v1.0
# Semi-automatic manner of generating OpenSSL Certificate Authority and Certificates
#
# Credits: Used Bing Copilot to make me an reference bash script and used it as a base (it didn't even work btw), My own free will, and StackOverflow.
# Here in case anyone ever wants something like this...

# Runtine ENVs + aliases
DIR="${HOME}/OSSLCA"

# Functions, user cert with SAN
create_user_cert() {
    NAME=$1
    PKEY="${DIR}/PrivateKeys/${NAME}.key"
    PCSR="${DIR}/CSR/${NAME}.csr"
    PCRT="${DIR}/Certs/${NAME}.crt"
    PALT="${DIR}/${NAME}_alt.cnf"

    if [ -z "${NAME}" ]; then
        echo "Usage: $0 <name>"
        exit 1
    fi

    echo "[OSSLCA] Generating private key for ${NAME}...\n"
    openssl genpkey -algorithm RSA -out "$PKEY" -aes256 -pkeyopt rsa_keygen_bits:2048
    echo "[OSSLCA] Generating Cerificate Signing Request for ${NAME}...\n"
    openssl req -new -key "${PKEY}" -config "${DIR}/OSSLCA.cnf" -out "${PCSR}"

    if [ ! -f ${DIR}/${NAME}_alt.cnf ]; then
        echo "[OSSLCA] Creating temporary configuration file..."
        touch "${DIR}/${NAME}_alt.cnf"
    else
        echo "[?] The configuration file already exists, re-creating it..."
        rm "${DIR}/${NAME}_alt.cnf"
        touch "${DIR}/${NAME}_alt.cnf"
    fi

    echo "[OSSLCA] Appending [ usr_cert ] to ${PALT}..."
    cat <<EOF > "${DIR}/${NAME}_alt.cnf"
[ usr_cert ]
basicConstraints        = CA:FALSE
nsComment               = "Rubberverse Internal Certificate"
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid,issuer
EOF
    echo "[OSSLCA] Enter comma-seperated SANs (e.g., example.com,www.example.com): "
    read SAN_INPUT

    if [ -z "$SAN_INPUT" ]; then
        echo "[OSSLCA] No SAN input provided, using default: DNS:localhost"
        SAN_INPUT="DNS:localhost"
    fi

    echo "[ alt_names ]" >> "${PALT}"
    IFS=',' read -ra SAN_ARRAY <<< "${SAN_INPUT}"
    INDEX=1
    for SAN in "${SAN_ARRAY[@]}"; do
        echo "DNS.$INDEX = $SAN" >> "$PALT"
        INDEX=$((INDEX+1))
    done

    echo "[OSSLCA] Provided SANs: ${SAN_INPUT}"

    echo "[OSSLCA] Signing user certificate with extra SANs..."
    openssl ca -config "${DIR}/OSSLCA.cnf" -in "${PCSR}" -out "${PCRT}" -extensions usr_cert -extfile "${PALT}"

    echo "[OSSLCA] Showing file information..."
    stat "${DIR}/Certs/${NAME}.crt"
    stat "${DIR}/PrivateKeys/${NAME}.key"

    echo "[OSSLCA] If there were no errors, certificate for ${NAME} was generated successfully!"
    echo "[OSSLCA] Environment clean-up"
    unset SAN_INPUT DIR
    echo "[OSSLCA] Removing ${PALT}"
    rm "${PALT}"
    echo "[OSSLCA] My job is done, exiting!"
    exit 0
}

echo "[OSSLCAv1.0] Checking if directories exist"

if [ ! -d "${DIR}" ]; then
    echo "[1] Initializing Directory"
    mkdir -p "${DIR}/Certs" "${DIR}/NewCerts" "${DIR}/PrivateKeys" "${DIR}/CSR"
    touch "${DIR}/index.txt"
    touch "${DIR}/OSSLCA.cnf"
    echo 1000 > "${DIR}/serial"
    cat <<EOF > "${DIR}/OSSLCA.cnf"
[ ca ]
default_ca = CA_default
[ CA_default ]
dir                     = ${DIR}
certs                   = ${DIR}/Certs
new_certs_dir           = ${DIR}/NewCerts
certificate             = ${DIR}/Certs/ca.crt
private_key             = ${DIR}/PrivateKeys/ca.key
database                = ${DIR}/index.txt
serial                  = ${DIR}/serial
x509_extensions         = v3_ca
default_days            = 50000
default_crl_days        = 50000
default_md              = sha512
policy                  = policy_match
[ policy_match ]
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
[ req ]
default_bits            = 4096
default_md              = sha512
default_keyfile         = ${DIR}/PrivateKeys/ca.key
distinguished_name      = req_distinguished_name
attributes              = req_attributes
x509_extensions         = v3_ca
req_extensions          = v3_req
string_mask             = utf8only
prompt                  = no
[ req_distinguished_name ]
C                       = PL
ST                      = Redacted
L                       = Redacted
O                       = Rubberverse
OU                      = Rubberverse
CN                      = certify.localhost.rubberverse.internal
[ req_attributes ]
[ usr_cert ]
basicConstraints        = CA:FALSE
nsComment               = "Rubberverse Internal Certificate"
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid,issuer
[ v3_ca ]
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always,issuer
basicConstraints        = CA:true
keyUsage                = keyCertSign, cRLSign
certificatePolicies     = 2.5.29.32.0
[ v3_req ]
subjectAltName          = DNS:localhost
EOF
    echo "Directory initialized!"
else
    echo "[2] Directory exists!"
    echo "[2] In order to re-create, run following command: rm -rf ${HOME}/OSSLCA"
fi

if [ ! -f "${DIR}/PrivateKeys/ca.key" ]; then
    echo "[1] CA Private Key is missing!"
    echo "[1] Generating Certificate Authority private key..."
    openssl genpkey -algorithm RSA -out "${DIR}/PrivateKeys/ca.key" -aes256 -pkeyopt rsa_keygen_bits:4096
fi

if [ ! -f "${DIR}/Certs/ca.crt" ]; then
    echo "[1] CA Certificate missing!"
    echo "[1] Generating Certificate Authority certificate..."
    openssl req -new -x509 -days 50000 -key "${DIR}/PrivateKeys/ca.key" -config "${DIR}/OSSLCA.cnf" -out "${DIR}/Certs/ca.crt"
fi

if [ "$1" ]; then
    create_user_cert "$1"
else
    echo "CA setup complete! In order to generate user certificates, run:"
    echo "./osslca.sh <name>"
    unset DIR
fi
