#!/bin/sh
set -e

# Could probably chain $HOME_DIR here but meh.
CERT_DIR=/home/overseer/Appdata/WebServer-Data/certificates/acme-v02.api.letsencrypt.org-directory/wildcard_.rubberverse.xyz
STOR_DIR=/home/overseer/Certificates
HOME_DIR=/home/overseer

# Eventually change this into array
systemctl -M overseer@ --user stop mumble.service
systemctl -M overseer@ --user stop livekit.service

if [ ! -d "${STOR_DIR}" ]; then
    echo "Directory ${STOR_DIR} not found, creating it"
    mkdir -p "${STOR_DIR}"
fi

if [ -f "${STOR_DIR}/wildcard_.rubberverse.xyz.crt" ]; then
    echo "Purging old certificates"
    rm "${STOR_DIR}/wildcard_.rubberverse.xyz.crt" "${STOR_DIR}/wildcard_.rubberverse.xyz.key"
fi

cp "${CERT_DIR}/wildcard_.rubberverse.xyz.crt" "${CERT_DIR}/wildcard_.rubberverse.xyz.key" "${STOR_DIR}"
chown overseer:overseer "${STOR_DIR}/wildcard_.rubberverse.xyz.crt" "${STOR_DIR}/wildcard_.rubberverse.xyz.key"
# u=rwx,g=--,o=r-x (others need to read and execute it but not modify it)
chmod 705 "${STOR_DIR}/wildcard_.rubberverse.xyz.crt" "${STOR_DIR}/wildcard_.rubberverse.xyz.key"

systemctl -M overseer@ --user restart mumble.service
systemctl -M overseer@ --user restart livekit.service

exit 0
