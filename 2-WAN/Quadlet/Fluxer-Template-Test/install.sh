#!/bin/bash
set -e
SHP2="${HOME}/.config/containers/systemd/Fluxer/overrides"

if [ ! -d "${SHP2}" ]; then
    mkdir -p "${SHP2}"
fi

echo "Checking directories and creating them"
for shard_type in gifs messages unfurl
do
    [ ! -d "${SHP2}/nats-shard@${shard_type}.container.d" ] && mkdir -p "${SHP2}/nats-shard@${shard_type}.container.d"
done
unset shard_type
for nats_type in gifs messages unfurl users
do
    [ ! -d "${SHP2}/nats@${nats_type}.container.d" ] && mkdir -p "${SHP2}/nats@${nats_type}.container.d"
done
unset nats_type
for databases in postgres valkey meilisearch
do
    [ ! -d "${SHP2}/database@${databases}.container.d" ] && mkdir -p "${SHP2}/database@${databases}.container.d"
done
unset databases


if [ ! -f "${SHP2}/nats-shard@gifs.container.d/10-override.conf" ]; then
echo "Creating systemd override for nats-shard@gifs.container"
cat <<'EOF' > "${SHP2}/nats-shard@gifs.container.d/10-override.conf"
[Container]
Environment=FLUXER_MEDIA_PROXY_PUBLIC_ENDPOINT=${FLUXER_PUBLIC_SCHEME}://${FLUXER_DOMAIN}/media
EOF
fi

if [ ! -f "${SHP2}/nats-shard@messages.container.d/10-override.conf" ]; then
echo "Creating systemd override for nats-shard@messages.container"
cat <<'EOF' > "${SHP2}/nats-shard@messages.container.d/10-override.conf"
[Unit]
Requires=fluxer-nats.service database@postgres.service nats@messages.service
After=fluxer-nats.service database@postgres.service nats@messages.service

[Container]
Environment=FLUXER_POSTGRES_MAX_CONNECTIONS=${RUBBERVERSE_XYZ_MESSAGES_SHARD_PG_MAX_CONNECTIONS}
Environment=FLUXER_SVC_MAX_CONCURRENT_REQUESTS=${FLUXER_SVC_MAX_CONCURRENT_REQUESTS}
Network=nats-network
Network=iso-postgres-network
EOF
fi

if [ ! -f "${SHP2}/nats-shard@unfurl.container.d/10-override.conf" ]; then
echo "Creating systemd override for nats-shard@unfurl.container"
cat <<'EOF' > "${SHP2}/nats-shard@unfurl.container.d/10-override.conf"
[Container]
Environment=FLUXER_MEDIA_PROXY_PUBLIC_ENDPOINT=${FLUXER_PUBLIC_SCHEME}://${FLUXER_DOMAIN}/media
Environment=FLUXER_STATIC_CDN_ENDPOINT=${FLUXER_PUBLIC_SCHEME}://${FLUXER_DOMAIN}
EOF
fi

if [ ! -f "${SHP2}/nats@gifs.container.d/10-override.conf" ]; then
echo "Creating systemd override for nats@gifs.container"
cat <<'EOF' > "${SHP2}/nats@gifs.container.d/10-override.conf"
[Container]
Environment=FLUXER_MEDIA_PROXY_PUBLIC_ENDPOINT=${FLUXER_PUBLIC_SCHEME}://${FLUXER_DOMAIN}/media
EOF
fi

if [ ! -f "${SHP2}/nats@messages.container.d/10-override.conf" ]; then
echo "Creating systemd override for nats@messages.container"
cat <<'EOF' > "${SHP2}/nats@messages.container.d/10-override.conf"
[Unit]
Requires=fluxer-nats.service database@postgres.service nats-shard@messages.service
After=fluxer-nats.service database@postgres.service
Before=nats-shard@messages.service

[Container]
Environment=FLUXER_SVC_MAX_CONCURRENT_REQUESTS=${FLUXER_SVC_MAX_CONCURRENT_REQUESTS}
Network=nats-network
Network=iso-postgres-network
EOF
fi

if [ ! -f "${SHP2}/nats@unfurl.container.d/10-override.conf" ]; then
echo "Creating systemd override for nats@unfurl.container"
cat <<'EOF' > "${SHP2}/nats@unfurl.container.d/10-override.conf"
[Container]
Environment=FLUXER_MEDIA_PROXY_PUBLIC_ENDPOINT=${FLUXER_PUBLIC_SCHEME}://${FLUXER_DOMAIN}/media
Environment=FLUXER_STATIC_CDN_ENDPOINT=${FLUXER_PUBLIC_SCHEME}://${FLUXER_DOMAIN}
EOF
fi

if [ ! -f "${SHP2}/nats@users.container.d/10-override.conf" ]; then
echo "Creating systemd override for nats@users.container"
cat <<'EOF' > "${SHP2}/nats@users.container.d/10-override.conf"
[Container]
Environment=FLUXER_SVC_MAX_CONCURRENT_REQUESTS=${FLUXER_SVC_MAX_CONCURRENT_REQUESTS}
EOF
fi

echo "MEow gdrjifrtiujhrij"

unset SHP1 SHP2 SHP3
SHP1="${HOME}/.config/containers/systemd/Fluxer"
SHP2="${HOME}/.config/containers/systemd/Fluxer/symlinks"
SHP3="${HOME}/.config/containers/systemd/Fluxer/networks"

echo "Creating symlinks so overrides can be used"
for type in gifs messages unfurl
do
    [ ! -L "${SHP2}/nats@${type}.container" ] && ln -s "${SHP1}/nats@.container" "${SHP2}/nats@${type}.container"
    [ ! -L "${SHP2}/nats-shard@${type}.container" ] && ln -s  "${SHP1}/nats-shard@.container" "${SHP2}/nats-shard@${type}.container"
done
[ ! -L "${SHP2}/nats@users.container" ] && ln -s "${SHP1}/nats@.container" "${SHP2}/nats@users.container"
unset type
for type in postgres valkey meilisearch
do
    [ ! -L "${SHP2}/database@${type}.container" ] && ln -s "${SHP1}/database@.container" "${SHP2}/database@${type}.container"
done
unset type
for type in gifs messages unfurl snowflakes users
do
    [ ! -L "${SHP2}/generic@${type}.network" ] && ln -s "${SHP1}/generic@.network" "${SHP2}/generic@${type}.network"
done
unset type

unset SHP1 SHP2 SHP3
systemctl --user daemon-reload
echo "MEOOW MWQEOKMFERGMergkme"
