## 18.10.2026

The ultimate "we are going back on some limits and fixing other stuff". Memory usage is same as before just now that when a container needs more memory it can actually borrow it instead of just either crashing or timing out.

<img width="952" height="102" alt="obraz" src="https://github.com/user-attachments/assets/9c4e1db8-6a88-45c9-85f4-a404d2582e2f" />

...and video playback (1 user) - hovers between 2GB. Around 230MB increase or something like that. Nothing too tragic. Maybe I could've made it lower with bigger and less volumes but I can think about that being an issue when I start having more than 5 people on my instance.

<img width="1157" height="445" alt="obraz" src="https://github.com/user-attachments/assets/d6acd04f-6ab3-4564-a2c3-f48acc2ceadb" />

~~This poor i3-9100 is screaming for mercy at this point.~~

---

`fluxer-seaweedfs.container` , `fluxer-seaweedfs-init.container`

- init: Port latest changes from latest docker-compose to here, point to fluxer-seaweedfs
- init: Use the same image as seaweedfs container and set proper envs so it fits this specific deployment
- seaweedfs: Change bucket size from 5192MB to 10240MB and max volumes to 7

As always, experimenting around. Init will now properly create buckets and set authorization password so there's nothing to worry about now.

`fluxer-api.container`, `fluxer-worker.container`,

- Both: Changed container memory limits from 512M to 2G
- Both: Changed `--max-old-space-size-percentage` from 50 to 30 and `--max-semi-space-size` from 32 to 16
- worker: Changed `/tmp` tmpfs mount size from 8m to 2G

Max memory limits were changed to workaround the sudden bursts of required memory that API and Worker containers require. 2GB just looks to be more comfortable compared to the old limits and containers still run at a relative low memory footprint (api container itself runs at 342MB currently). Tweaking Young space here to be lower by -16 causes more stuff to get garbage collected instead of being promoted to Old so that seems to be the sweet spot for both of those components, it does not cause any significant increase in CPU resources being used, not that I've noticed at least and it prevents OOM from occuring on large file uploads so it's a + in my book. Tested it with 300MB video upload.

Heap is still kept relatively low at only 30% which is ~614MB so that's more or so why it runs lower still despite the higher limit.

On large file uploads or archive creation, fluxer-worker container will store some data, presumably the actual guild data itself that it's tasked to collect. Size of `/tmp` needs to be adjusted appropriately, otherwise it will fail on servers with a huge message history nearly instantly. 

`fluxer-meilisearch.container`

- Set MEILI_MAX_INDEXING_MEMORY to 512MB
- Changed `/tmp` tmpfs mount size from 1m to 2G
- Removed pointless `/var/run` tmpfs mount
- Set `MemoryDenyWriteExecute` to true from false

`fluxer-media-proxy.container`

- Extend memory limit to `2G` to satisfy AV memory budget on large video file uploads

Anything lower and uploads 100MB+ started failing to embed. It's possible that uploads will still fail to embed either way if they cross 400MB+ range, as AV budget grows more and more demanding the higher the file-size. It is 512MB + 256MB (AV) budget and it seems to grow with size of the video. 768MB budget was fine for =<100MB but above 100MB it suddenly stopped embedding videos with `{"message":"native work refused, larger than the memory budget","bytes":444497958,"capacity":436207616}` (444.8MB needed, 436.2076MB total capacity with `Memory=768M`, 76MB either left as a buffer or used for other purpose)

Could probably limit it tighter but eh. Maybe later down the line. I need my sleep now. Goodnight.

## 7.10.2026

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
