Testing reduction in generated quadlet files by using systemd & quadlet systemd generatr template and override system.
Templates are expected to not be modified directly, instead users should create an override for the service they want to modify.

`install.sh` will set everything up and deploy the containers live, currently it only sets up directories, overrides and symlinks as needed.

## Requirements

- Minimum: Podman v5.2.0, Recommended: Podman v6.0.0+

Older versions of `quadlet-systemd-generator` don't support files in different directories, preferably update your version of Podman so you can avoid this issue altogether.

## Differences compared to my current Fluxer deployment

Instead of having 6+ configurations for NATS, Database and network components, it is instead generated dynamically from following templates: `nats@.container`, `nats-shard@.container`, `database@.container` and `generic@.network`. This results in a reduction of around 13 `.container` files.

The way it's achieved is by:

1. Creating overrides for each service that needs it inside `~/.config/containers/systemd/Fluxer/overrides` (automated by script)
2. Creating symlinks to core template files with full path as argument inside `~/.config/containers/systemd/Fluxer/symlinks` so quadlet systemd generator can add our overrides (automated by script)

Symlinks need to be created as quadlet systemd generator can't see or override anything that is not there. By creating a symlink, quadlet systemd generator can use our overrides for ex. `database@postgres.container.d`. Modifying the generated service directly is possible with a override but it's volatile and considering Podman changes a lot and so do it's components, it may be unreliable long-term solution.

These current quadlets also change with what user containers get ran by default which is `65534:65534` (`nobody:nobody`) instead of `1100:1100` for supported containers. We are extending the user namespace anyway so we may as well reap it's benefits by running an obnoxiously high UID:GID for our container user. I've also implemented a way to set dedicated CPU cores & memory swap limits for each container which is customizable via `.sysenv`.

`/tmp` and `/var/run` now have stricter storage limitations with following mount flags `noexec,nosuid,nodev`. Fully qualified image names were restored as it was a generally not a very good idea t do it the way I did it, for such modifications it's recommended to make use of overrides. It also caused quadlet systemd generator to complain every time user daemon was reloaded.

## Can it be re-used for other projects?

A simple generic quadlet template can be reused for any project you desire, all you need to do is create a symlink and create an override anywhere inside `~/.config/containers/systemd` with `containername.container.d` as it's name. Same should be possible for any type even `.network` but I didn't test it yet.

Generally I may replace most of my Quadlet deployment with this approach as it's just simpler to maintain in long-term as one change can be done by either modifying the template itself (which will affect all containers re-using that template) or by creating a specific service override.

## `install.sh`

It is needed as you need to create a lot of symlinks, directories and have everything be set up for you. It's all in a single script so it can be easily audited by anyone and will never pull portions of script remotely and execute it.

It's planned to:

1. Install all quadlet configurations from here with `podman quadlet install <url>`
2. Move everything to unified directory `~/.config/containers/systemd/Fluxer`
3. Create all necessary directories by the script and for overrides
4. Create all necessary overrides using `cat <<'EOF' >` heredoc to avoid pulling files from repository
5. Set up `.sysenv` and prepare `.env` for Fluxer deployment by automatically running openssl rand -hex 32 and replacing values
6. Ask for extra input from users for some values and fill both `.sysenv` and `.env`

## `.sysenv`

Short for system environment, this is used by systemd itself to inject environment variables into the service. These environment variables **aren't** accessible inside container, in fact container has no idea they're even a thing! They're used to allow for quick modification of some template options for each service, though any deeper modification will require an override still.

It's mimicking the way `docker-compose.yaml` works for Fluxer but with new extra environment variables that I've included.

Template Example:

```.container
[Unit]
Description=Fluxer NATS Router for %i
Requires=fluxer-nats.service nats-shard@%i.service
After=fluxer-nats.service
Before=nats-shard@%i.service

[Install]
WantedBy=multi-user.target

[Service]
Restart=on-failure
SystemCallArchitectures=native
MemoryDenyWriteExecute=true
EnvironmentFile=%h/Fluxer/.sysenv

[Container]
Image=ghcr.io/fluxerapp/fluxer-%i:v1
ContainerName=fluxer-%i
Timezone=${RUBBERVERSE_XYZ_CONTAINER_TIMEZONE}
EnvironmentFile=%h/Fluxer/.env
Environment=FLUXER_SVC_NAME=%i
Environment=FLUXER_SVC_MODE=router
AutoUpdate=registry
Tmpfs=/tmp:rw,size=4m,noexec,nosuid,nodev
Tmpfs=/var/run:rw,size=4m,noexec,nosuid,nodev
NoNewPrivileges=true
DropCapability=all
ReadOnly=true
PodmanArgs=--cpus=${RUBBERVERSE_XYZ_CPU_CORES_%i}
PodmanArgs=--memory-swap=${RUBBERVERSE_XYZ_SWAP_MEMORY_%i}
Memory=${RUBBERVERSE_XYZ_MEMORY_LIMIT_%i}
Network=%i-network
UserNS=auto
```

Example:

```.env
# >> [Network] [IPv6] [generic@] [generic-isolated@] (generated)
# Enable or disable IPv6 support in all generated rootless networks
# Boolean: true/false
RUBBERVERSE_XYZ_IPv6_SUPPORT=false
# >> [Limit] [Resources] [nats@] (generated)
# CPU Count Limit per generated NATS container ex. 1.5 cores
RUBBERVERSE_XYZ_CPU_CORES_gifs=2
RUBBERVERSE_XYZ_CPU_CORES_users=2
RUBBERVERSE_XYZ_CPU_CORES_unfurl=2
RUBBERVERSE_XYZ_CPU_CORES_messages=2
RUBBERVERSE_XYZ_CPU_CORES_snowflakes=2
# >> [Limit] [Resources] [nats@] (generated)
# Max usable memory per generated NATS container
RUBBERVERSE_XYZ_MEMORY_LIMIT_gifs=128m
RUBBERVERSE_XYZ_MEMORY_LIMIT_users=128m
RUBBERVERSE_XYZ_MEMORY_LIMIT_unfurl=128m
RUBBERVERSE_XYZ_MEMORY_LIMIT_messages=128m
RUBBERVERSE_XYZ_MEMORY_LIMIT_snowflakes=128m
# >> [Limit] [Swap] [Resources] [nats@] (generated)
# Max usable swap memory per generated NATS shard container
RUBBERVERSE_XYZ_SWAP_MEMORY_gifs=0m
RUBBERVERSE_XYZ_SWAP_MEMORY_users=0m
RUBBERVERSE_XYZ_SWAP_MEMORY_unfurl=0m
RUBBERVERSE_XYZ_SWAP_MEMORY_messages=0m
RUBBERVERSE_XYZ_SWAP_MEMORY_snowflakes=0m
# >> [Limit] [Resources] [nats-shard@] (generated)
# CPU Count Limit per generated NATS shard container ex. 1.5 cores
RUBBERVERSE_XYZ_CPU_CORES_SHARD_gifs=2
RUBBERVERSE_XYZ_CPU_CORES_SHARD_users=2
RUBBERVERSE_XYZ_CPU_CORES_SHARD_unfurl=2
RUBBERVERSE_XYZ_CPU_CORES_SHARD_messages=2
RUBBERVERSE_XYZ_CPU_CORES_SHARD_snowflakes=2
# >> [Limit] [Resources] [nats-shard@] (generated)
# Max usable memory per generated NATS shard container
RUBBERVERSE_XYZ_MEMORY_LIMIT_SHARD_gifs=128m
RUBBERVERSE_XYZ_MEMORY_LIMIT_SHARD_users=128m
RUBBERVERSE_XYZ_MEMORY_LIMIT_SHARD_unfurl=128m
RUBBERVERSE_XYZ_MEMORY_LIMIT_SHARD_messages=128m
RUBBERVERSE_XYZ_MEMORY_LIMIT_SHARD_snowflakes=128m
# >> [Limit] [Swap] [Resources] [nats-shard@] (generated)
# Max usable swap memory per generated NATS shard container
RUBBERVERSE_XYZ_SWAP_MEMORY_SHARD_gifs=0m
RUBBERVERSE_XYZ_SWAP_MEMORY_SHARD_users=0m
RUBBERVERSE_XYZ_SWAP_MEMORY_SHARD_unfurl=0m
RUBBERVERSE_XYZ_SWAP_MEMORY_SHARD_messages=0m
RUBBERVERSE_XYZ_SWAP_MEMORY_SHARD_snowflakes=0m
# >> [Time] [all]
# Timezone to use for all containers
RUBBERVERSE_XYZ_CONTAINER_TIMEZONE=Europe/Warsaw
```

## Why?

Because we can go above and beyond. This is mostly me testing my barebones systemd knowledge to do something way more advanced and reap it's benefits while showing that quadlet systemd generator is way more powerful if you let it be, along with Podman quadlets being vastly superior over the vastly inferior `docker-compose` plugin. This also allows me to create a fully scripted install that does all the heavy lifting for you, that part will be fun to pull off but that's why `install.sh` is here.

## Did Clode throw this up?///

I'm learning here, not vibe-coding shit. If you let LLM hand-hold you then what's the point of homelabbing anyway? It's fine to look up information using LLMs since they made search engines be hot garbage but don't rely on them 100% and always verify what it spits out at you as it nearly always gets things wrong.

No. Everything you see here and every single quadlet was manually thrown up by me. It's getting tired constantly modifying configurations so I'm exploring this method.

