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
