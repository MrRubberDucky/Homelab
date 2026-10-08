## 7.1.0.2026

Experimental changes. Just more heavy limits or options being set.

`fluxer-push.container`

- Added this new container for push notifications
- Tmpfs mount over `/tmp` and `/var/run` with size 1m and `noexec,nosuid,nodev` flags
- Implemented resource limits: 128M memory, 2 CPU core(s), 0M swap memory

`fluxer-nats.container`, `nats.conf`

- Added `fluxer-push.service` as dependency
- Reduced JetStream `max_memory_store` from 4GB to 2GB and `max_file_store` from 40GB to 20GB
- Changed container memory limits from 4G to 2G

`fluxer-meilisearch.container`

- Added  environment variables `MEILI_MAX_INDEXING_MEMORY=256M` and `MEILI_EXPERIMENTTAL_REDUCE_INDEXING_MEMORY_USAGE=true`
- Changed container memory limits from 1536M to 1G

`fluxer-seaweedfs.container`

- Added `-master.volumeSizeLimitMB=5192` and set `-master.volumePreallocate=6` in `Exec=`
- Added environment variables `GOMEMLIMIT=1792` and `GOGC=100`

`fluxer-api.container`, `fluxer-worker.container`

- Both: Wrap `NODE_OPTIONS` environment variable so quadlet systemd generator does not split it into separate envs
- Both: Change `--max-old-space-size` to `--max-old-space-size-percentage`
- Both: Set `--max-old-space-size-percentage=50` and `--max-semi-space-size=32`
- Both: Changed container memory limit from 2G to 512M
- api: Changed size of `/tmp` to match max upload filesize on instance

`fluxer-media-proxy.container`, `fluxer-gateway.container`

- Both: Changed container memory limit from 512M to 256M
- media-proxy: Changed container CPU core(s) to 1

`fluxer-postgres.container`, `.sysenv`

- Modified environment variables to align the default values to 4GB memory (3GB + 1GB buffer)
- Changed container memory limits from 5G to 4G

`fluxer-app-proxy.container`, `fluxer-admin.container`, `fluxer-static-proxy.container`

These just serve static content or do very quick calls to API. We'll see if it creates problems down the line.

- Changed container memory limits from 128M to 32M

`routers/fluxer-*.container`, `shards/fluxer-*-shard.container`

- All: Tmpfs mount over `/tmp` and `/var/run` with size 1m and `noexec,nosuid,nodev` flags
- All: Implemented resource limits: 64M memory, 2 CPU core(s), 0M swap memory
- unfurl-shard: Fix environment variable for static & media-proxy being set wrong

`00_sysenv.env`

- Add branding configuration

`_compose.env`

- Remove comments and outdated environment variables

## 6.10.2026

`fluxer-seaweedfs.container`

- Removed environment variables from previous template experimentation
- Using mirrored and pre-hardened image `public.ecr.aws/aikido-dev/chrislusf/seaweedfs:latest` (docker hub is a prison)
- Tmpfs mount over `/tmp` and `/var/run` with size 1m and `noexec,nosuid,nodev` flags
- Implemented resource limits: 2G memory, 2 CPU core(s), 0M swap memory
- Added `-master.telemetry=false` to `Exec=`

`fluxer-nats.container`

- Removed environment variables from previous template experimentation
- Now using scratch image instead of trixie
- Reworked dependencies
- Implemented resource limits: 4G memory, 2 CPU core(s), 0M swap memory

`fluxer-meilisearch.container`

- Removed environment variables from previous template experimentation
- Pin to latest image tag `v1`
- Always upgrade database on every update
- Tmpfs mount over `/tmp` and `/var/run` with size 1m and `noexec,nosuid,nodev` flags
- Implemented resource limits: 1536M memory, 2 CPU core(s), 0M swap memory

`fluxer-valkey.container`

- Removed environment variables from previous template experimentation
- Point at general `trixie` tag instead of versioned tag
- Tmpfs mount over `/tmp` and `/var/run` with size 1m and `noexec,nosuid,nodev` flags
- Implemented resource limits: 256M memory, 2 CPU core(s), 0M swap memory

`fluxer-caddy.container`

- Removed environment variables from previous template experimentation
- Removed one pointless `Volume=` directive
- Use `latest-vanilla` tag instead for `qor-caddy` imag
- Implemented resource limits: 128M memory, 2 CPU core(s), 0M swap memory

The rest of the containers were treated in same way with limited size tmpfs mount and resource limits. Too lazy to write them.
