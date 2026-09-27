#!/bin/bash
set -e

SHP1="${HOME}/.config/containers/systemd/Templates/symlinks"
SHP2="${HOME}/.config/containers/systemd/Templates/overrides"
SHP3="${HOME}/.config/containers/systemd/Templates"

if [ ! -d "${SHP2}" ]; then
    mkdir -p "${SHP2}"
fi
if [ ! -d "${SHP1}" ]; then
    mkdir -p "${SHP1}"
fi

if [ "${CUSTOM:-}" ]; then
    # Generate overrides and blank files for each
    read -ra SERVICES_ARRAY <<< "${CUSTOM}"
    for service in "${SERVICES_ARRAY[@]}"
    do
        [ ! -d "${SHP2}/template@${service}.container.d" ] && mkdir -p "${SHP2}/template@${service}.container.d"
        [ ! -f "${SHP2}/template@${service}.container.d/10-override.conf" ] && touch "${SHP2}/template@${service}.container.d/10-override.conf"
    done
    # Generate symlinks
    for symlink in "${SERVICES_ARRAY[@]}"
    do
        [ ! -L "${SHP1}/template@${symlink}.container" ] && ln -s "${SHP3}/template@.container" "${SHP1}/template@${symlink}.container"
    done
else
    SERVICES='beszel beszel-agent socket-proxy caddy itchclaim mediajournal it-tools navidrome pykms sillytavern tinyauth tududi syncthing voidauth vaultwarden'
    read -ra SERVICES_ARRAY <<< "${SERVICES}"
    for service in "${SERVICES_ARRAY[@]}"
    do
        [ ! -d "${SHP2}/template@${service}.container.d" ] && mkdir -p "${SHP2}/template@${service}.container.d"
        [ ! -f "${SHP2}/template@${service}.container.d/10-override.conf" ] && touch "${SHP2}/template@${service}.container.d/10-override.conf"
    done
    for symlink in "${SERVICES_ARRAY[@]}"
    do
        [ ! -L "${SHP1}/template@${symlink}.container" ] && ln -s "${SHP3}/template@.container" "${SHP1}/template@${symlink}.container"
    done
fi

unset SHP1 SHP2 SHP3 symlink service CUSTOM SERVICES_ARRAY SERVICES
systemctl --user daemon-reload
