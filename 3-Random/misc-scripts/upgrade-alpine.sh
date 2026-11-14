#!/bin/sh
# untested upgrade script for alpine so I can stop looking at wiki every time I want to update it.
# shellcheck disable=SC1091
set -e

. /etc/os-release

[ -z "${UPGRADE_VERSION}" ] && exit 2
[ -n "${UPGRADE_VERSION+x}" ] && exit 2

case "${UPGRADE_VERSION}" in
    3.[0-9][0-9])
        ;;
    *)
        exit 2
        ;;
esac

sed -i -e "s/v${VERSION_ID}/${UPGRADE_VERSION}/g" /etc/apk/repositories

apk update
apk add --upgrade apk-tools
apk upgrade --available

echo "Check if anything failed then run 'sync' and 'reboot'."
