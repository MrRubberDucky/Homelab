Fluxer is "a free and open source instant messaging and VoIP chat app built for friends, groups, and communities." See it as self-hostable Discord alternative that actually feels like an alternative.

## Requirements

- Podman v5.8+
- systemd
- Files stored under `/srv` (you can change the volume binds though if you wish)

## Explanation

"Translated" [docker-compose.yaml](https://github.com/fluxerapp/fluxer/blob/main/deploy/self-hosting/docker-compose.yml) from fluxerapp repository to Quadlet format so Podman users can enjoy this chatting app in the safety of their favorite containerization software.

Includes everything but LiveKit. For LiveKit, look inside Matrix folder. You'll need to readjust your envs and setup done here to suit your needs, I'm reverse proxying it via Caddy on my VPS.

Dependencies should resolve properly, launch `fluxer-caddy` to start everything. Network inside a pod is shared so couldn't just throw everything into a pod and call it a day, it would conflict and crash left'n'right. Every container image already runs as a rootless user inside of them so I've only done the necessary things to Postgres, Valkey and NATS. `DropCapability=all`, `NoNewPrivileges=true` and `AutoUpdate=registry` is also included here. `MemoryDenyWriteExecute=` is something to be tested still, this is mostly a NodeJS, Rust and Erlang project and those programming languages generally want memory to be executable and writable. Some networks are Internal-only so no outgoing connections for them.

I'm using my own Caddy image here as I know it best and it can run without any extra capabilities and also read-only. You'll get some extra modules on top of it if you're just exposing it directly - look [here](https://github.com/rubberverse/qor-caddy) for more information.

Networks are separated and isolated between containers that's why there's so many `.network` files.

For Meilisearch - I've tried going the `EnvironmentFile=` route but for some reason it just doesn't read those values? That's why it's done this way. You'll need to customize the key here and update `FLUXER_MEILISEARCH_KEY` in `Fluxer.env` to get it to work properly.

## Usage

Just clone this repository and drag this folder out, don't go one by one it will be a huge waste of time.

1. Make following directories and use root account to own them to your rootless user (or use your home directory)

```bash
mkdir -p /srv/fluxer/db /srv/fluxer/meili /srv/fluxer/nats /srv/fluxer/caddy /srv/fluxer/seaweedffs
```

2. Move `configs/*` to `/srv/fluxer/caddy`

```bash
mv configs/* /srv/fluxer/caddy
```

3. Move `environments/Fluxer.env` to `/srv/fluxer/.env` & modify it to suit your deployment & include necessary secrets

```bash
mv environments/Fluxer.env /srv/fluxer/.env
nano /srv/fluxer/.env
```

4. Move `networks` to `~/.config/containers/systemd`

```bash
mv ./networks ~/.config/containers/systemd
```

5. Move `*.container` files to `~/.config/containers/systemd/fluxer`

```bash
mkdir -p ~/.config/containers/systemd/fluxer
mv ./*.container ~/.config/containers/systemd/fluxer
```

6. Modify following `.container` files to suit your deployment & include necessary secrets

- `fluxer-meilisearch.container`
- `fluxer-admin.container`
- `fluxer-caddy.container`
- `fluxer-gateway.container`

7. Reload systemd user daemon

```bash
systemctl --user daemon-reload
```

8. Start stack

```bash
systemctl --user start fluxer-api fluxer-nats fluxer-caddy fluxer-seaweeds
```

If I didn't screw anything up, whole stack should launch.

Yeah I wasted 10 hours on this for no one to really see this but that's just *life*. In case you want help with getting this to run then you can ask me in GitHub issues if you somehow found this and are having trouble.
