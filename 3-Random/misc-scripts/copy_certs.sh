#!/bin/bash
# v1.1.1
set -e
USER="overseer"
USER_HOME="/home/${USER}"
APPDATA="${USER_HOME}/Appdata/Fetcher-Data/certificates"
STORAGE="${USER_HOME}/Certificates"
SERVICES="mediamtx"
read -ra SERVICES_ARRAY <<< "${SERVICES}"

CERT_NAME="moq.rubberverse.xyz"
CERT="${APPDATA}/acme-v02.api.letsencrypt.org-directory/${CERT_NAME}"

for SERVICE in "${SERVICES_ARRAY[@]}"
do
    systemctl -M "${USER}"@ --user stop "${SERVICE}".service
done

[[ ! -d "${STORAGE}" ]] && mkdir -p "${STORAGE}"
[[ -f "${STORAGE}/${CERT_NAME}.crt" ]] && rm "${STORAGE}/${CERT_NAME}.crt" "${STORAGE}/${CERT_NAME}.key"

cp "${CERT}/${CERT_NAME}.crt" "${CERT}/${CERT_NAME}.key" "${STORAGE}"

chown "${USER}":"${USER}" "${STORAGE}" "${STORAGE}/${CERT_NAME}.crt" "${STORAGE}/${CERT_NAME}.key"
chmod 705 "${STORAGE}/${CERT_NAME}.crt" "${STORAGE}/${CERT_NAME}.key"

for SERVICE in "${SERVICES_ARRAY[@]}"
do
    systemctl -M "${USER}"@ --user stop "${SERVICE}".service
done

exit 0
