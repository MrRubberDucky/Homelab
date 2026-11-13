#!/bin/bash
# v1.1
set -e

USER_HOME=/home/overseer
APPDATA="${USER_HOME}/Appdata/WebServer-Data/certificates"
STORAGE="${USER_HOME}/Certificates"
SERVICES="mediamtx"
read -ra SERVICES_ARRAY <<< "${SERVICES}"

CERT_NAME="rubberverse.xyz"
CERT="${APPDATA}/acme-v02.api.letsencrypt.org-directory/wildcard_.${CERT_NAME}"

for SERVICE in "${SERVICES_ARRAY[@]}"
do
    systemctl -M overseer@ --user stop "${SERVICE}".service
done

[[ ! -d "${STORAGE}" ]] && mkdir -p "${STORAGE}"
[[ -f "${STORAGE}/wildcard_.${CERT_NAME}.crt" ]] && rm "${STORAGE}/wildcard_.${CERT_NAME}.crt" "${STORAGE}/wildcard_.${CERT_NAME}.key"

cp "${CERT}/wildcard_.${CERT_NAME}.crt" "${CERT}/wildcard_.${CERT_NAME}.key" "${STORAGE}"

chown overseer:overseer "${STORAGE}" "${STORAGE}/wildcard_.${CERT_NAME}.crt" "${STORAGE}/wildcard_.${CERT_NAME}.key"
chmod 705 "${STORAGE}/wildcard_.${CERT_NAME}.crt" "${STORAGE}/wildcard_.${CERT_NAME}.key"

for SERVICE in "${SERVICES_ARRAY[@]}"
do
    systemctl -M overseer@ --user stop "${SERVICE}".service
done

exit 0
