## 7.1.0.2026

`fluxer-nats.container`, `nats.conf`

- Reduced JetStream `max_memory_store` from 4GB to 2GB
- Reduced JetStream `max_file_store` from 40GB to 20GB
- Changed container memory limits from 4G to 2G

`fluxer-meilisearch.container`

- Added `MEILI_MAX_INDEXING_MEMORY` and `MEILI_EXPERIMENTTAL_REDUCE_INDEXING_MEMORY_USAGE` environment variables
- Set `MEILI_MAX_INDEXING_MEMORY` to 512M
- Set `MEILI_EXPERIMENTTAL_REDUCE_INDEXING_MEMORY_USAGE` to true
- Change container memory limits from 1536M to 1G

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
